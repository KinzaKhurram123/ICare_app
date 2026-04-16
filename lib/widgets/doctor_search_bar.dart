import 'package:flutter/material.dart';
import 'package:icare/screens/doctors_list.dart';

class DoctorSearchBar extends StatefulWidget {
  final bool isMobile;
  const DoctorSearchBar({super.key, required this.isMobile});

  @override
  State<DoctorSearchBar> createState() => _DoctorSearchBarState();
}

class _DoctorSearchBarState extends State<DoctorSearchBar> {
  String _searchMode = 'name';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.isMobile ? 46 : 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _searchMode,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: TextStyle(
                    fontSize: widget.isMobile ? 11 : 12,
                    color: const Color(0xFF0036BC),
                    fontWeight: FontWeight.w600,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Doctor Name')),
                    DropdownMenuItem(value: 'speciality', child: Text('Speciality')),
                    DropdownMenuItem(value: 'condition', child: Text('Condition')),
                  ],
                  onChanged: (value) => setState(() => _searchMode = value!),
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: _searchMode == 'name'
                        ? 'Search by doctor name...'
                        : _searchMode == 'speciality'
                            ? 'Search by speciality...'
                            : 'Search by condition...',
                    hintStyle: TextStyle(
                      fontSize: widget.isMobile ? 12 : 13,
                      color: Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: const Color(0xFF0036BC),
                      size: widget.isMobile ? 20 : 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: widget.isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.isMobile ? 10 : 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _SearchActionButton(
              label: 'Search All Doctors',
              icon: Icons.search_rounded,
              color: const Color(0xFF0036BC),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DoctorsList()),
              ),
            ),
            _SearchActionButton(
              label: 'Connect Now',
              icon: Icons.video_call_rounded,
              color: const Color(0xFF10B981),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DoctorsList()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SearchActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Gilroy-Bold',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
