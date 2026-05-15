const express = require('express');
const router = express.Router();
const { connectMongoDB } = require('../config/mongodb');
const CommunityPost = require('../models/CommunityPost');
const { authMiddleware } = require('../middleware/auth');
const cloudinary = require('../config/cloudinary');

// GET /api/community/posts — fetch posts (public)
router.get('/posts', async (req, res) => {
  try {
    await connectMongoDB();
    const { category, limit = 50, skip = 0 } = req.query;
    const filter = {};
    if (category && category !== 'All') filter.category = category;

    const posts = await CommunityPost.find(filter)
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .skip(Number(skip))
      .populate('userId', 'name role profilePicture')
      .lean();

    const formatted = posts.map(p => ({
      ...p,
      id: p._id.toString(),
      likeCount: (p.likes || []).length,
      commentCount: (p.comments || []).length,
    }));

    res.json({ success: true, posts: formatted });
  } catch (err) {
    console.error('GET /community/posts error:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch posts' });
  }
});

// POST /api/community/posts — create a post (auth required)
router.post('/posts', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { content, category, image, imageUrl } = req.body;

    if (!content || content.trim() === '') {
      return res.status(400).json({ success: false, message: 'Content is required' });
    }

    let finalImageUrl = imageUrl || null;

    // If a base64 image is provided, upload to Cloudinary
    if (image && image.startsWith('data:')) {
      try {
        const uploadResult = await cloudinary.uploader.upload(image, {
          folder: 'community_posts',
          resource_type: 'image',
          transformation: [{ width: 1200, height: 1200, crop: 'limit', quality: 'auto' }],
        });
        finalImageUrl = uploadResult.secure_url;
      } catch (uploadErr) {
        console.error('Cloudinary upload error:', uploadErr);
        // Continue without image if upload fails
      }
    }

    const post = await CommunityPost.create({
      userId: req.user.id,
      userName: req.user.name || req.user.username,
      userRole: req.user.role,
      content: content.trim(),
      category: category || 'General',
      imageUrl: finalImageUrl,
    });

    res.status(201).json({
      success: true,
      post: {
        ...post.toObject(),
        id: post._id.toString(),
        likeCount: 0,
        commentCount: 0,
      },
    });
  } catch (err) {
    console.error('POST /community/posts error:', err);
    res.status(500).json({ success: false, message: 'Failed to create post' });
  }
});

// POST /api/community/posts/:id/like — toggle like (auth required)
router.post('/posts/:id/like', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const post = await CommunityPost.findById(req.params.id);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });

    const userId = req.user.id;
    const alreadyLiked = post.likes.some(l => l.toString() === userId.toString());
    if (alreadyLiked) {
      post.likes = post.likes.filter(l => l.toString() !== userId.toString());
    } else {
      post.likes.push(userId);
    }
    await post.save();

    res.json({ success: true, liked: !alreadyLiked, likeCount: post.likes.length });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to like post' });
  }
});

// POST /api/community/posts/:id/comment — add comment (auth required)
router.post('/posts/:id/comment', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const { content } = req.body;
    if (!content || content.trim() === '') {
      return res.status(400).json({ success: false, message: 'Comment cannot be empty' });
    }

    const post = await CommunityPost.findByIdAndUpdate(
      req.params.id,
      {
        $push: {
          comments: {
            userId: req.user.id,
            userName: req.user.name || req.user.username,
            content: content.trim(),
          },
        },
      },
      { new: true }
    );
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });

    res.json({ success: true, commentCount: post.comments.length });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to add comment' });
  }
});

// DELETE /api/community/posts/:id — delete own post (auth required)
router.delete('/posts/:id', authMiddleware, async (req, res) => {
  try {
    await connectMongoDB();
    const post = await CommunityPost.findById(req.params.id);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    if (post.userId.toString() !== req.user.id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }
    await post.deleteOne();
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to delete post' });
  }
});

module.exports = router;
