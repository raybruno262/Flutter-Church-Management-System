// screens/equipment_category_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/provider/addEquipmentCategory_provider.dart';

import 'package:flutter_churchcrm_system/provider/equipmentCategory_provider.dart';
import 'package:flutter_churchcrm_system/provider/updateEquipmentCategory_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/addEquipmentCategory.dart';
import 'package:flutter_churchcrm_system/screens/updateEquipmentCategoryScreen.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class EquipmentCategoryScreen extends ConsumerStatefulWidget {
  final UserModel loggedInUser;

  const EquipmentCategoryScreen({super.key, required this.loggedInUser});

  @override
  ConsumerState<EquipmentCategoryScreen> createState() =>
      _EquipmentCategoryScreenState();
}

class _EquipmentCategoryScreenState
    extends ConsumerState<EquipmentCategoryScreen> {
  final _nameFilterController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _nameFilterController.addListener(_onFilterChanged);
  }

  void _onFilterChanged() {
    final nameQuery = _nameFilterController.text;

    // INSTANT response - no loading state
    ref.read(equipmentCategoryProvider.notifier).updateSearchQuery(nameQuery);

    // Only fetch from API after user stops typing (debounce)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (nameQuery.isNotEmpty) {
        ref
            .read(equipmentCategoryProvider.notifier)
            .handleFilterChange(nameQuery);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameFilterController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  DataRow _buildDataRow(EquipmentCategory equipmentCategory) {
    return DataRow(
      cells: [
        DataCell(Text(equipmentCategory.name, style: GoogleFonts.inter())),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  // Reset the update provider state before navigating
                  ref
                      .read(updateEquipmentCategoryProvider.notifier)
                      .resetState();

                  // Navigate to update screen 
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateEquipmentCategoryScreen(
                        loggedInUser: widget.loggedInUser,
                        equipmentCategory: equipmentCategory,
                      ),
                    ),
                  );

                  if (result == 'refresh') {
                    // Force refresh the main data
                    ref.read(equipmentCategoryProvider.notifier).forceRefresh();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipmentCategoryProvider);
    final notifier = ref.read(equipmentCategoryProvider.notifier);
    final isDesktop = Responsive.isDesktop(context);

    // This will force the UI to rebuild when refreshTrigger changes
    // ignore: unused_local_variable
    final refreshTrigger = state.refreshTrigger;

    return Scaffold(
      drawer: !isDesktop
          ? Drawer(
              child: SideMenuWidget(
                selectedTitle: 'Equipment',
                loggedInUser: widget.loggedInUser,
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              Container(
                width: 250,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: borderColor, width: 2),
                  ),
                ),
                child: SideMenuWidget(
                  selectedTitle: 'Equipment',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildEquipmentCategoryScreen(state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentCategoryScreen(
    EquipmentCategoryState state,
    EquipmentCategoryNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const TopHeaderWidget(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Manage Equipment Category",
                      style: GoogleFonts.inter(
                        color: titlepageColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Back Button - ALWAYS WORKING
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(
                      'Back',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: containerColor,
                      ),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          StatBox(
                            iconPath: 'assets/icons/equipstat.svg',
                            label: 'Total Equipment Categories',
                            count: state.equipmentCategoryCount.toString(),
                            backgroundColor: statboxColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Header with Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        const SizedBox(width: 400),
                        Text(
                          "Equipment Category List",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // ADD BUTTON 
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Reset the add provider state before navigating
                            ref
                                .read(addEquipmentCategoryProvider.notifier)
                                .resetState();

                            // Navigate to add screen - THIS WILL NOW WORK
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEquipmentCategoryScreen(
                                      loggedInUser: widget.loggedInUser,
                                    ),
                              ),
                            );

                            if (result == 'refresh') {
                              // Force refresh the main data
                              ref
                                  .read(equipmentCategoryProvider.notifier)
                                  .forceRefresh();
                            }
                          },
                          icon: SvgPicture.asset("assets/icons/equipment.svg"),
                          label: Text(
                            'Add Equipment Category',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Data Table Section
                  Center(
                    child: Container(
                      width: 520,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _horizontalScrollController,
                          child: Column(
                            children: [
                              // Filter Row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _buildFilterField(
                                      _nameFilterController,
                                      'Search Name',
                                    ),
                                    const SizedBox(width: 8),
                                    // Clear Filter Button
                                    ElevatedButton(
                                      onPressed: () {
                                        _nameFilterController.clear();
                                        notifier.clearFilters();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                      ),
                                      child: const Text('Clear Filter'),
                                    ),
                                  ],
                                ),
                              ),

                              // Data Table - This will rebuild when refreshTrigger changes
                              Stack(
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 300,
                                    ),
                                    child: SizedBox(
                                      width: 495,
                                      child: DataTable(
                                        horizontalMargin: 12,
                                        dataRowMaxHeight: 56,
                                        headingRowHeight: 48,
                                        dividerThickness: 1,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                              Colors.deepPurple,
                                            ),
                                        dataRowColor: WidgetStateProperty.all(
                                          backgroundcolor,
                                        ),
                                        border: TableBorder(
                                          horizontalInside: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          verticalInside: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          top: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          left: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          right: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        columns: [
                                          DataColumn(
                                            label: Text(
                                              'Name',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Actions',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows:
                                            notifier
                                                .displayedEquipmentCategories
                                                .isEmpty
                                            ? [
                                                DataRow(
                                                  cells: List.generate(
                                                    2,
                                                    (_) => const DataCell(
                                                      SizedBox(),
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            : notifier
                                                  .displayedEquipmentCategories
                                                  .map(_buildDataRow)
                                                  .toList(),
                                      ),
                                    ),
                                  ),
                                  if (notifier
                                      .displayedEquipmentCategories
                                      .isEmpty)
                                    Positioned(
                                      left: 126,
                                      top: 120,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'No Equipment Categories found',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Pagination Controls
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => notifier.previousPage(),
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('Previous'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Page ${state.currentPage + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => notifier.nextPage(),
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('Next'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 36),
                                  // Page size selector
                                  Container(
                                    height: 43,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade700,
                                          Colors.deepPurple.shade500,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButton<int>(
                                      value: state.pageSize,
                                      underline: const SizedBox(),
                                      dropdownColor: Colors.deepPurple.shade600,
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      items: _pageSizeOptions.map((size) {
                                        return DropdownMenuItem(
                                          value: size,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.table_rows,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '$size rows',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      selectedItemBuilder: (context) {
                                        return _pageSizeOptions.map((size) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.view_list,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '$size rows',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList();
                                      },
                                      onChanged: (value) {
                                        if (value != null) {
                                          notifier.changePageSize(value);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        '© 2025 All rights reserved. Church CRM System',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterField(TextEditingController controller, String hint) {
    return SizedBox(
      width: 222,
      height: 40,
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
