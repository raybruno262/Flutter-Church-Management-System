import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/expenseCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/incomeCategory_controller.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/expenseCategory_model.dart';
import 'package:flutter_churchcrm_system/model/incomeCategory_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/UpdateIncomeCategory.dart';
import 'package:flutter_churchcrm_system/screens/addExpenseCategoryScreen.dart';
import 'package:flutter_churchcrm_system/screens/addIncomeCategory.dart';
import 'package:flutter_churchcrm_system/screens/updateExpenseCategory.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseCategoryScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const ExpenseCategoryScreen({super.key, required this.loggedInUser});

  @override
  State<ExpenseCategoryScreen> createState() => _ExpenseCategoryScreenState();
}

class _ExpenseCategoryScreenState extends State<ExpenseCategoryScreen> {
  final ExpenseCategoryController _expenseCategoryController =
      ExpenseCategoryController();

  int _expenseCategoryCount = 0;
  final _nameFilterController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  int _currentPage = 0;

  int _pageSize = 5;
  List<ExpenseCategory> _expenseCategories = [];
  List<ExpenseCategory> _allExpenseCategories = [];
  // ignore: unused_field
  List<ExpenseCategory> _filteredExpenseCategories = [];
  @override
  void initState() {
    super.initState();
    _fetchExpenseCategoryCount();
    _fetchExpenseCategories();
  }

  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  // ignore: unused_field
  bool _isFiltering = false;
  bool _isLoading = true;

  Future<void> _fetchExpenseCategories() async {
    setState(() => _isLoading = true);
    final expenseCategories = await _expenseCategoryController
        .getPaginatedExpenseCategories(page: _currentPage, size: _pageSize);
    setState(() {
      _expenseCategories = expenseCategories;
      _filteredExpenseCategories = _expenseCategories;

      _isLoading = false;
    });
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();

    final filtered = _allExpenseCategories.where((expenseCategory) {
      final matchesName = expenseCategory.name.toLowerCase().contains(
        nameQuery,
      );

      return matchesName;
    }).toList();

    setState(() {
      _filteredExpenseCategories = filtered;
      _currentPage = 0;
    });
  }

  Future<void> _fetchAllExpenseCategories() async {
    final allExpenseCategories = await _expenseCategoryController
        .getAllExpenseCategories();
    setState(() {
      _allExpenseCategories = allExpenseCategories;
      _isLoading = false;
    });
  }

  void _onFilterChanged() async {
    final isDefaultFilter = _nameFilterController.text.isEmpty;

    if (isDefaultFilter) {
      _isFiltering = false;
      _currentPage = 0;
      await _fetchExpenseCategories();
    } else {
      _isFiltering = true;
      await _fetchAllExpenseCategories();
      _applySearchFilter();
    }
  }

  Future<void> _nextPage() async {
    if (_isFiltering) {
      if ((_currentPage + 1) * _pageSize < _filteredExpenseCategories.length) {
        setState(() => _currentPage++);
      }
    } else {
      setState(() => _currentPage++);
      await _fetchExpenseCategories();
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      if (_isFiltering) {
        setState(() => _currentPage--);
      } else {
        setState(() => _currentPage--);
        await _fetchExpenseCategories();
      }
    }
  }

  List<ExpenseCategory> get displayedDepartments {
    if (_isFiltering) {
      if (_filteredExpenseCategories.isEmpty) return [];
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      return _filteredExpenseCategories.sublist(
        start,
        end > _filteredExpenseCategories.length
            ? _filteredExpenseCategories.length
            : end,
      );
    } else {
      return _expenseCategories;
    }
  }

  // ignore: unused_field
  bool _isClearing = false;

  Future<void> _fetchExpenseCategoryCount() async {
    try {
      final count = await _expenseCategoryController.getExpenseCategoryCount();
      setState(() {
        _expenseCategoryCount = count;
      });
    } catch (e) {
      setState(() {
        _expenseCategoryCount = 0;
      });
    }
  }

  DataRow _buildDataRow(ExpenseCategory expenseCategory) {
    return DataRow(
      cells: [
        DataCell(Text(expenseCategory.name, style: GoogleFonts.inter())),

        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateExpenseCategoryScreen(
                        loggedInUser: widget.loggedInUser,
                        expenseCategory: expenseCategory,
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _currentPage = 0;
                    });

                    _fetchExpenseCategories();

                    _fetchExpenseCategoryCount();
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
          ? Drawer(
              child: SideMenuWidget(
                selectedTitle: 'Finance',
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
                  selectedTitle: 'Finance',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildExpenseCategoryScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCategoryScreen() {
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
                      "Manage Expense Category",
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
                          StatBox(
                            iconPath: 'assets/icons/expense.svg',
                            label: 'Total Expense Categories',
                            count: _expenseCategoryCount.toString(),
                            backgroundColor: statboxColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 440),
                        Text(
                          "Expense Category List",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 140),

                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddExpenseCategoryScreen(
                                  loggedInUser: widget.loggedInUser,
                                ),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                _currentPage = 0;
                              });

                              await _fetchExpenseCategories();
                              await _fetchExpenseCategoryCount();
                            }
                          },
                          icon: SvgPicture.asset("assets/icons/expense.svg"),
                          label: Text(
                            'Add Expense Category',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 17,
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
                      ? Center(
                          child: Container(
                            height: 300,

                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Center(
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,

                                        children: [
                                          _buildFilterField(
                                            _nameFilterController,
                                            'Search Name',
                                          ),
                                        ],
                                      ),
                                    ),

                                    Stack(
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),

                                                DataColumn(
                                                  label: Text(
                                                    'Actions',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],

                                              rows: displayedDepartments.isEmpty
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
                                                  : displayedDepartments
                                                        .map(_buildDataRow)
                                                        .toList(),
                                            ),
                                          ),
                                        ),
                                        if (displayedDepartments.isEmpty)
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
                                                  'No Income Categories found',
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

                                    Positioned(
                                      left: 426,
                                      top: 10,
                                      child: Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _previousPage,
                                            icon: Icon(Icons.arrow_back),
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
                                            icon: Icon(Icons.arrow_forward),
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                              items: _pageSizeOptions.map((
                                                size,
                                              ) {
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
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
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
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
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
                                                    _fetchExpenseCategories();
                                                  }
                                                }
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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

  Widget _buildFilterField(TextEditingController controller, String hint) {
    return SizedBox(
      width: 222,
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
    );
  }
}
