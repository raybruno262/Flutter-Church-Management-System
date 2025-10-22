import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/controller/finance_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/finance_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/addFinanceScreen.dart';
import 'package:flutter_churchcrm_system/screens/updateFinanceScreen.dart';
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
  String _transactionTypeFilter =
      'All Types'; // Options: All Types, INCOME, EXPENSE
  final _descriptionFilterController = TextEditingController();
  final _amountFilterController = TextEditingController();
  String _categoryFilter = 'All Categories';

  final ScrollController _horizontalScrollController = ScrollController();

  final FinanceController _controller = FinanceController();
  final UserController _usercontroller = UserController();
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  List<Finance> _financeRecords = [];
  List<Finance> _allFinanceRecords = [];
  List<Finance> _filteredFinanceRecords = [];
  bool _isLoading = true;

  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _fetchFinanceRecords();
    _fetchAllFinanceRecords();
    _fetchFinanceStats();
  }

  Future<void> _fetchFinanceRecords() async {
    setState(() => _isLoading = true);
    try {
      final financeRecords = await _controller.getPaginatedFinance(
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _financeRecords = financeRecords;
        _filteredFinanceRecords = _financeRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllFinanceRecords() async {
    try {
      final allFinanceRecords = await _controller.getAllFinance();
      setState(() {
        _allFinanceRecords = allFinanceRecords;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _applySearchFilter() {
    final descriptionQuery = _descriptionFilterController.text.toLowerCase();
    final amountQuery = _amountFilterController.text;

    final filtered = _allFinanceRecords.where((finance) {
      final matchesDescription =
          finance.description?.toLowerCase().contains(descriptionQuery) ??
          false;
      final matchesAmount =
          amountQuery.isEmpty ||
          finance.amount.toString().contains(amountQuery);

      final matchesTransactionType =
          _transactionTypeFilter == 'All Types' ||
          finance.transactionType == _transactionTypeFilter;

      final categoryName = finance.category;
      final matchesCategory =
          _categoryFilter == 'All Categories' ||
          categoryName.contains(_categoryFilter);

      return matchesDescription &&
          matchesAmount &&
          matchesTransactionType &&
          matchesCategory;
    }).toList();

    setState(() {
      _filteredFinanceRecords = filtered;
      _currentPage = 0; // Reset to first page when filtering
    });
  }

  void _onFilterChanged() async {
    final isDefaultFilter =
        _descriptionFilterController.text.isEmpty &&
        _amountFilterController.text.isEmpty &&
        _transactionTypeFilter == 'All Types' &&
        _categoryFilter == 'All Categories';

    if (isDefaultFilter) {
      _isFiltering = false;
      _currentPage = 0;
      await _fetchFinanceRecords();
    } else {
      _isFiltering = true;
      await _fetchAllFinanceRecords();
      _applySearchFilter();
    }
  }

  Future<void> _nextPage() async {
    if (_isFiltering) {
      if ((_currentPage + 1) * _pageSize < _filteredFinanceRecords.length) {
        setState(() => _currentPage++);
      }
    } else {
      setState(() => _currentPage++);
      await _fetchFinanceRecords();
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      if (_isFiltering) {
        // No need to fetch for filtered data, just update UI
        setState(() {});
      } else {
        await _fetchFinanceRecords();
      }
    }
  }

  List<Finance> get displayedFinanceRecords {
    if (_isFiltering) {
      if (_filteredFinanceRecords.isEmpty) return [];
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      return _filteredFinanceRecords.sublist(
        start,
        end > _filteredFinanceRecords.length
            ? _filteredFinanceRecords.length
            : end,
      );
    } else {
      return _financeRecords;
    }
  }

  Map<String, double> _financeStats = {
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

  DataRow _buildDataRow(Finance finance) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTransactionTypeBackgroundColor(
                finance.transactionType,
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
                    color: _getTransactionTypeDotColor(finance.transactionType),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  finance.transactionType,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getTransactionTypeTextColor(
                      finance.transactionType,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(
            finance.transactionDate ?? 'N/A',
            style: GoogleFonts.inter(fontSize: 13),
          ),
        ),
        DataCell(
          Text(
            '\$${finance.amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: finance.transactionType == 'INCOME'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ),
        DataCell(
          Text(finance.category, style: GoogleFonts.inter(fontSize: 13)),
        ),
        DataCell(
          Text(
            finance.description ?? 'No description',
            style: GoogleFonts.inter(fontSize: 13),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                tooltip: 'View Finance Record',
                onPressed: () {
                  _showFinanceDetailsDialog(finance);
                },
              ),
              if (widget.loggedInUser.role == 'CellAdmin' ||
                  widget.loggedInUser.role == 'SuperAdmin') ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Update Finance Record',
                  onPressed: () async {
                    // final updatedFinance = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => UpdateFinanceScreen(
                    //       loggedInUser: widget.loggedInUser,
                    //       finance: finance,
                    //     ),
                    //   ),
                    // );

                    // if (updatedFinance != null && updatedFinance is Finance) {
                    //   setState(() {
                    //     final index = _financeRecords.indexWhere(
                    //       (f) => f.financeId == updatedFinance.financeId,
                    //     );
                    //     if (index != -1) {
                    //       _financeRecords[index] = updatedFinance;
                    //     }

                    //     final filteredIndex = _filteredFinanceRecords
                    //         .indexWhere(
                    //           (f) => f.financeId == updatedFinance.financeId,
                    //         );
                    //     if (filteredIndex != -1) {
                    //       _filteredFinanceRecords[filteredIndex] =
                    //           updatedFinance;
                    //     }
                    //   });

                    //   await _fetchFinanceStats();
                    //   await _fetchFinanceRecords();
                    // }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showFinanceDetailsDialog(Finance finance) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: SingleChildScrollView(
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              color: backgroundcolor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: finance.transactionType == 'INCOME'
                          ? [Colors.green.shade700, Colors.green.shade500]
                          : [Colors.red.shade700, Colors.red.shade500],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Transaction Type Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          finance.transactionType == 'INCOME'
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Amount
                      Text(
                        '\$${finance.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Transaction Type
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          finance.transactionType,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Transaction Details Section
                      _buildSectionHeader('Transaction Details'),
                      const SizedBox(height: 16),

                      // Details in cards
                      _buildEnhancedDetailCard(
                        'Category',
                        finance.category,
                        Icons.category_outlined,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildEnhancedDetailCard(
                        'Transaction Date',
                        finance.transactionDate ?? 'N/A',
                        Icons.date_range_outlined,
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildEnhancedDetailCard(
                        'Description',
                        finance.description ?? 'No description',
                        Icons.description_outlined,
                        Colors.orange,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Actions section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.loggedInUser.role == 'CellAdmin' ||
                          widget.loggedInUser.role == 'SuperAdmin')
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: finance.transactionType == 'INCOME'
                                  ? [
                                      Colors.green.shade600,
                                      Colors.green.shade800,
                                    ]
                                  : [Colors.red.shade600, Colors.red.shade800],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton.icon(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              'Update Record',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () async {
                              // final updatedFinance = await Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => UpdateFinanceScreen(
                              //       loggedInUser: widget.loggedInUser,
                              //       finance: finance,
                              //     ),
                              //   ),
                              // );
                              // if (updatedFinance != null &&
                              //     updatedFinance is Finance) {
                              //   setState(() {
                              //     final index = _financeRecords.indexWhere(
                              //       (f) =>
                              //           f.financeId == updatedFinance.financeId,
                              //     );
                              //     if (index != -1) {
                              //       _financeRecords[index] = updatedFinance;
                              //     }

                              //     final filteredIndex = _filteredFinanceRecords
                              //         .indexWhere(
                              //           (f) =>
                              //               f.financeId ==
                              //               updatedFinance.financeId,
                              //         );
                              //     if (filteredIndex != -1) {
                              //       _filteredFinanceRecords[filteredIndex] =
                              //           updatedFinance;
                              //     }
                              //   });

                              //   await _fetchFinanceStats();
                              //   await _fetchFinanceRecords();
                              // }
                            },
                          ),
                        ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  // Helper method for section headers
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 2,
          width: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade800,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.grey.shade300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced detail card widget
  Widget _buildEnhancedDetailCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
                      "Manage Finances",
                      style: GoogleFonts.inter(
                        color: titlepageColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Finance Statistics
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
                            iconPath: 'assets/icons/income.svg',
                            label: 'Total Income',
                            count:
                                '\$${_financeStats['totalIncome']!.toStringAsFixed(2)}',
                            backgroundColor: Colors.green.shade100,
                          ),
                          StatBox(
                            label: 'Total Expenses',
                            count:
                                '\$${_financeStats['totalExpenses']!.toStringAsFixed(2)}',
                            iconPath: 'assets/icons/expense.svg',
                            backgroundColor: Colors.red.shade100,
                          ),
                          StatBox(
                            label: 'Current Balance',
                            count:
                                '\$${_financeStats['currentBalance']!.toStringAsFixed(2)}',
                            iconPath: 'assets/icons/balance.svg',
                            backgroundColor:
                                _financeStats['currentBalance']! >= 0
                                ? Colors.blue.shade100
                                : Colors.orange.shade100,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Finance Records List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 460),
                        Text(
                          "Finance Records",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 280),
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin') ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              // final newFinance = await Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => AddFinanceScreen(
                              //       loggedInUser: widget.loggedInUser,
                              //     ),
                              //   ),
                              // );

                              // if (newFinance != null && newFinance is Finance) {
                              //   setState(() {
                              //     _financeRecords.insert(0, newFinance);
                              //     _filteredFinanceRecords = _financeRecords;
                              //     _currentPage = 0;
                              //   });

                              //   // Refresh stats
                              //   await _fetchFinanceStats();
                              // }
                            },
                            icon: SvgPicture.asset("assets/icons/finance.svg"),
                            label: Text(
                              'Add Finance Record',
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

                  // Finance Records Table
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
                                  // Filter Row
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        _buildTransactionTypeDropdown(),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _descriptionFilterController,
                                          'Search Description',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _amountFilterController,
                                          'Search Amount',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildCategoryFilterField(),
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
                                          width: 1200,
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
                                                label: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.swap_vert,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Type',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Date',
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
                                                  'Category',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Description',
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
                                                displayedFinanceRecords.isEmpty
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
                                                : displayedFinanceRecords
                                                      .map(_buildDataRow)
                                                      .toList(),
                                          ),
                                        ),
                                      ),
                                      if (displayedFinanceRecords.isEmpty)
                                        Positioned(
                                          left: 300,
                                          top: 120,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.search_off,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'No Finance Records found',
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

                                  // Pagination
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
                                                  _fetchFinanceRecords();
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

                  // Footer
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
      width: 180,
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

  Widget _buildTransactionTypeDropdown() {
    return SizedBox(
      width: 150,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _transactionTypeFilter,
        onChanged: (value) {
          setState(() {
            _transactionTypeFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Types', 'INCOME', 'EXPENSE'].map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              type,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Types', 'INCOME', 'EXPENSE'].map((type) {
            return Text(
              type,
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

  Widget _buildCategoryFilterField() {
    return SizedBox(
      width: 180,
      height: 40,
      child: TextField(
        controller: TextEditingController(
          text: _categoryFilter == 'All Categories' ? '' : _categoryFilter,
        ),
        onChanged: (value) {
          setState(() {
            _categoryFilter = value.isEmpty ? 'All Categories' : value;
            _onFilterChanged();
          });
        },
        style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search Category',
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

  // Helper methods for transaction type styling
  Color _getTransactionTypeBackgroundColor(String transactionType) {
    switch (transactionType) {
      case 'INCOME':
        return Colors.green.shade100;
      case 'EXPENSE':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTransactionTypeDotColor(String transactionType) {
    switch (transactionType) {
      case 'INCOME':
        return Colors.green;
      case 'EXPENSE':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getTransactionTypeTextColor(String transactionType) {
    switch (transactionType) {
      case 'INCOME':
        return Colors.green.shade800;
      case 'EXPENSE':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade600;
    }
  }
}
