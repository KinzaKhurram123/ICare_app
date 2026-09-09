import 'package:flutter/material.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/services/instructor_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/drag_scroll.dart';

/// Directory of every instructor, for students.
///
/// The instructor profile already collects a Professional Bio, qualification,
/// designation and experience, but nothing ever showed it to anyone — the
/// client's point: "yeh bio-data apne likhne ke liye thodi likhega, KISI KO
/// DIKHANE ke liye hai — STUDENT hi dekhega na!"
class InstructorsListScreen extends StatefulWidget {
  const InstructorsListScreen({super.key});

  @override
  State<InstructorsListScreen> createState() => _InstructorsListScreenState();
}

class _InstructorsListScreenState extends State<InstructorsListScreen> {
  final InstructorService _service = InstructorService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getAllInstructors();
      if (!mounted) return;
      setState(() {
        _all = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            // An instructor with no name at all is an incomplete account, not
            // someone a student can usefully look up.
            .where((e) => _name(e).isNotEmpty)
            .toList()
          ..sort((a, b) => _name(a).toLowerCase().compareTo(
                _name(b).toLowerCase(),
              ));
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load instructors. Please try again.';
        _loading = false;
      });
    }
  }

  static String _name(Map<String, dynamic> i) =>
      (i['name'] ?? i['username'] ?? '').toString().trim();

  static String _subtitle(Map<String, dynamic> i) {
    final designation = (i['designation'] ?? '').toString().trim();
    if (designation.isNotEmpty) return designation;
    final qualification = (i['qualification'] ?? '').toString().trim();
    return qualification.isNotEmpty ? qualification : 'Instructor';
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((i) {
      return _name(i).toLowerCase().contains(q) ||
          _subtitle(i).toLowerCase().contains(q) ||
          (i['bio'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Instructors',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(wide),
      ),
    );
  }

  Widget _buildBody(bool wide) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 44, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final items = _filtered;

    return DragScroll(
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search instructors',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'No instructors found.',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                else if (wide)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 480,
                      mainAxisExtent: 132,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _card(items[i]),
                  )
                else
                  ...items.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _card(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> i) {
    final name = _name(i);
    final bio = (i['bio'] ?? '').toString().trim();
    final experience = (i['experience'] ?? '').toString().trim();
    final photo =
        (i['profilePicture'] ?? i['profile_image'] ?? '').toString().trim();

    return InkWell(
      onTap: () => _showProfile(i),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(photo, name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(i),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (experience.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '$experience years experience',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String photo, String name) {
    final initials = name.isEmpty
        ? '?'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
    // buildProfileImageProvider, not NetworkImage: an uploaded avatar comes
    // back as a base64 data: URI, which NetworkImage cannot load.
    final img = buildProfileImageProvider(photo.isEmpty ? null : photo);
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
      backgroundImage: img,
      child: img != null
          ? null
          : Text(
              initials,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  void _showProfile(Map<String, dynamic> i) {
    final name = _name(i);
    final bio = (i['bio'] ?? '').toString().trim();
    final qualification = (i['qualification'] ?? '').toString().trim();
    final experience = (i['experience'] ?? '').toString().trim();
    final languages = (i['languages'] is List)
        ? (i['languages'] as List).join(', ')
        : '';
    final photo =
        (i['profilePicture'] ?? i['profile_image'] ?? '').toString().trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _avatar(photo, name),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            _subtitle(i),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (bio.isNotEmpty) _detail('About', bio),
                if (qualification.isNotEmpty)
                  _detail('Qualification', qualification),
                if (experience.isNotEmpty)
                  _detail('Experience', '$experience years'),
                if (languages.isNotEmpty) _detail('Languages', languages),
                if (bio.isEmpty &&
                    qualification.isEmpty &&
                    experience.isEmpty &&
                    languages.isEmpty)
                  const Text(
                    'This instructor has not added profile details yet.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}
