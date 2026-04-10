import 'package:flutter/material.dart';
import 'package:icare/models/lab.dart';
import 'package:icare/screens/book_lab.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/screens/lab_reports_screen.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/lab_widget.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:icare/services/laboratory_service.dart';

class LabsListScreen extends StatefulWidget {
  const LabsListScreen({super.key});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> {
  final LaboratoryService _labService = LaboratoryService();
  final TextEditingController _searchController = TextEditingController();
  List<Lab> _labs = [];
  List<Lab> _filteredLabs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLabs();
  }

  Future<void> _fetchLabs() async {
    try {
      final labsData = await _labService.getAllLaboratories();
      final List<Lab> loadedLabs = labsData.map((json) {
        return Lab(
          id: json['_id'] ?? '',
          title: json['labName'] ?? json['name'] ?? 'Laboratory',
          photo: json['image'] ?? ImagePaths.lab1,
          delivery: json['homeSample'] == true
              ? "Home Sample Available"
              : "Walk-in Only",
          address:
              json['address'] ?? json['location'] ?? 'Location not available',
          rating: (json['rating'] ?? 4.5).toString(),
          tests:
              (json['availableTests'] as List?)
                  ?.map((t) => t['name'].toString())
                  .toList() ??
              [],
        );
      }).toList();

      if (mounted) {
        setState(() {
          _labs = loadedLabs;
          _filteredLabs = loadedLabs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching labs: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterLabs(String query) {
    if (query.isEmpty) {
      setState(() => _filteredLabs = _labs);
      return;
    }
    setState(() {
      _filteredLabs = _labs.where((lab) {
        final title = lab.title?.toLowerCase() ?? "";
        final address = lab.address?.toLowerCase() ?? "";
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || address.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          text: "Book a Lab",
          fontFamily: "Gilroy-Bold",
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0F172A),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 40 : 20,
                        vertical: 24,
                      ),
                      color: Colors.white,
                      child: Center(
                        child: CustomInputField(
                          width: isDesktop ? 700 : double.infinity,
                          hintText: "Search laboratories or clinics...",
                          controller: _searchController,
                          onChanged: _filterLabs,
                          trailingIcon: SvgWrapper(
                            assetPath: ImagePaths.filters,
                            onPress: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => const FiltersScreen(),
                                ),
                              );
                            },
                          ),
                          leadingIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF94A3B8),
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: _filteredLabs.isEmpty
                          ? _buildEmptyState()
                          : LabsList(labs: _filteredLabs, tab: 'book'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No laboratories found",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LabsList extends StatelessWidget {
  final List<Lab> labs;
  final String tab;
  const LabsList({super.key, required this.labs, this.tab = 'book'});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;
    final actionText = tab == 'book' ? 'Book a Lab' : 'View Reports';

    return GridView.builder(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      itemCount: labs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        mainAxisExtent: isDesktop ? 340 : 340,
        crossAxisSpacing: 30,
        mainAxisSpacing: 20,
      ),
      itemBuilder: (ctx, i) {
        return LabWidget(
          lab: labs[i],
          actionText: actionText,
          onActionBtnPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => tab == 'book'
                    ? BookLabScreen(labId: labs[i].id, labTitle: labs[i].title)
                    : const LabReportsScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
