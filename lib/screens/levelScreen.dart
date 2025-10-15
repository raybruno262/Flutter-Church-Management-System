import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/levelStatBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/addLevelScreen.dart';
import 'package:flutter_churchcrm_system/screens/updateLevelScreen.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';

import 'package:flutter_churchcrm_system/constants.dart';

class LevelScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const LevelScreen({super.key, required this.loggedInUser});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  String _statusFilter = 'All Status'; // Options: All, Active, Inactive
  final _nameFilterController = TextEditingController();
  final _addressFilterController = TextEditingController();

  final _parentFilterController = TextEditingController();
  String _typeFilter = 'All Types';
  final LevelController _controller = LevelController();

  int _currentPage = 0;
  final int _pageSize = 5;
  List<Level> _levels = [];
  List<Level> _allLevels = [];
  List<Level> _filteredLevels = [];

  @override
  void initState() {
    super.initState();
    _fetchLevels();

    _fetchLevelCounts();
  }

  bool _isLoading = true;
  bool _isFiltering = false;

  Future<void> _fetchLevels() async {
    setState(() => _isLoading = true);
    final levels = await _controller.getPaginatedLevels(
      page: _currentPage,
      size: _pageSize,
    );
    setState(() {
      _levels = levels;
      _filteredLevels = _levels;

      _isLoading = false;
    });
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();
    final addressQuery = _addressFilterController.text.toLowerCase();
    final parentQuery = _parentFilterController.text.toLowerCase();

    final filtered = _allLevels.where((level) {
      final matchesName =
          level.name?.toLowerCase().contains(nameQuery) ?? false;
      final matchesAddress =
          level.address?.toLowerCase().contains(addressQuery) ?? false;
      final matchesParent = parentQuery.isEmpty
          ? true
          : (level.parent?.name?.toLowerCase().contains(parentQuery) ?? false);

      final status = (level.isActive ?? false) ? 'Active' : 'Inactive';
      final matchesStatus =
          _statusFilter == 'All Status' || status == _statusFilter;

      final matchesType =
          _typeFilter == 'All Types' || level.levelType == _typeFilter;

      return matchesName &&
          matchesAddress &&
          matchesParent &&
          matchesStatus &&
          matchesType;
    }).toList();

    setState(() {
      _filteredLevels = filtered;
      _currentPage = 0;
    });
  }

  Future<void> _fetchAllLevels() async {
    final allLevels = await _controller.getAllLevels();
    setState(() {
      _allLevels = allLevels;
      _isLoading = false;
    });
  }

  // Detect filter changes and switch mode
  void _onFilterChanged() async {
    final isDefaultFilter =
        _nameFilterController.text.isEmpty &&
        _addressFilterController.text.isEmpty &&
        _parentFilterController.text.isEmpty &&
        _statusFilter == 'All Status' &&
        _typeFilter == 'All Types';

    if (isDefaultFilter) {
      _isFiltering = false;
      _currentPage = 0;
      await _fetchLevels();
    } else {
      _isFiltering = true;
      await _fetchAllLevels();
      _applySearchFilter();
    }
  }

  Future<void> _nextPage() async {
    if (_isFiltering) {
      if ((_currentPage + 1) * _pageSize < _filteredLevels.length) {
        setState(() => _currentPage++);
      }
    } else {
      _currentPage++;
      await _fetchLevels();
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      if (_isFiltering) {
        setState(() => _currentPage--);
      } else {
        _currentPage--;
        await _fetchLevels();
      }
    }
  }

  List<Level> get displayedLevels {
    if (_isFiltering) {
      if (_filteredLevels.isEmpty) return [];
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      return _filteredLevels.sublist(
        start,
        end > _filteredLevels.length ? _filteredLevels.length : end,
      );
    } else {
      return _levels;
    }
  }

  Map<String, Map<String, int>> _levelCounts = {
    'regions': {'total': 0, 'active': 0, 'inactive': 0},
    'parishes': {'total': 0, 'active': 0, 'inactive': 0},
    'chapels': {'total': 0, 'active': 0, 'inactive': 0},
    'cells': {'total': 0, 'active': 0, 'inactive': 0},
  };
  Future<void> _fetchLevelCounts() async {
    final rawCounts = await _controller.getLevelCounts();

    setState(() {
      _levelCounts = {
        'regions': {
          'total': rawCounts['regions']?['total'] ?? 0,
          'active': rawCounts['regions']?['active'] ?? 0,
          'inactive': rawCounts['regions']?['inactive'] ?? 0,
        },
        'parishes': {
          'total': rawCounts['parishes']?['total'] ?? 0,
          'active': rawCounts['parishes']?['active'] ?? 0,
          'inactive': rawCounts['parishes']?['inactive'] ?? 0,
        },
        'chapels': {
          'total': rawCounts['chapels']?['total'] ?? 0,
          'active': rawCounts['chapels']?['active'] ?? 0,
          'inactive': rawCounts['chapels']?['inactive'] ?? 0,
        },
        'cells': {
          'total': rawCounts['cells']?['total'] ?? 0,
          'active': rawCounts['cells']?['active'] ?? 0,
          'inactive': rawCounts['cells']?['inactive'] ?? 0,
        },
      };
    });
  }

  DataRow _buildDataRow(Level level) {
    return DataRow(
      cells: [
        DataCell(Text(level.name ?? '', style: GoogleFonts.inter())),
        DataCell(Text(level.address ?? '', style: GoogleFonts.inter())),
        DataCell(Text(level.levelType ?? '', style: GoogleFonts.inter())),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (level.isActive ?? false)
                  ? Colors.green.shade100
                  : Colors.red.shade100,
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
                    color: (level.isActive ?? false)
                        ? Colors.green
                        : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  (level.isActive ?? false) ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (level.isActive ?? false)
                        ? Colors.green.shade800
                        : Colors.red.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),

        DataCell(Text(level.parent?.name ?? 'N/A', style: GoogleFonts.inter())),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),

                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateLevelScreen(
                        loggedInUser: widget.loggedInUser,
                        level: level,
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _currentPage = 0;
                    });

                    await _fetchLevels();
                    await _fetchLevelCounts();
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
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? Container(
              width: 250,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SideMenuWidget(
                selectedTitle: 'Levels',
                loggedInUser: widget.loggedInUser,
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: borderColor, width: 2),
                    ),
                  ),
                  child: SideMenuWidget(
                    selectedTitle: 'Levels',
                    loggedInUser: widget.loggedInUser,
                  ),
                ),
              ),
            Expanded(flex: 10, child: _buildLevelScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelScreen() {
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
                      "Manage Levels",
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
                          LevelStatBox(
                            iconPath: 'assets/icons/region.svg',
                            label: 'Regions',
                            totalCount: _levelCounts['regions']!['total']!,
                            activeCount: _levelCounts['regions']!['active']!,
                            inactiveCount:
                                _levelCounts['regions']!['inactive']!,
                            backgroundColor: statboxColor,
                          ),
                          LevelStatBox(
                            iconPath: 'assets/icons/parish.svg',
                            label: 'Parishes',
                            totalCount: _levelCounts['parishes']!['total']!,
                            activeCount: _levelCounts['parishes']!['active']!,
                            inactiveCount:
                                _levelCounts['parishes']!['inactive']!,
                            backgroundColor: statboxColor,
                          ),
                          LevelStatBox(
                            iconPath: 'assets/icons/chapel.svg',
                            label: 'Chapels',
                            totalCount: _levelCounts['chapels']!['total']!,
                            activeCount: _levelCounts['chapels']!['active']!,
                            inactiveCount:
                                _levelCounts['chapels']!['inactive']!,
                            backgroundColor: statboxColor,
                          ),
                          LevelStatBox(
                            iconPath: 'assets/icons/cell.svg',
                            label: 'Cells',
                            totalCount: _levelCounts['cells']!['total']!,
                            activeCount: _levelCounts['cells']!['active']!,
                            inactiveCount: _levelCounts['cells']!['inactive']!,
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
                        SizedBox(width: 460),
                        Text(
                          "Levels List",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 280),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddLevelScreen(
                                  loggedInUser: widget.loggedInUser,
                                ),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                _currentPage = 0;
                              });

                              await _fetchLevels();
                              await _fetchLevelCounts();
                            }
                          },
                          icon: SvgPicture.asset("assets/icons/level.svg"),
                          label: Text(
                            'Add Level',
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
                    ),
                  ),

                  const SizedBox(height: 10),

                  _isLoading
                      ? Container(
                          height: 300,

                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
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
                                        _addressFilterController,
                                        'Search Address',
                                      ),
                                      const SizedBox(width: 8),
                                      _buildTypeDropdown(),

                                      const SizedBox(width: 8),
                                      _buildStatusDropdown(),

                                      const SizedBox(width: 8),
                                      _buildFilterField(
                                        _parentFilterController,
                                        'Search Parent Name',
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
                                        width: 1030,
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
                                                'Address',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Type',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'STATUS',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Parent Name',
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
                                          rows: displayedLevels.isEmpty
                                              ? [
                                                  DataRow(
                                                    cells: List.generate(
                                                      6,
                                                      (_) => const DataCell(
                                                        SizedBox(),
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                              : displayedLevels
                                                    .map(_buildDataRow)
                                                    .toList(),
                                        ),
                                      ),
                                    ),
                                    if (displayedLevels.isEmpty)
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
                                              'No levels found',
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _previousPage,
                                      icon: Icon(Icons.arrow_back),
                                      label: Text('Previous'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                      icon: Icon(Icons.arrow_forward),
                                      label: Text('Next'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterField(TextEditingController controller, String hint) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 200,
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: (_) => _onFilterChanged(),
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
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return SizedBox(
      width: 200,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _typeFilter,
        onChanged: (value) {
          setState(() {
            _typeFilter = value!;
            _onFilterChanged();
          });
        },
        items:
            [
              'All Types',
              'HEADQUARTER',
              'REGION',
              'PARISH',
              'CHAPEL',
              'CELL',
            ].map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                ),
              );
            }).toList(),
        selectedItemBuilder: (context) {
          return [
            'All Types',
            'HEADQUARTER',
            'REGION',
            'PARISH',
            'CHAPEL',
            'CELL',
          ].map((status) {
            return Text(
              status,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
            );
          }).toList();
        },
        dropdownColor: backgroundcolor,
        decoration: InputDecoration(
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

  Widget _buildStatusDropdown() {
    return SizedBox(
      width: 200,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _statusFilter,
        onChanged: (value) {
          setState(() {
            _statusFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Status', 'Active', 'Inactive'].map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(
              status,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Status', 'Active', 'Inactive'].map((status) {
            return Text(
              status,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
            );
          }).toList();
        },
        dropdownColor: backgroundcolor,
        decoration: InputDecoration(
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
