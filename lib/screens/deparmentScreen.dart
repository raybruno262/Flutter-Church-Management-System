import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const DepartmentScreen({super.key, required this.loggedInUser});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  final DepartmentController _departmentController = DepartmentController();
  int _departmentCount = 0;
  final _nameFilterController = TextEditingController();
  int _currentPage = 0;
  final int _pageSize = 5;
  List<Department> _departments = [];
  List<Department> _filteredDapartments = [];
  @override
  void initState() {
    super.initState();
    _fetchDepartmentCount();
    _fetchDepartments();
  }

  void _nextPage() {
    _currentPage++;
    _fetchDepartments();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _fetchDepartments();
    }
  }

  bool _isLoading = true;

  Future<void> _fetchDepartments() async {
    setState(() => _isLoading = true);
    final departments = await _departmentController.getPaginatedDepartments(
      page: _currentPage,
      size: _pageSize,
    );
    setState(() {
      _departments = departments.reversed.toList();

      _applySearchFilter();
      _isLoading = false;
    });
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();

    _filteredDapartments = _departments.where((level) {
      final matchesName = level.name.toLowerCase().contains(nameQuery);

      return matchesName;
    }).toList();

    setState(() {});
  }

  Future<void> _fetchDepartmentCount() async {
    try {
      final count = await _departmentController.getDepartmentCount();
      setState(() {
        _departmentCount = count;
      });
    } catch (e) {
      setState(() {
        _departmentCount = 0;
      });
    }
  }

  DataRow _buildDataRow(Department department) {
    return DataRow(
      cells: [
        DataCell(Text(department.name, style: GoogleFonts.inter())),

        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  // TODO: Navigate to UpdateLevelPage
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
          ? Drawer(
              child: SideMenuWidget(
                selectedTitle: 'Members',
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
                  selectedTitle: 'Members',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildDepartmentScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const TopHeaderWidget(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Manage Department",
                      style: GoogleFonts.inter(
                        color: titlepageColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

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
                  const SizedBox(height: 20),

                  // Main Row Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: StatBox + Add Department Form
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
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
                                    iconPath: 'assets/icons/depart.svg',
                                    label: 'Total Departments',
                                    count: _departmentCount.toString(),
                                    backgroundColor: statboxColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              "Add/Update Department",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: titlepageColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [_buildTextField('Department Name')],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              child: Text(
                                "Save",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // TODO: Add save logic
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Right: Levels List + Table
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "Department List",
                                style: GoogleFonts.inter(
                                  color: titlepageColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _isLoading
                                ? Container(
                                    height: 300,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: containerColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,

                                          child: SizedBox(
                                            width: 800,
                                            child: _buildFilterField(
                                              _nameFilterController,
                                              'Search Name',
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: 300,
                                          ),
                                          child: SizedBox(
                                            width: 600,
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
                                                    'Department Name',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    'Action',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: _filteredDapartments.isEmpty
                                                  ? [
                                                      DataRow(
                                                        cells: [
                                                          DataCell(
                                                            Text(
                                                              'No Department found',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                              ),
                                                            ),
                                                          ),
                                                          const DataCell(
                                                            SizedBox(),
                                                          ),
                                                        ],
                                                      ),
                                                    ]
                                                  : _filteredDapartments
                                                        .map(_buildDataRow)
                                                        .toList(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: _previousPage,
                                              icon: const Icon(
                                                Icons.arrow_back,
                                              ),
                                              label: Text('Previous'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurple,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                              icon: const Icon(
                                                Icons.arrow_forward,
                                              ),
                                              label: Text('Next'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurple,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      '© 2025 All rights reserved. Church CRM System',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 13,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 310,
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: (_) => _applySearchFilter(),
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

  Widget _buildTextField(String label) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
