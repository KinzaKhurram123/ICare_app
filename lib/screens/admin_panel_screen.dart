import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/utils/theme.dart';

/// Admin Panel
///
/// This is where admin-controlled users are onboarded:
/// - Laboratories (verified partners)
/// - Pharmacies (verified partners)
/// - Instructors (LMS teachers)
/// - Students (LMS learners)
/// - Doctor approvals
///
/// These roles CANNOT self-signup. Admin creates them.
class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock data
  List<Map<String, dynamic>> _pendingDoctors = [];
  List<Map<String, dynamic>> _laboratories = [];
  List<Map<String, dynamic>> _pharmacies = [];
  List<Map<String, dynamic>> _instructors = [];
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    // In real implementation, fetch from backend
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Gilroy-Bold',
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Manage users and system settings',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontFamily: 'Gilroy-Medium',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryColor,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorWeight: 3,
              isScrollable: true,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                fontFamily: 'Gilroy-Bold',
              ),
              tabs: [
                Tab(text: 'DOCTOR APPROVALS (${_pendingDoctors.length})'),
                Tab(text: 'LABORATORIES (${_laboratories.length})'),
                Tab(text: 'PHARMACIES (${_pharmacies.length})'),
                Tab(text: 'INSTRUCTORS (${_instructors.length})'),
                Tab(text: 'STUDENTS (${_students.length})'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDoctorApprovalsTab(),
                _buildLaboratoriesTab(),
                _buildPharmaciesTab(),
                _buildInstructorsTab(),
                _buildStudentsTab(),
              ],
            ),
    );
  }

  Widget _buildDoctorApprovalsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Doctor Approvals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Gilroy-Bold',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review and approve doctor registrations',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          if (_pendingDoctors.isEmpty)
            _buildEmptyState('No pending approvals', Icons.check_circle_outline)
          else
            Expanded(
              child: ListView.builder(
                itemCount: _pendingDoctors.length,
                itemBuilder: (ctx, i) => _buildDoctorApprovalCard(_pendingDoctors[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLaboratoriesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laboratory Partners',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Gilroy-Bold'),
                  ),
                  SizedBox(height: 4),
                  Text('Verified lab partners in the system', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _addLaboratory,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Laboratory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_laboratories.isEmpty)
            _buildEmptyState('No laboratories added', Icons.science_outlined)
          else
            Expanded(
              child: ListView.builder(
                itemCount: _laboratories.length,
                itemBuilder: (ctx, i) => _buildLabCard(_laboratories[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPharmaciesTab() {
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Pharmacy Partners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ElevatedButton.icon(onPressed: _addPharmacy, icon: const Icon(Icons.add), label: const Text('Add')),
      ]),
      if (_pharmacies.isEmpty) _buildEmptyState('No pharmacies', Icons.local_pharmacy_outlined),
    ]));
  }

  Widget _buildInstructorsTab() {
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Instructors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ElevatedButton.icon(onPressed: _addInstructor, icon: const Icon(Icons.add), label: const Text('Add')),
      ]),
      if (_instructors.isEmpty) _buildEmptyState('No instructors', Icons.school_outlined),
    ]));
  }

  Widget _buildStudentsTab() {
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ElevatedButton.icon(onPressed: _addStudent, icon: const Icon(Icons.add), label: const Text('Add')),
      ]),
      if (_students.isEmpty) _buildEmptyState('No students', Icons.person_outline),
    ]));
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.06), shape: BoxShape.circle),
        child: Icon(icon, size: 48, color: AppColors.primaryColor.withOpacity(0.5))),
      const SizedBox(height: 16),
      Text(msg, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    ]));
  }

  Widget _buildDoctorApprovalCard(Map<String, dynamic> d) {
    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 12),
          Expanded(child: Text('Dr. ${d['name'] ?? 'Unknown'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => _rejectDoctor(d), child: const Text('Reject'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton(onPressed: () => _approveDoctor(d), child: const Text('Approve'))),
        ]),
      ]));
  }

  Widget _buildLabCard(Map<String, dynamic> lab) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [const Icon(Icons.science), const SizedBox(width: 12),
        Expanded(child: Text(lab['name'] ?? 'Lab')), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {})]));
  }

  void _addLaboratory() {
    showDialog(
      context: context,
      builder: (ctx) => _AddLaboratoryDialog(
        onAdd: (labData) async {
          setState(() => _isLoading = true);
          try {
            // In real implementation, call backend API
            await Future.delayed(const Duration(seconds: 1));

            setState(() {
              _laboratories.add(labData);
              _isLoading = false;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Laboratory "${labData['name']}" added successfully'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          } catch (e) {
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to add laboratory'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _addPharmacy() {
    showDialog(
      context: context,
      builder: (ctx) => _AddPharmacyDialog(
        onAdd: (pharmacyData) async {
          setState(() => _isLoading = true);
          try {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _pharmacies.add(pharmacyData);
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pharmacy "${pharmacyData['name']}" added successfully'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          } catch (e) {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  void _addInstructor() {
    showDialog(
      context: context,
      builder: (ctx) => _AddInstructorDialog(
        onAdd: (instructorData) async {
          setState(() => _isLoading = true);
          try {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _instructors.add(instructorData);
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Instructor "${instructorData['name']}" added successfully'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          } catch (e) {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  void _addStudent() {
    showDialog(
      context: context,
      builder: (ctx) => _AddStudentDialog(
        onAdd: (studentData) async {
          setState(() => _isLoading = true);
          try {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _students.add(studentData);
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Student "${studentData['name']}" added successfully'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          } catch (e) {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  void _approveDoctor(Map<String, dynamic> d) async {
    setState(() => _isLoading = true);
    try {
      // Call backend API to approve doctor
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _pendingDoctors.remove(d);
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dr. ${d['name']} approved successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _rejectDoctor(Map<String, dynamic> d) async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _pendingDoctors.remove(d);
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dr. ${d['name']} rejected'),
            backgroundColor: const Color(0xFFF59E0B),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
}

// Laboratory Addition Dialog
class _AddLaboratoryDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  const _AddLaboratoryDialog({required this.onAdd});

  @override
  State<_AddLaboratoryDialog> createState() => _AddLaboratoryDialogState();
}

class _AddLaboratoryDialogState extends State<_AddLaboratoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Laboratory Partner', style: TextStyle(fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Laboratory Name *', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone *', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(labelText: 'License Number *', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address *', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final labData = {
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
                'license': _licenseController.text,
                'address': _addressController.text,
                'city': _cityController.text,
                'createdAt': DateTime.now().toIso8601String(),
              };
              Navigator.pop(context);
              widget.onAdd(labData);
            }
          },
          child: const Text('Add Laboratory'),
        ),
      ],
    );
  }
}

// Pharmacy Addition Dialog
class _AddPharmacyDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  const _AddPharmacyDialog({required this.onAdd});

  @override
  State<_AddPharmacyDialog> createState() => _AddPharmacyDialogState();
}

class _AddPharmacyDialogState extends State<_AddPharmacyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Pharmacy Partner'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Pharmacy Name *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            TextFormField(controller: _licenseController, decoration: const InputDecoration(labelText: 'License *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context);
            widget.onAdd({'name': _nameController.text, 'email': _emailController.text, 'phone': _phoneController.text, 'license': _licenseController.text, 'address': _addressController.text});
          }
        }, child: const Text('Add')),
      ],
    );
  }
}

// Instructor Addition Dialog
class _AddInstructorDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  const _AddInstructorDialog({required this.onAdd});

  @override
  State<_AddInstructorDialog> createState() => _AddInstructorDialogState();
}

class _AddInstructorDialogState extends State<_AddInstructorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Instructor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            TextFormField(controller: _specialtyController, decoration: const InputDecoration(labelText: 'Specialty *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context);
            widget.onAdd({'name': _nameController.text, 'email': _emailController.text, 'specialty': _specialtyController.text});
          }
        }, child: const Text('Add')),
      ],
    );
  }
}

// Student Addition Dialog
class _AddStudentDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  const _AddStudentDialog({required this.onAdd});

  @override
  State<_AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<_AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Student'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context);
            widget.onAdd({'name': _nameController.text, 'email': _emailController.text});
          }
        }, child: const Text('Add')),
      ],
    );
  }
}
