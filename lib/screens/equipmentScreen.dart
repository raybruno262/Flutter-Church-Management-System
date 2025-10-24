import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/equipmentStatBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/financeStatBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/controller/equipmentCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/equipment_controller.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/equipment_model.dart';

import 'package:flutter_churchcrm_system/screens/addEquipmentScreen.dart';
import 'package:flutter_churchcrm_system/screens/updateEquipmentScreen.dart';

import 'package:intl/intl.dart';
import 'package:flutter_churchcrm_system/controller/finance_Controller.dart';
import 'package:flutter_churchcrm_system/controller/incomeCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';

import 'package:flutter_churchcrm_system/model/finance_model.dart';
import 'package:flutter_churchcrm_system/model/incomeCategory_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';

class EquipmentScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const EquipmentScreen({super.key, required this.loggedInUser});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final _nameFilterController = TextEditingController();
  final _categoryFilterController = TextEditingController();
  final _purchaseDateFilterController = TextEditingController();
  final _purchasePriceFilterController = TextEditingController();
  String _conditionFilter =
      'All Conditions'; // Excellent, good, needs repair, Out of Service
  final _locationFilterController = TextEditingController();
  final _descriptionFilterController = TextEditingController();
  final _levelFilterController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final EquipmentController _controller = EquipmentController();
  final UserController _usercontroller = UserController();

  // ignore: unused_field
  List<EquipmentCategory> _equipmentCategories = [];
  final EquipmentCategoryController _equipmentCategoriesController =
      EquipmentCategoryController();

  EquipmentCategory? _selectedEquipmentCategory;

  Future<void> _loadEquipmentCategories() async {
    final equipmentCategories = await _equipmentCategoriesController
        .getAllEquipmentCategories();
    if (mounted) {
      setState(() => _equipmentCategories = equipmentCategories);
    }
  }

  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  List<Equipment> _equipment = [];
  List<Equipment> _allEquipment = [];
  List<Equipment> _filteredEquipment = [];

  bool _isLoading = true;

  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _fetchEquipment();
    _fetchAllEquipment();
    _fetchEquipmentStats();
    _loadEquipmentCategories();
  }

  Future<void> _fetchEquipment() async {
    setState(() => _isLoading = true);
    try {
      final equipment = await _controller.getScopedPaginatedEquipment(
        userId: widget.loggedInUser.userId!,
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _equipment = equipment;
        _filteredEquipment = _equipment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllEquipment() async {
    try {
      final allFinance = await _controller.getAllEquipment();
      setState(() {
        _allEquipment = allFinance;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();
    final categoryQuery = _categoryFilterController.text.toLowerCase();
    final purchaseDateQuery = _purchaseDateFilterController.text;
    final purchasePriceQuery = _purchasePriceFilterController.text;
    final locationQuery = _locationFilterController.text.toLowerCase();
    final descriptionQuery = _descriptionFilterController.text.toLowerCase();

    final levelQuery = _levelFilterController.text.toLowerCase();

    final filtered = _allEquipment.where((finance) {
      final matchesName = finance.name.toLowerCase().contains(nameQuery);
      final matchesCategory =
          categoryQuery.isEmpty ||
          (finance.equipmentCategory.name.toLowerCase().contains(
            categoryQuery,
          ));
      final matchespurchaseDate =
          purchaseDateQuery.isEmpty ||
          (finance.purchaseDate.contains(purchaseDateQuery));
      final matchesLocation = finance.location?.toLowerCase().contains(
        locationQuery,
      );
      final matchesLevel =
          levelQuery.isEmpty ||
          (finance.level?.name?.toLowerCase().contains(levelQuery) ?? false);
      final matchesDescription = finance.description?.toLowerCase().contains(
        nameQuery,
      );
      final matchesPrice = finance.purchasePrice == purchasePriceQuery;

      final matchesCondition =
          _conditionFilter == 'All Conditions' ||
          finance.condition == _conditionFilter;

      return matchesName &&
          matchesCategory &&
          matchespurchaseDate &&
          matchesLocation! &&
          matchesLevel &&
          matchesPrice &&
          matchesDescription! &&
          matchesCondition;
    }).toList();
    setState(() {
      _filteredEquipment = filtered;
      _currentPage = 0;
    });
  }

  void _onFilterChanged() async {
    final isDefaultFilter =
        _nameFilterController.text.isEmpty &&
        _categoryFilterController.text.isEmpty &&
        _purchaseDateFilterController.text.isEmpty &&
        _purchasePriceFilterController.text.isEmpty &&
        _locationFilterController.text.isEmpty &&
        _conditionFilter == 'All Conditions' &&
        _descriptionFilterController.text.isEmpty &&
        _levelFilterController.text.isEmpty;

    if (isDefaultFilter) {
      _isFiltering = false;
      _currentPage = 0;
      await _fetchEquipment();
    } else {
      _isFiltering = true;
      await _fetchAllEquipment();
      _applySearchFilter();
    }
  }

  Future<void> _nextPage() async {
    if (_isFiltering) {
      if ((_currentPage + 1) * _pageSize < _filteredEquipment.length) {
        setState(() => _currentPage++);
      }
    } else {
      setState(() => _currentPage++);
      await _fetchEquipment();
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      if (_isFiltering) {
        setState(() {});
      } else {
        await _fetchEquipment();
      }
    }
  }

  List<Equipment> get displayedEquipment {
    if (_isFiltering) {
      if (_filteredEquipment.isEmpty) return [];
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      return _filteredEquipment.sublist(
        start,
        end > _filteredEquipment.length ? _filteredEquipment.length : end,
      );
    } else {
      return _equipment;
    }
  }

  Map<String, dynamic> _equipmentStats = {
    'totalEquipment': 0,
    'excellentCount': 0,
    'goodCount': 0,
    'needsRepairCount': 0,
    'outOfServiceCount': 0,
  };

  Future<void> _fetchEquipmentStats() async {
    try {
      final loggedInUser = await _usercontroller.loadUserFromStorage();

      if (loggedInUser == null || loggedInUser.userId == null) {
        setState(() {
          _equipmentStats = {
            'totalEquipment': 0,
            'excellentCount': 0,
            'goodCount': 0,
            'needsRepairCount': 0,
            'outOfServiceCount': 0,
          };
        });
        return;
      }

      final stats = await _controller.getEquipmentStats(loggedInUser.userId!);

      final updatedStats = {
        'totalEquipment': stats['totalEquipment'] ?? 0,
        'excellentCount': stats['excellentCount'] ?? 0,
        'goodCount': stats['goodCount'] ?? 0,
        'needsRepairCount': stats['needsRepairCount'] ?? 0,
        'outOfServiceCount': stats['outOfServiceCount'] ?? 0,
      };

      setState(() {
        _equipmentStats = updatedStats;
      });
    } catch (e) {
      setState(() {
        _equipmentStats = {
          'totalEquipment': 0,
          'excellentCount': 0,
          'goodCount': 0,
          'needsRepairCount': 0,
          'outOfServiceCount': 0,
        };
      });
    }
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

  // For StatBox widgets
  TextStyle _getCountTextStyle(double value) {
    final formatted = _formatNumberWithCommas(value);

    if (formatted.length > 12) {
      return GoogleFonts.inter(
        fontSize: 14, // Smaller font for very large numbers
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
    } else if (formatted.length > 10) {
      return GoogleFonts.inter(
        fontSize: 15, // Medium font for large numbers
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
    } else {
      return GoogleFonts.inter(
        fontSize: 17, // Normal font
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
    }
  }

  DataRow _buildDataRow(Equipment equipment) {
    return DataRow(
      cells: [
        DataCell(Text(equipment.name, style: GoogleFonts.inter())),
        DataCell(
          Text(equipment.equipmentCategory.name, style: GoogleFonts.inter()),
        ),
        DataCell(
          Container(
            constraints: BoxConstraints(maxWidth: 110),
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
              color: _getConditionBackgroundColor(equipment.condition),
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
                    color: _getConditionDotColor(equipment.condition),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  equipment.condition,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getConditionTextColor(equipment.condition),
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
                    final updatedEquipment = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateEquipmentScreen(
                          loggedInUser: widget.loggedInUser,
                          equipment: equipment,
                        ),
                      ),
                    );

                    if (updatedEquipment != null &&
                        updatedEquipment is Equipment) {
                      setState(() {
                        final index = _equipment.indexWhere(
                          (m) => m.equipmentId == updatedEquipment.equipmentId,
                        );
                        if (index != -1) {
                          _equipment[index] = updatedEquipment;
                        }

                        final filteredIndex = _filteredEquipment.indexWhere(
                          (m) => m.equipmentId == updatedEquipment.equipmentId,
                        );
                        if (filteredIndex != -1) {
                          _filteredEquipment[filteredIndex] = updatedEquipment;
                        }
                      });

                      await _fetchEquipmentStats();
                      await _fetchEquipment();
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
    final isDesktop = Responsive.isDesktop(context);

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
                child: _buildEquipmentScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentScreen() {
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
                            count: _equipmentStats['totalEquipment'].toString(),
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Excellent Condition',
                            count: _equipmentStats['excellentCount'].toString(),
                            iconPath: 'assets/icons/excellent.svg',
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Good    Condition',
                            count: _equipmentStats['goodCount'].toString(),
                            iconPath: 'assets/icons/good.svg',
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Needs Attention',
                            count: _equipmentStats['needsRepairCount']
                                .toString(),
                            iconPath: 'assets/icons/attention.svg',
                            backgroundColor: statboxColor,
                          ),
                          EquipmentStatBox(
                            label: 'Recent Maintenance',
                            count: _equipmentStats['outOfServiceCount']
                                .toString(),
                            iconPath: 'assets/icons/maintenance.svg',
                            backgroundColor: statboxColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                              final newEquipment = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEquipmentScreen(
                                    loggedInUser: widget.loggedInUser,
                                  ),
                                ),
                              );

                              if (newEquipment != null &&
                                  newEquipment is Equipment) {
                                await _fetchEquipment();
                                await _fetchAllEquipment();
                                await _fetchEquipmentStats();
                                setState(() {
                                  _currentPage = 0;
                                });
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

                  _isLoading
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
                                        _buildConditionDropdown(),

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
                                      ],
                                    ),
                                  ),

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
                                            rows: displayedEquipment.isEmpty
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
                                                : displayedEquipment
                                                      .map(_buildDataRow)
                                                      .toList(),
                                          ),
                                        ),
                                      ),
                                      if (displayedEquipment.isEmpty)
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
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _previousPage,
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
                                          'Page ${_currentPage + 1}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton.icon(
                                          onPressed: _nextPage,
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
                                            value: _pageSize,
                                            underline: const SizedBox(),
                                            dropdownColor:
                                                Colors.deepPurple.shade600,
                                            icon: Icon(
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
                                                    Icon(
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
                                                    Icon(
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
                                                setState(() {
                                                  _pageSize = value;
                                                  _currentPage = 0;
                                                });
                                                if (_isFiltering) {
                                                  _applySearchFilter();
                                                } else {
                                                  _fetchEquipment();
                                                }
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

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
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

  Widget _buildConditionDropdown() {
    return SizedBox(
      width: 210,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _conditionFilter,
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
                        color: _getConditionDotColor(condition),
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
                    color: _getConditionDotColor(condition),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  condition,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _getConditionTextColor(condition),
                  ),
                ),
              ],
            );
          }).toList();
        },
        dropdownColor: backgroundcolor,
        decoration: InputDecoration(
          filled: true,
          fillColor: _getConditionBackgroundColor(_conditionFilter),
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
      width: 220, // Increased width for better usability
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: (_) => _onFilterChanged(),
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

  // Color methods for conditions
  Color _getConditionBackgroundColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green.shade50;
      case 'Good':
        return Colors.blue.shade50;
      case 'Needs Repair':
        return Colors.orange.shade50;
      case 'Out of Service':
        return Colors.red.shade50;
      case 'All Conditions':
      default:
        return Colors.white;
    }
  }

  Color _getConditionDotColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Needs Repair':
        return Colors.orange;
      case 'Out of Service':
        return Colors.red;
      case 'All Conditions':
      default:
        return Colors.grey;
    }
  }

  Color _getConditionTextColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green.shade800;
      case 'Good':
        return Colors.blue.shade800;
      case 'Needs Repair':
        return Colors.orange.shade800;
      case 'Out of Service':
        return Colors.red.shade800;
      case 'All Conditions':
      default:
        return Colors.grey.shade800;
    }
  }
}
