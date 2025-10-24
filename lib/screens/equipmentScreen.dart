import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/equipmentStatBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/equipment_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/addEquipmentScreen.dart';
import 'package:flutter_churchcrm_system/screens/updateEquipmentScreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_churchcrm_system/provider/equipment_provider.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  final UserModel loggedInUser;
  const EquipmentScreen({super.key, required this.loggedInUser});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  final _nameFilterController = TextEditingController();
  final _categoryFilterController = TextEditingController();
  final _purchaseDateFilterController = TextEditingController();
  final _purchasePriceFilterController = TextEditingController();
  String _conditionFilter = 'All Conditions';
  final _locationFilterController = TextEditingController();
  final _descriptionFilterController = TextEditingController();
  final _levelFilterController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _nameFilterController.addListener(_onFilterChanged);
    _categoryFilterController.addListener(_onFilterChanged);
    _purchaseDateFilterController.addListener(_onFilterChanged);
    _purchasePriceFilterController.addListener(_onFilterChanged);
    _locationFilterController.addListener(_onFilterChanged);
    _descriptionFilterController.addListener(_onFilterChanged);
    _levelFilterController.addListener(_onFilterChanged);
  }

  void _onFilterChanged() {
    final filters = _getCurrentFilters();

    // INSTANT response - no loading state
    ref
        .read(equipmentProvider(widget.loggedInUser.userId!).notifier)
        .updateSearchQuery(filters);

    // Only fetch from API after user stops typing (debounce)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (filters.values.any((value) => value.isNotEmpty) ||
          _conditionFilter != 'All Conditions') {
        ref
            .read(equipmentProvider(widget.loggedInUser.userId!).notifier)
            .handleFilterChange(filters);
      }
    });
  }

  Map<String, String> _getCurrentFilters() {
    return {
      'name': _nameFilterController.text,
      'category': _categoryFilterController.text,
      'purchaseDate': _purchaseDateFilterController.text,
      'purchasePrice': _purchasePriceFilterController.text,
      'location': _locationFilterController.text,
      'description': _descriptionFilterController.text,
      'level': _levelFilterController.text,
      'condition': _conditionFilter,
    };
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameFilterController.dispose();
    _categoryFilterController.dispose();
    _purchaseDateFilterController.dispose();
    _purchasePriceFilterController.dispose();
    _locationFilterController.dispose();
    _descriptionFilterController.dispose();
    _levelFilterController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  DataRow _buildDataRow(Equipment equipment) {
    final notifier = ref.read(
      equipmentProvider(widget.loggedInUser.userId!).notifier,
    );

    return DataRow(
      cells: [
        DataCell(Text(equipment.name, style: GoogleFonts.inter())),
        DataCell(
          Text(equipment.equipmentCategory.name, style: GoogleFonts.inter()),
        ),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Tooltip(
              message: _formatNumberWithCommas(equipment.purchasePrice),
              child: Text(
                _formatNumberForDisplay(equipment.purchasePrice),
                style: GoogleFonts.inter(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
        DataCell(Text(equipment.purchaseDate, style: GoogleFonts.inter())),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: notifier.getConditionBackgroundColor(equipment.condition),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: notifier.getConditionDotColor(equipment.condition),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  equipment.condition,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: notifier.getConditionTextColor(equipment.condition),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(Text(equipment.location!, style: GoogleFonts.inter())),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 300, minWidth: 150),
            child: Tooltip(
              message: equipment.description ?? 'No description',
              child: Text(
                equipment.description ?? 'No description',
                style: GoogleFonts.inter(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Text(equipment.level?.name ?? 'N/A', style: GoogleFonts.inter()),
        ),
        DataCell(
          Row(
            children: [
              if (widget.loggedInUser.role == 'CellAdmin' ||
                  widget.loggedInUser.role == 'SuperAdmin') ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Update Equipment',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateEquipmentScreen(
                          loggedInUser: widget.loggedInUser,
                          equipment: equipment,
                        ),
                      ),
                    );

                    if (result == 'refresh') {
                      // Force refresh the main data
                      ref
                          .read(
                            equipmentProvider(
                              widget.loggedInUser.userId!,
                            ).notifier,
                          )
                          .forceRefresh();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipmentProvider(widget.loggedInUser.userId!));
    final notifier = ref.read(
      equipmentProvider(widget.loggedInUser.userId!).notifier,
    );
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
                child: _buildEquipmentScreen(state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentScreen(
    EquipmentState state,
    EquipmentNotifier notifier,
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
                      "Manage Equipment",
                      style: GoogleFonts.inter(
                        color: titlepageColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                          EquipmentStatBox(
                            iconPath: 'assets/icons/equipment.svg',
                            label: 'Total Equipment',
                            count: state.equipmentStats['totalEquipment']
                                .toString(),
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Excellent Condition',
                            count: state.equipmentStats['excellentCount']
                                .toString(),
                            iconPath: 'assets/icons/excellent.svg',
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Good   Condition',
                            count: state.equipmentStats['goodCount'].toString(),
                            iconPath: 'assets/icons/good.svg',
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Needs Attention',
                            count: state.equipmentStats['needsRepairCount']
                                .toString(),
                            iconPath: 'assets/icons/attention.svg',
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Recent Maintenance',
                            count: state.equipmentStats['outOfServiceCount']
                                .toString(),
                            iconPath: 'assets/icons/maintenance.svg',
                            backgroundColor: statboxColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header with Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 460),
                        Text(
                          "Equipment List",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 240),
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin') ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEquipmentScreen(
                                    loggedInUser: widget.loggedInUser,
                                  ),
                                ),
                              );

                              if (result == 'refresh') {
                                // Force refresh the main data
                                notifier.forceRefresh();
                              }
                            },
                            icon: SvgPicture.asset(
                              "assets/icons/equipment.svg",
                            ),
                            label: Text(
                              'Add Equipment',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
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
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Data Table Section
                  state.isLoading
                      ? Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      : Container(
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
                                      children: [
                                        _buildFilterField(
                                          _nameFilterController,
                                          'Search Name',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _categoryFilterController,
                                          'Search Category',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _purchasePriceFilterController,
                                          'Search Price',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _purchaseDateFilterController,
                                          'Search Date(MM/dd/yyyy)',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildConditionDropdown(notifier),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _locationFilterController,
                                          'Search Location',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _descriptionFilterController,
                                          'Search Description',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _levelFilterController,
                                          'Search Level Name',
                                        ),
                                        const SizedBox(width: 8),
                                        // Clear Filter Button
                                        ElevatedButton(
                                          onPressed: () {
                                            _nameFilterController.clear();
                                            _categoryFilterController.clear();
                                            _purchaseDateFilterController
                                                .clear();
                                            _purchasePriceFilterController
                                                .clear();
                                            _locationFilterController.clear();
                                            _descriptionFilterController
                                                .clear();
                                            _levelFilterController.clear();
                                            setState(() {
                                              _conditionFilter =
                                                  'All Conditions';
                                            });
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

                                  // Data Table
                                  Stack(
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 300,
                                        ),
                                        child: SizedBox(
                                          width: 1800,
                                          child: DataTable(
                                            horizontalMargin: 12,
                                            dataRowMaxHeight: 56,
                                            headingRowHeight: 48,
                                            dividerThickness: 1,
                                            headingRowColor:
                                                WidgetStateProperty.all(
                                                  Colors.deepPurple,
                                                ),
                                            dataRowColor:
                                                WidgetStateProperty.all(
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
                                                  'Equipment Category',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Price',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Purchase Date',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Condition',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Location',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Container(
                                                  width: 300,
                                                  child: Text(
                                                    'Description',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Level Name',
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
                                                    .displayedEquipment
                                                    .isEmpty
                                                ? [
                                                    DataRow(
                                                      cells: List.generate(
                                                        9,
                                                        (_) => const DataCell(
                                                          SizedBox(),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                : notifier.displayedEquipment
                                                      .map(_buildDataRow)
                                                      .toList(),
                                          ),
                                        ),
                                      ),
                                      if (notifier.displayedEquipment.isEmpty)
                                        Positioned(
                                          left: 426,
                                          top: 120,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.search_off,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'No Equipment found',
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
                                  const SizedBox(height: 10),

                                  // Pagination Controls
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              notifier.previousPage(),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: DropdownButton<int>(
                                            value: state.pageSize,
                                            underline: const SizedBox(),
                                            dropdownColor:
                                                Colors.deepPurple.shade600,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            selectedItemBuilder: (context) {
                                              return _pageSizeOptions.map((
                                                size,
                                              ) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                      ],
                                    ),
                                  ),
                                ],
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

  Widget _buildConditionDropdown(EquipmentNotifier notifier) {
    return SizedBox(
      width: 210,
      height: 40,
      child: DropdownButtonFormField<String>(
        value: _conditionFilter,
        onChanged: (value) {
          setState(() {
            _conditionFilter = value!;
            _onFilterChanged();
          });
        },
        items:
            [
              'All Conditions',
              'Excellent',
              'Good',
              'Needs Repair',
              'Out of Service',
            ].map((condition) {
              return DropdownMenuItem(
                value: condition,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: notifier.getConditionDotColor(condition),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      condition,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        selectedItemBuilder: (context) {
          return [
            'All Conditions',
            'Excellent',
            'Good',
            'Needs Repair',
            'Out of Service',
          ].map((condition) {
            return Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: notifier.getConditionDotColor(condition),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  condition,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: notifier.getConditionTextColor(condition),
                  ),
                ),
              ],
            );
          }).toList();
        },
        dropdownColor: backgroundcolor,
        decoration: InputDecoration(
          filled: true,
          fillColor: notifier.getConditionBackgroundColor(_conditionFilter),
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

  Widget _buildFilterField(TextEditingController controller, String hint) {
    return SizedBox(
      width: 220,
      height: 40,
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
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

  String _formatNumberForDisplay(double value) {
    final formatted = _formatNumberWithCommas(value);
    return formatted;
  }

  String _formatNumberWithCommas(double value) {
    if (value % 1 == 0) {
      return NumberFormat('#,##0').format(value);
    } else {
      return NumberFormat('#,##0.00').format(value);
    }
  }
}
