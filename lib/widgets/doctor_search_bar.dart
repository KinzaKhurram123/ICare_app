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
    return Container(
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
    );
  }
}

