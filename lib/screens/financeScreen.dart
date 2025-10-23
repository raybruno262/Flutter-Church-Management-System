import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/financeStatBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/controller/expenseCategory_controller.dart';
import 'package:flutter_churchcrm_system/model/expenseCategory_model.dart';
import 'package:flutter_churchcrm_system/screens/updateFinanceScreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_churchcrm_system/controller/finance_Controller.dart';
import 'package:flutter_churchcrm_system/controller/incomeCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';

import 'package:flutter_churchcrm_system/model/finance_model.dart';
import 'package:flutter_churchcrm_system/model/incomeCategory_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/addFinanceScreen.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';

class FinanceScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const FinanceScreen({super.key, required this.loggedInUser});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _categoryFilterController = TextEditingController();
  final _transactionDateFilterController = TextEditingController();
  final _amountFilterController = TextEditingController();
  String _typeFilter = 'All Types'; // Options: All, Income, Expense
  final _descriptionFilterController = TextEditingController();
  final _levelFilterController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final FinanceController _controller = FinanceController();
  final UserController _usercontroller = UserController();

  // ignore: unused_field
  List<IncomeCategory> _incomeCategories = [];
  List<ExpenseCategory> _expenseCategories = [];
  final IncomeCategoryController _incomeCategoriesController =
      IncomeCategoryController();
  final ExpenseCategoryController _expenseCategoriesController =
      ExpenseCategoryController();
  IncomeCategory? _selectedIncomeCategory;

  Future<void> _loadIncomeCategories() async {
    final incomeCategories = await _incomeCategoriesController
        .getAllIncomeCategories();
    if (mounted) {
      setState(() => _incomeCategories = incomeCategories);
    }
  }

  Future<void> _loadExpenseCategories() async {
    final expenseCategories = await _expenseCategoriesController
        .getAllExpenseCategories();
    if (mounted) {
      setState(() => _expenseCategories = expenseCategories);
    }
  }

  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  List<Finance> _finance = [];
  List<Finance> _allFinance = [];
  List<Finance> _filteredFinance = [];

  bool _isLoading = true;

  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _fetchFinance();
    _fetchAllFinance();
    _fetchFinanceStats();
    _loadIncomeCategories();
    _loadExpenseCategories();
  }

  Future<void> _fetchFinance() async {
    setState(() => _isLoading = true);
    try {
      final finance = await _controller.getScopedPaginatedFinance(
        userId: widget.loggedInUser.userId!,
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _finance = finance;
        _filteredFinance = _finance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllFinance() async {
    try {
      final allFinance = await _controller.getAllFinance();
      setState(() {
        _allFinance = allFinance;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _applySearchFilter() {
    final categoryQuery = _categoryFilterController.text.toLowerCase();
    final transactionDateQuery = _transactionDateFilterController.text;
    final amountQuery = _amountFilterController.text;
    final descriptionQuery = _descriptionFilterController.text.toLowerCase();
    final levelQuery = _levelFilterController.text.toLowerCase();

    final filtered = _allFinance.where((finance) {
      final matchesTransactionDate =
          transactionDateQuery.isEmpty ||
          (finance.transactionDate.contains(transactionDateQuery));

      final matchesAmount = finance.amount == amountQuery;
      final matchesDescription = finance.description!.toLowerCase().contains(
        descriptionQuery,
      );
      final matchesType =
          _typeFilter == 'All Types' || finance.transactionType == _typeFilter;

      final matchesLevel =
          levelQuery.isEmpty ||
          (finance.level?.name?.toLowerCase().contains(levelQuery) ?? false);

      return matchesTransactionDate &&
          matchesAmount &&
          matchesDescription &&
          matchesType &&
          matchesLevel;
    }).toList();
    setState(() {
      _filteredFinance = filtered;
      _currentPage = 0;
    });
  }

  void _onFilterChanged() async {
    final isDefaultFilter =
        _categoryFilterController.text.isEmpty &&
        _transactionDateFilterController.text.isEmpty &&
        _amountFilterController.text.isEmpty &&
        _typeFilter == 'All Types' &&
        _descriptionFilterController.text.isEmpty &&
        _levelFilterController.text.isEmpty;

    if (isDefaultFilter) {
      _isFiltering = false;
      _currentPage = 0;
      await _fetchFinance();
    } else {
      _isFiltering = true;
      await _fetchAllFinance();
      _applySearchFilter();
    }
  }

  Future<void> _nextPage() async {
    if (_isFiltering) {
      if ((_currentPage + 1) * _pageSize < _filteredFinance.length) {
        setState(() => _currentPage++);
      }
    } else {
      setState(() => _currentPage++);
      await _fetchFinance();
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      if (_isFiltering) {
        setState(() {});
      } else {
        await _fetchFinance();
      }
    }
  }

  List<Finance> get displayedFinance {
    if (_isFiltering) {
      if (_filteredFinance.isEmpty) return [];
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      return _filteredFinance.sublist(
        start,
        end > _filteredFinance.length ? _filteredFinance.length : end,
      );
    } else {
      return _finance;
    }
  }

  Map<String, dynamic> _financeStats = {
    'totalIncome': 0.0,
    'totalExpenses': 0.0,
    'currentBalance': 0.0,
  };

  Future<void> _fetchFinanceStats() async {
    try {
      final loggedInUser = await _usercontroller.loadUserFromStorage();

      if (loggedInUser == null || loggedInUser.userId == null) {
        setState(() {
          _financeStats = {
            'totalIncome': 0.0,
            'totalExpenses': 0.0,
            'currentBalance': 0.0,
          };
        });
        return;
      }

      final stats = await _controller.getFinanceStats(loggedInUser.userId!);

      final updatedStats = {
        'totalIncome': stats['totalIncome'] ?? 0.0,
        'totalExpenses': stats['totalExpenses'] ?? 0.0,
        'currentBalance': stats['currentBalance'] ?? 0.0,
      };

      setState(() {
        _financeStats = updatedStats;
      });
    } catch (e) {
      setState(() {
        _financeStats = {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'currentBalance': 0.0,
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

  DataRow _buildDataRow(Finance finance) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            finance.incomeCategory?.name ?? 'N/A',
            style: GoogleFonts.inter(),
          ),
        ),
        DataCell(
          Text(
            finance.expenseCategory?.name ?? 'N/A',
            style: GoogleFonts.inter(),
          ),
        ),
        DataCell(
          Container(
            constraints: BoxConstraints(maxWidth: 110),
            child: Tooltip(
              message: _formatNumberWithCommas(finance.amount),
              child: Text(
                _formatNumberForDisplay(finance.amount),
                style: GoogleFonts.inter(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
        DataCell(Text(finance.transactionDate, style: GoogleFonts.inter())),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(
                finance.transactionType ?? 'UNKNOWN',
              ),
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
                    color: _getStatusDotColor(
                      finance.transactionType ?? 'UNKNOWN',
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  finance.transactionType ?? 'UNKNOWN',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(
                      finance.transactionType ?? 'UNKNOWN',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 300, minWidth: 150),
            child: Tooltip(
              message: finance.description ?? 'No description',
              child: Text(
                finance.description ?? 'No description',
                style: GoogleFonts.inter(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Text(finance.level?.name ?? 'N/A', style: GoogleFonts.inter()),
        ),
        DataCell(
          Row(
            children: [
              if (widget.loggedInUser.role == 'CellAdmin' ||
                  widget.loggedInUser.role == 'SuperAdmin') ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Update Transaction',
                  onPressed: () async {
                    final updatedFinance = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateFinanceScreen(
                          loggedInUser: widget.loggedInUser,
                          finance: finance,
                        ),
                      ),
                    );

                    if (updatedFinance != null && updatedFinance is Finance) {
                      setState(() {
                        final index = _finance.indexWhere(
                          (m) => m.financeId == updatedFinance.financeId,
                        );
                        if (index != -1) {
                          _finance[index] = updatedFinance;
                        }

                        final filteredIndex = _filteredFinance.indexWhere(
                          (m) => m.financeId == updatedFinance.financeId,
                        );
                        if (filteredIndex != -1) {
                          _filteredFinance[filteredIndex] = updatedFinance;
                        }
                      });

                      await _fetchFinanceStats();
                      await _fetchFinance();
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
                child: _buildFinanceScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceScreen() {
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
                      "Manage Finance",
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
                          Tooltip(
                            message: _formatNumberWithCommas(
                              _financeStats['totalIncome'],
                            ),
                            child: FinanceStatBoxWidget(
                              iconPath: 'assets/icons/income.svg',
                              label: 'Total Incomes',
                              count: _formatNumberForDisplay(
                                _financeStats['totalIncome'],
                              ),
                              backgroundColor: statboxColor,
                              countTextStyle: _getCountTextStyle(
                                _financeStats['totalIncome'],
                              ),
                            ),
                          ),
                          Tooltip(
                            message: _formatNumberWithCommas(
                              _financeStats['totalExpenses'],
                            ),
                            child: FinanceStatBoxWidget(
                              label: 'Total Expenses',
                              count: _formatNumberForDisplay(
                                _financeStats['totalExpenses'],
                              ),
                              iconPath: 'assets/icons/expense.svg',
                              backgroundColor: statboxColor,
                              countTextStyle: _getCountTextStyle(
                                _financeStats['totalExpenses'],
                              ),
                            ),
                          ),
                          Tooltip(
                            message: _formatNumberWithCommas(
                              _financeStats['currentBalance'],
                            ),
                            child: FinanceStatBoxWidget(
                              label: 'Current Balance',
                              count: _formatNumberForDisplay(
                                _financeStats['currentBalance'],
                              ),
                              iconPath: 'assets/icons/balance.svg',
                              backgroundColor: statboxColor,
                              countTextStyle: _getCountTextStyle(
                                _financeStats['currentBalance'],
                              ),
                            ),
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
                          "Finance List",
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
                              final newFinance = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddFinanceScreen(
                                    loggedInUser: widget.loggedInUser,
                                  ),
                                ),
                              );

                              if (newFinance != null && newFinance is Finance) {
                                await _fetchFinance();
                                await _fetchAllFinance();
                                await _fetchFinanceStats();
                                setState(() {
                                  _currentPage = 0;
                                });
                              }
                            },
                            icon: SvgPicture.asset("assets/icons/finance.svg"),
                            label: Text(
                              'Add Transaction',
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
                                          _categoryFilterController,
                                          'Search Category',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _categoryFilterController,
                                          'Search Category',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _amountFilterController,
                                          'Search Amount',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _transactionDateFilterController,
                                          'Search Date(MM/dd/yyyy)',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildTypeDropdown(),

                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _descriptionFilterController,
                                          'Search Description',
                                        ),

                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _levelFilterController,
                                          'Search Level',
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
                                          width: 1600,
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
                                                  'Income Category',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Expense Category',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Amount',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Transaction Date',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Transaction Type',
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
                                            rows: displayedFinance.isEmpty
                                                ? [
                                                    DataRow(
                                                      cells: List.generate(
                                                        8,
                                                        (_) => const DataCell(
                                                          SizedBox(),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                : displayedFinance
                                                      .map(_buildDataRow)
                                                      .toList(),
                                          ),
                                        ),
                                      ),
                                      if (displayedFinance.isEmpty)
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
                                                'No Finance found',
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
                                                  _fetchFinance();
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

  Widget _buildTypeDropdown() {
    return SizedBox(
      width: 210,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _typeFilter,
        onChanged: (value) {
          setState(() {
            _typeFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Types', 'INCOME', 'EXPENSE'].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Text(
              gender,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Types', 'INCOME', 'EXPENSE'].map((role) {
            return Text(
              role,
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

  Color _getStatusBackgroundColor(String transactionType) {
    switch (transactionType) {
      case 'INCOME':
        return Colors.green.shade100;
      case 'EXPENSE':
        return Colors.brown.shade100;

      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusDotColor(String transactionType) {
    switch (transactionType) {
      case 'INCOME':
        return Colors.green;
      case 'EXPENSE':
        return Colors.brown;

      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String transactionType) {
    switch (transactionType) {
      case 'INCOME':
        return Colors.green.shade800;
      case 'EXPENSE':
        return Colors.brown.shade500;

      default:
        return Colors.grey.shade600;
    }
  }
}
