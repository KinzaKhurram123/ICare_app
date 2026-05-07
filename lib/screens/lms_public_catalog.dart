import 'package:flutter/material.dart';
import 'package:icare/screens/lms_public_course_detail.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/theme.dart';

/// Public LMS Course Catalog - Browse courses without login
/// Inspired by Moodle & Coursera course marketplace
class LmsPublicCatalog extends StatefulWidget {
  const LmsPublicCatalog({super.key});

  @override
  State<LmsPublicCatalog> createState() => _LmsPublicCatalogState();
}

class _LmsPublicCatalogState extends State<LmsPublicCatalog> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _courses = [];
  List<dynamic> _filteredCourses = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  
  final List<String> _categories = [
    'All',
    'HealthProgram',
    'Medical Training',
    'Wellness',
    'Nutrition',
    'Mental Health',
    'Fitness',
    'Professional Development'
  ];
  
  final List<String> _difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadPublicCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPublicCourses() async {
    setState(() => _isLoading = true);
    try {
      // Call public endpoint (no auth required)
      final response = await _api.get('/courses/public');
      if (response.data['success'] == true) {
        setState(() {
          _courses = response.data['courses'] ?? [];
          _filteredCourses = _courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load courses')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        // Category filter
        if (_selectedCategory != 'All' && course['category'] != _selectedCategory) {
          return false;
        }
        
        // Difficulty filter
        if (_selectedDifficulty != 'All' && course['difficulty'] != _selectedDifficulty) {
          return false;
        }
        
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          final title = (course['title'] ?? '').toString().toLowerCase();
          final description = (course['description'] ?? '').toString().toLowerCase();
          if (!title.contains(searchQuery) && !description.contains(searchQuery)) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Explore Courses',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.login, color: Color(0xFF6366F1)),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            tooltip: 'Login',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
                const SizedBox(height: 16),
                
                // Filters Row
                if (isDesktop)
                  Row(
                    children: [
                      Expanded(child: _buildCategoryFilter()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDifficultyFilter()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildCategoryFilter(),
                      const SizedBox(height: 12),
                      _buildDifficultyFilter(),
                    ],
                  ),
              ],
            ),
          ),
          
          // Results Count
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Row(
              children: [
                Text(
                  '${_filteredCourses.length} courses found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          
          // Course Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPublicCourses,
                        child: GridView.builder(
                          padding: EdgeInsets.all(isDesktop ? 24 : 16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: isDesktop ? 0.75 : 0.85,
                          ),
                          itemCount: _filteredCourses.length,
                          itemBuilder: (context, index) {
                            return _CourseCard(
                              course: _filteredCourses[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LmsPublicCourseDetail(
                                      courseId: _filteredCourses[index]['_id'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category, size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _categories.map((cat) {
        return DropdownMenuItem(value: cat, child: Text(cat));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value!);
        _applyFilters();
      },
    );
  }

  Widget _buildDifficultyFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedDifficulty,
      decoration: InputDecoration(
        labelText: 'Difficulty',
        prefixIcon: const Icon(Icons.signal_cellular_alt, size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _difficulties.map((diff) {
        return DropdownMenuItem(value: diff, child: Text(diff));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedDifficulty = value!);
        _applyFilters();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No courses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

/// Course Card Widget
class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbnail = course['thumbnail'] ?? course['thumbnail_url'];
    final title = course['title'] ?? 'Untitled Course';
    final description = course['description'] ?? '';
    final category = course['category'] ?? 'General';
    final difficulty = course['difficulty'] ?? 'Beginner';
    final rating = (course['rating'] ?? 0.0).toDouble();
    final totalReviews = course['total_reviews'] ?? 0;
    final duration = course['duration'] ?? 0;
    
    // Count modules and lessons
    final modules = (course['modules'] as List?) ?? [];
    final lessonCount = modules.fold<int>(
      0,
      (sum, module) => sum + ((module['lessons'] as List?) ?? []).length,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: thumbnail != null
                  ? Image.network(
                      thumbnail,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Difficulty
                    Row(
                      children: [
                        _Badge(label: category, color: const Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        _Badge(label: difficulty, color: const Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    
                    // Stats Row
                    Row(
                      children: [
                        if (rating > 0) ...[
                          const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Text(
                            '$rating ($totalReviews)',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Icon(Icons.play_circle_outline, size: 14, color: Color(0xFF6366F1)),
                        const SizedBox(width: 4),
                        Text(
                          '$lessonCount lessons',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.7),
            AppColors.primaryColor,
          ],
        ),
      ),
      child: const Icon(Icons.school, size: 60, color: Colors.white70),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
