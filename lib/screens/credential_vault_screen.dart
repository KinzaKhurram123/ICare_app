import 'package:flutter/material.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';

class CredentialVaultScreen extends StatefulWidget {
  const CredentialVaultScreen({super.key});

  @override
  State<CredentialVaultScreen> createState() => _CredentialVaultScreenState();
}

class _CredentialVaultScreenState extends State<CredentialVaultScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _credentials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCredentials();
  }

  Future<void> _fetchCredentials() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/credentials/me');
      if (mounted) {
        setState(() {
          _credentials = response.data['credentials'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    String type = 'Medical License';
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upload Credential',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'DOCUMENT TYPE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: type,
                items:
                    [
                          'Medical License',
                          'Specialization Certificate',
                          'Indemnity Insurance',
                          'Other',
                        ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (v) => type = v!,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'DOCUMENT TITLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. PMC License 2024',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {}, // File Picker
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_rounded,
                          color: AppColors.primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to select PDF or Image',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Max file size: 10MB',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: isUploading
                      ? 'Uploading...'
                      : 'Submit for Verification',
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (titleController.text.isEmpty) return;
                          setModalState(() => isUploading = true);
                          try {
                            await _apiService.post('/credentials', {
                              'type': type,
                              'title': titleController.text,
                              'documentUrl': 'https://example.com/mock-doc.pdf',
                            });
                            Navigator.pop(ctx);
                            _fetchCredentials();
                          } catch (e) {
                            setModalState(() => isUploading = false);
                          }
                        },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Certificate',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchCredentials,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildVaultHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _credentials.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _credentials.length,
                    itemBuilder: (ctx, i) =>
                        _buildCredentialCard(_credentials[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        label: const Text(
          'Add Document',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildVaultHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Certificates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your medical licenses and certifications for platform verification.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildVaultStat('Total', '03', Colors.blue),
              const SizedBox(width: 12),
              _buildVaultStat('Verified', '02', Colors.green),
              const SizedBox(width: 12),
              _buildVaultStat('Pending', '01', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaultStat(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(
            count,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Vault is Empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your license to get verified and start',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const Text(
            'accepting consultation requests.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(dynamic cred) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (cred['status']) {
      case 'verified':
        statusColor = Colors.green;
        statusText = 'VERIFIED';
        statusIcon = Icons.verified_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'REJECTED';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'expired':
        statusColor = Colors.orange;
        statusText = 'EXPIRED';
        statusIcon = Icons.warning_rounded;
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'UNDER REVIEW';
        statusIcon = Icons.history_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.file_present_rounded,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cred['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  cred['type'],
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: Color(0xFF64748B),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                ),
              ),
              const Text(
                'View',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
