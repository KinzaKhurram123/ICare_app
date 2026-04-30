import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

/// Lab test template screen — similar to PrescriptionTemplatesScreen
/// Doctor can create/manage lab test templates and suggest them during consultation.
class LabTestTemplateScreen extends StatefulWidget {
  /// If provided, the screen shows a "Select" button instead of just viewing.
  final bool selectionMode;
  final Function(Map<String, dynamic>)? onTemplateSelected;

  const LabTestTemplateScreen({
    super.key,
    this.selectionMode = false,
    this.onTemplateSelected,
  });

  @override
  State<LabTestTemplateScreen> createState() => _LabTestTemplateScreenState();
}

class _LabTestTemplateScreenState extends State<LabTestTemplateScreen> {
  bool _isLoading = false;

  // Local templates list (persisted in memory for this session)
  // In production this would come from a backend service.
  static final List<Map<String, dynamic>> _templates = [
    {
      'id': 'default_1',
      'name': 'Basic Blood Panel',
      'tests': [
        {'name': 'Complete Blood Count (CBC)', 'notes': ''},
        {'name': 'Blood Glucose (Fasting)', 'notes': ''},
        {'name': 'Lipid Profile', 'notes': ''},
      ],
    },
    {
      'id': 'default_2',
      'name': 'Liver Function Tests',
      'tests': [
        {'name': 'ALT (SGPT)', 'notes': ''},
        {'name': 'AST (SGOT)', 'notes': ''},
        {'name': 'Bilirubin Total', 'notes': ''},
        {'name': 'Alkaline Phosphatase', 'notes': ''},
      ],
    },
    {
      'id': 'default_3',
      'name': 'Kidney Function Tests',
      'tests': [
        {'name': 'Serum Creatinine', 'notes': ''},
        {'name': 'Blood Urea Nitrogen (BUN)', 'notes': ''},
        {'name': 'Uric Acid', 'notes': ''},
        {'name': 'Urine Complete Examination', 'notes': ''},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          widget.selectionMode ? 'Select Lab Test Template' : 'Lab Test Templates',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      floatingActionButton: widget.selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddTemplateDialog,
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'New Template',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? _buildEmptyState()
              : _buildTemplatesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.biotech_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No lab test templates yet.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first template.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final template = _templates[index];
        final tests = (template['tests'] ?? []) as List<dynamic>;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      template['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (!widget.selectionMode)
                    IconButton(
                      onPressed: () => _confirmRemoveTemplate(index),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Tests list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tests
                    .map(
                      (test) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                test['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (widget.selectionMode)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onTemplateSelected?.call(template);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Select This Template'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditTemplateDialog(index),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTemplateDialog() {
    final nameController = TextEditingController();
    final testNameController = TextEditingController();
    final testNotesController = TextEditingController();
    List<Map<String, String>> currentTests = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'New Lab Test Template',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'e.g. Diabetes Monitoring Panel',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Add Tests',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: testNameController,
                  decoration: const InputDecoration(labelText: 'Test Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: testNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'e.g. Fasting required',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (testNameController.text.isNotEmpty) {
                      setDialogState(() {
                        currentTests.add({
                          'name': testNameController.text,
                          'notes': testNotesController.text,
                        });
                        testNameController.clear();
                        testNotesController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                  ),
                ),
                if (currentTests.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Tests added:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  ...currentTests.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${t['name']}${t['notes']!.isNotEmpty ? ' (${t['notes']})' : ''}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a template name')),
                  );
                  return;
                }
                if (currentTests.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add at least one test')),
                  );
                  return;
                }
                setState(() {
                  _templates.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text,
                    'tests': currentTests,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Template saved successfully'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Template'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTemplateDialog(int index) {
    final template = _templates[index];
    final nameController = TextEditingController(text: template['name']);
    final testNameController = TextEditingController();
    final testNotesController = TextEditingController();
    List<Map<String, String>> currentTests =
        List<Map<String, String>>.from(
          (template['tests'] as List).map((t) => Map<String, String>.from(t)),
        );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Template', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Template Name'),
                ),
                const SizedBox(height: 16),
                const Text('Tests:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                ...currentTests.asMap().entries.map(
                  (entry) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.biotech_rounded, size: 18, color: Color(0xFF8B5CF6)),
                    title: Text(entry.value['name'] ?? '', style: const TextStyle(fontSize: 13)),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                      onPressed: () => setDialogState(() => currentTests.removeAt(entry.key)),
                    ),
                  ),
                ),
                const Divider(),
                TextField(
                  controller: testNameController,
                  decoration: const InputDecoration(labelText: 'Add Test Name'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (testNameController.text.isNotEmpty) {
                      setDialogState(() {
                        currentTests.add({'name': testNameController.text, 'notes': testNotesController.text});
                        testNameController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _templates[index] = {
                    ..._templates[index],
                    'name': nameController.text,
                    'tests': currentTests,
                  };
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveTemplate(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${_templates[index]['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _templates.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
