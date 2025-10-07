import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/screens/addLevelScreen.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final LevelController _levelController = LevelController();
  int _currentPage = 0;
  final int _rowsPerPage = 5;
  bool _isLoading = true;
  List<Level> _levels = [];

  @override
  void initState() {
    super.initState();
    _fetchLevels();
  }

  Future<void> _fetchLevels() async {
    setState(() => _isLoading = true);
    final data = await _levelController.getPaginatedLevels(
      page: _currentPage,
      size: _rowsPerPage,
    );
    setState(() {
      _levels = data;
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? Container(
              width: 250,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const SideMenuWidget(selectedIndex: 1),
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
                  child: const SideMenuWidget(selectedIndex: 1),
                ),
              ),
            Expanded(flex: 10, child: _buildLevelScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const TopHeaderWidget(),

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

            // 🔷 Stat Boxes
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
                  children: const [
                    StatBox(
                      iconPath: 'assets/icons/region.svg',
                      label: 'Total Regions',
                      count: '400',
                      backgroundColor: statboxColor,
                    ),
                    StatBox(
                      label: 'Total Parishes',
                      count: '370',
                      iconPath: 'assets/icons/parish.svg',
                      backgroundColor: statboxColor,
                    ),
                    StatBox(
                      label: 'Total Chapels',
                      count: '200',
                      iconPath: 'assets/icons/chapel.svg',
                      backgroundColor: statboxColor,
                    ),
                    StatBox(
                      label: 'Total Cells',
                      count: '200',
                      iconPath: 'assets/icons/cell.svg',
                      backgroundColor: statboxColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔍 Search bar + ➕ Add Level button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    height: 35,
                    child: TextField(
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search ...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddLevelScreen(),
                        ),
                      );
                    },
                    icon: SvgPicture.asset("assets/icons/level.svg"),
                    label: Text(
                      'Add Level',
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📋 Custom-styled Paginated Table
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade700),
              ),
              padding: const EdgeInsets.all(12),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.transparent,
                  dividerColor: Colors.grey.shade700,
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PaginatedDataTable(
                        header: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Level List',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Name',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Address',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Level Type',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'isActive',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Actions',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        ],
                        source: LevelDataSource(levels: _levels),
                        rowsPerPage: _rowsPerPage,
                        columnSpacing: 196,
                        horizontalMargin: 16,
                        showCheckboxColumn: false,
                        onPageChanged: (startIndex) {
                          final newPage = startIndex ~/ _rowsPerPage;
                          setState(() => _currentPage = newPage);
                          _fetchLevels();
                        },
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                '© 2025 All rights reserved. Church CRM System',
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class LevelDataSource extends DataTableSource {
  final List<Level> levels;
  final void Function(Level level)? onEdit;

  LevelDataSource({required this.levels, this.onEdit});

  @override
  DataRow getRow(int index) {
    final level = levels[index];
    final isActive = level.isActive ?? false;

    return DataRow(
      cells: [
        DataCell(
          Text(level.name ?? '', style: const TextStyle(color: Colors.white)),
        ),
        DataCell(
          Text(
            level.address ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        DataCell(
          Text(
            level.levelType ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
            onPressed: () => onEdit?.call(level),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => levels.length;

  @override
  int get selectedRowCount => 0;
}

class _LevelDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data = [
    {
      'name': 'Maycraven',
      'address': 'Maycraven',
      'type': 'Head Quarter',
      'active': true,
      'location': 'Remera',
    },
    {
      'name': 'Lionesse Yami',
      'address': 'Lionesse Yami',
      'type': 'Region',
      'active': true,
      'location': 'Remera',
    },
    {
      'name': 'Lionesse Yami',
      'address': 'Lionesse Yami',
      'type': 'Region',
      'active': true,
      'location': 'Remera',
    },
    {
      'name': 'Christian Chang',
      'address': 'Christian Chang',
      'type': 'Parish',
      'active': true,
      'location': 'Remera',
    },
    {
      'name': 'Jade Solis',
      'address': 'Jade Solis',
      'type': 'Chapel',
      'active': true,
      'location': 'Remera',
    },
    {
      'name': 'Claude Bowman',
      'address': 'Claude Bowman',
      'type': 'Cell',
      'active': false,
      'location': 'Remera',
    },
  ];

  @override
  DataRow getRow(int index) {
    final item = _data[index];
    return DataRow(
      cells: [
        DataCell(Text(item['name'])),
        DataCell(Text(item['address'])),
        DataCell(Text(item['type'])),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item['active'] ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['active'] ? 'Active' : 'Inactive',
              style: GoogleFonts.inter(
                color: item['active'] ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Icon(Icons.edit, color: Colors.grey[700], size: 18)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
