import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/services/course_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class HealthCommunityScreen extends StatefulWidget {
  const HealthCommunityScreen({super.key});

  @override
  State<HealthCommunityScreen> createState() => _HealthCommunityScreenState();
}

class _HealthCommunityScreenState extends State<HealthCommunityScreen> {
  final CourseService _courseService = CourseService();
  final List<String> _categories = [
    'All',
    'Diabetes',
    'Heart Health',
    'Mental Wellness',
    'Nutrition',
    'Pregnancy',
    'COVID-19',
  ];
  String _selectedCategory = 'All';
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _courseService.getForumPosts(
        category: _selectedCategory,
      );
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading community posts: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: const CustomBackButton(),
        title: const Text(
          'Health Community',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPosts,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildCreatePostHeader();
                        return _buildPostCard(_posts[index - 1]);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostBottomSheet(),
        backgroundColor: AppColors.primaryColor,
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Post',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _selectedCategory = category);
                _loadPosts();
              },
              backgroundColor: const Color(0xFFF8FAFC),
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatePostHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _showCreatePostBottomSheet(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Share your health journey...',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final authorName = post['authorName'] ?? post['author']?['name'] ?? 'User';
    final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U';
    final isExpert = post['isExpert'] ?? false;
    final role = post['authorRole'] ?? post['author']?['role'] ?? 'Patient';
    final timeRaw = post['createdAt'] ?? post['updatedAt'];
    final time = timeRaw != null
        ? DateTime.parse(timeRaw.toString())
        : DateTime.now();
    final String postId = post['_id'] ?? post['id'] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isExpert
                      ? Colors.blue
                      : AppColors.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: isExpert ? Colors.white : AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          if (isExpert)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified_rounded,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '$role • ${DateFormat('MMM dd').format(time)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCategoryBadge(post['category'] ?? 'General'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post['content'] ?? '',
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInteractionButton(
                  Icons.favorite_rounded,
                  (post['likes'] ?? 0).toString(),
                  const Color(0xFFEF4444),
                  () async {
                    await _courseService.likeForumPost(postId);
                    _loadPosts(); // Refresh for accurate counts
                  },
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  Icons.chat_bubble_rounded,
                  (post['replies'] ?? 0).toString(),
                  AppColors.primaryColor,
                  () {
                    setState(() {
                      post['_showComments'] = !(post['_showComments'] ?? false);
                    });
                  },
                ),
                const Spacer(),
              ],
            ),
            if (post['_showComments'] == true) ...[
              const Divider(height: 32, color: Color(0xFFEDF2F7)),
              _buildInlineCommentInput(postId),
              const SizedBox(height: 16),
              _buildCommentsSection(post['comments'] ?? []),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineCommentInput(String postId) {
    final controller = TextEditingController();
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
          child: const Icon(
            Icons.person_rounded,
            size: 18,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    try {
                      await _courseService.addForumComment(
                        postId,
                        controller.text,
                      );
                      _loadPosts(); // Refresh for latest comments
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: const Text('Something went wrong. Please try again.')));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(List<dynamic> comments) {
    if (comments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Most relevant',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final author = comment['authorName'] ?? 'User';
            final content = comment['content'] ?? '';
            final timeRaw = comment['createdAt'];
            final time = timeRaw != null
                ? DateTime.parse(timeRaw)
                : DateTime.now();

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text(
                      author.isNotEmpty ? author[0] : 'U',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    author,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(time),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                content,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {},
                              child: const Text(
                                'Like',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () {},
                              child: const Text(
                                'Reply',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String count,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: count == '0' ? const Color(0xFFCBD5E1) : color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostBottomSheet() {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 500),
            child: _CreatePostSheet(onPostSuccess: _loadPosts),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _CreatePostSheet(onPostSuccess: _loadPosts),
      );
    }
  }
}

class _CreatePostSheet extends StatefulWidget {
  final VoidCallback onPostSuccess;
  const _CreatePostSheet({required this.onPostSuccess});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();
  final CourseService _courseService = CourseService();
  String _selectedCategory = 'General';
  bool _isPosting = false;
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() => _imageFile = image);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(36))
            : BorderRadius.circular(32),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keep it short
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Text(
                    'Create New Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: _handleSubmit,
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items:
                        [
                              'General',
                              'Diabetes',
                              'Heart Health',
                              'Mental Wellness',
                              'Nutrition',
                              'Pregnancy',
                              'COVID-19',
                            ]
                            .map(
                              (String val) => DropdownMenuItem(
                                value: val,
                                child: Text(
                                  val,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                    underline: const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _contentController,
                maxLines: 4,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                ),
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb
                          ? Image.network(
                              _imageFile!.path,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_imageFile!.path),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => setState(() => _imageFile = null),
                        icon: const Icon(Icons.cancel, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined, color: Colors.green),
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.videocam_outlined, color: Colors.blue),
                  const SizedBox(width: 24),
                  const Icon(Icons.poll_outlined, color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    try {
      await _courseService.createForumPost({
        'content': _contentController.text,
        'category': _selectedCategory,
        // In a real app, you'd upload the image to a storage bucket first
        'image': _imageFile?.path,
      });
      widget.onPostSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Something went wrong. Please try again.')));
      }
    }
  }
}
