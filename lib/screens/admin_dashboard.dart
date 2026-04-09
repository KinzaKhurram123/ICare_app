import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/custom_button.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final String initialTab;
  const AdminDashboard({super.key, this.initialTab = 'Pending'});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _currentTab =
      'Pending'; // 'Pending', 'Student', 'Pharmacy', 'Laboratory', 'Instructor'

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);

    try {
      final endpoint = _currentTab == 'Pending'
          ? '/admin/pending-users'
          : '/admin/approved-users?role=$_currentTab';

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _users = data['users'] ?? [];
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTabChanged(String tab) {
    if (_currentTab == tab) return;
    setState(() {
      _currentTab = tab;
      _users = [];
    });
    _fetchUsers();
  }

  Future<void> _approveUser(String userId) async {
    try {
      final response = await _apiService.post(
        '/admin/approve-user/$userId',
        {},
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'User approved successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchUsers();
      }
    } catch (e) {
      print('Error approving user: $e');
    }
  }

  Future<void> _rejectUser(String userId) async {
    try {
      final response = await _apiService.post('/admin/reject-user/$userId', {});
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'User rejected successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        _fetchUsers();
      }
    } catch (e) {
      print('Error rejecting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Admin System Control',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabItem('Pending', Icons.pending_actions_rounded),
                _buildTabItem('Student', Icons.school_rounded),
                _buildTabItem('Pharmacy', Icons.local_pharmacy_rounded),
                _buildTabItem('Laboratory', Icons.science_rounded),
                _buildTabItem('Instructor', Icons.person_add_rounded),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentTab != 'Pending'
          ? FloatingActionButton.extended(
              onPressed: () => _showAddUserDialog(),
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add $_currentTab',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _currentTab == 'Pending'
                        ? Icons.check_circle_outline
                        : Icons.group_off_rounded,
                    size: 80,
                    color: Colors.blueGrey.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentTab == 'Pending'
                        ? "All Caught Up!"
                        : "No users found",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentTab == 'Pending'
                        ? "No pending users waiting for approval."
                        : "No verified users in this category yet.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'] ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user['email'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _currentTab == 'Pending'
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user['role'] ?? 'Unspecified',
                                style: TextStyle(
                                  color: _currentTab == 'Pending'
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (user['verificationDetails'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                if (user['verificationDetails']['organizationName'] !=
                                        null &&
                                    user['verificationDetails']['organizationName']
                                        .toString()
                                        .isNotEmpty)
                                  _buildDetailRow(
                                    Icons.business_rounded,
                                    "Organization",
                                    user['verificationDetails']['organizationName'],
                                  ),
                                if (user['verificationDetails']['location'] !=
                                        null &&
                                    user['verificationDetails']['location']
                                        .toString()
                                        .isNotEmpty)
                                  _buildDetailRow(
                                    Icons.location_on_rounded,
                                    "Location",
                                    user['verificationDetails']['location'],
                                  ),
                                if (user['verificationDetails']['licenseNumber'] !=
                                        null &&
                                    user['verificationDetails']['licenseNumber']
                                        .toString()
                                        .isNotEmpty)
                                  _buildDetailRow(
                                    Icons.badge_rounded,
                                    "License/Accreditation",
                                    user['verificationDetails']['licenseNumber'],
                                  ),
                                if (user['verificationDetails']['credentials'] !=
                                        null &&
                                    user['verificationDetails']['credentials']
                                        .toString()
                                        .isNotEmpty)
                                  _buildDetailRow(
                                    Icons.school_rounded,
                                    "Specialty/Credentials",
                                    user['verificationDetails']['credentials'],
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (_currentTab == 'Pending') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _rejectUser(user['_id']),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Reject & Delete'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _approveUser(user['_id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Approve Access',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final orgController = TextEditingController();
    final licenseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add New $_currentTab',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create a verified account for a $_currentTab. System credentials will be emailed to them.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              _buildDialogField(
                nameController,
                'Full Name',
                Icons.person_rounded,
              ),
              const SizedBox(height: 16),
              _buildDialogField(
                emailController,
                'Email Address',
                Icons.email_rounded,
              ),
              const SizedBox(height: 16),
              _buildDialogField(
                orgController,
                'Organization / University',
                Icons.business_rounded,
              ),
              const SizedBox(height: 16),
              _buildDialogField(
                licenseController,
                'License / Student ID',
                Icons.badge_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final userData = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': _currentTab,
                  'verificationDetails': {
                    'organizationName': orgController.text,
                    'licenseNumber': licenseController.text,
                  },
                };

                final response = await _apiService.post(
                  '/admin/create-user',
                  userData,
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$_currentTab added and credentials emailed!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
                _fetchUsers();
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Unable to complete action. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add & Notify'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon) {
    bool isActive = _currentTab == title;
    return GestureDetector(
      onTap: () => _onTabChanged(title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primaryColor : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.primaryColor : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary500),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
