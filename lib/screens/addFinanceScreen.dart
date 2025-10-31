import 'package:flutter_churchcrm_system/controller/expenseCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/finance_Controller.dart';
import 'package:flutter_churchcrm_system/controller/incomeCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/model/expenseCategory_model.dart';

import 'package:flutter_churchcrm_system/model/finance_model.dart';
import 'package:flutter_churchcrm_system/model/incomeCategory_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/screens/expenseCategoryScreen.dart';
import 'package:flutter_churchcrm_system/screens/incomeCategoryScreen.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:flutter/material.dart';

import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';

import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFinanceScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const AddFinanceScreen({super.key, required this.loggedInUser});

  @override
  State<AddFinanceScreen> createState() => _AddFinanceScreenState();
}

class _AddFinanceScreenState extends State<AddFinanceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Income Controllers
  final _incomeAmountController = TextEditingController();
  final _incomedescriptionController = TextEditingController();
  final _incomeTransactionDateController = TextEditingController();
  // Expense Controllers
  final _expenseAmountController = TextEditingController();
  final _expensedescriptionController = TextEditingController();
  final _expenseTransactionDateController = TextEditingController();

  final LevelController _levelController = LevelController();
  // Income Data lists
  List<IncomeCategory> _incomeCategories = [];
  List<ExpenseCategory> _expenseCategories = [];
  List<Level> _chapels = [];
  List<Level> _expenseChapels = [];
  final IncomeCategoryController _incomeCatController =
      IncomeCategoryController();
  final ExpenseCategoryController _expenseCatController =
      ExpenseCategoryController();
  // State variables
  bool _isLoading = false;
  bool _isExpenseLoading = false;
  DateTime? _incometransactionDate;
  DateTime? _expensetransactionDate;
  IncomeCategory? _selectedIncomeCategory;
  ExpenseCategory? _selectedExpenseCategory;
  Level? _incomeselectedSuperAdminChapel;
  Level? _expenseselectedSuperAdminChapel;
  // Message state variables
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadIncomeCategories();
    _loadChapels();
    _loadExpenseCategories();
    _loadExpenseChapels();
  }

  @override
  void dispose() {
    _incomeAmountController.dispose();
    _incomedescriptionController.dispose();
    _expenseAmountController.dispose();
    _expensedescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadChapels() async {
    final chapels = await _levelController.getAllChapels();
    if (mounted) {
      setState(() => _chapels = chapels);
    }
  }

  Future<void> _loadExpenseChapels() async {
    final chapels = await _levelController.getAllChapels();
    if (mounted) {
      setState(() => _expenseChapels = chapels);
    }
  }

  Future<void> _loadIncomeCategories() async {
    final incomeCategory = await _incomeCatController.getAllIncomeCategories();
    if (mounted) {
      setState(() => _incomeCategories = incomeCategory);
    }
  }

  Future<void> _loadExpenseCategories() async {
    final expenseCategory = await _expenseCatController
        .getAllExpenseCategories();
    if (mounted) {
      setState(() => _expenseCategories = expenseCategory);
    }
  }

  void _clearIncomeForm() {
    // Reset form validation
    _formKey.currentState?.reset();
    // Clear text controllers
    _incomeAmountController.clear();
    _incomedescriptionController.clear();
    _incomeTransactionDateController.clear();

    // Reset state variables
    setState(() {
      _incometransactionDate = null;
      _selectedIncomeCategory = null;
      _incomeselectedSuperAdminChapel = null;
    });
  }

  void _clearExpenseForm() {
    // Reset form validation
    _formKey.currentState?.reset();
    // Clear text controllers
    _expenseAmountController.clear();
    _expensedescriptionController.clear();
    _expenseTransactionDateController.clear();

    // Reset state variables
    setState(() {
      _expensetransactionDate = null;
      _selectedExpenseCategory = null;
      _expenseselectedSuperAdminChapel = null;
    });
  }

  Future<void> _submitFinance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _message = null;
      _isSuccess = false;
    });

    // Validate category selection
    if (_selectedIncomeCategory == null) {
      setState(() {
        _message = 'Please select Income category';
        _isSuccess = false;
      });
      return;
    }

    // Validate amount
    final amountText = _incomeAmountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _message = 'Please enter an amount';
        _isSuccess = false;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _message = 'Please enter a valid amount greater than zero';
        _isSuccess = false;
      });
      return;
    }

    // Validate transaction date
    if (_incometransactionDate == null) {
      setState(() {
        _message = 'Please select a transaction date';
        _isSuccess = false;
      });
      return;
    }

    if (_incometransactionDate!.isAfter(DateTime.now())) {
      setState(() {
        _message = 'Transaction date cannot be in the future';
        _isSuccess = false;
      });
      return;
    }

    // Validate user ID
    if (widget.loggedInUser.userId == null) {
      setState(() {
        _message = 'User session expired. Please log in again.';
        _isSuccess = false;
      });
      return;
    }

    // Validate level/chapel selection
    final level = widget.loggedInUser.role == 'SuperAdmin'
        ? _incomeselectedSuperAdminChapel
        : widget.loggedInUser.level;

    if (level == null) {
      setState(() {
        _message = widget.loggedInUser.role == 'SuperAdmin'
            ? 'Please select a chapel for this transaction'
            : 'You are not allowed to add a transaction';
        _isSuccess = false;
      });
      return;
    }

    // Validate level ID
    if (level.levelId == null) {
      setState(() {
        _message = 'Invalid chapel selection. Please try again.';
        _isSuccess = false;
      });
      return;
    }

    // Validate income category has ID
    if (_selectedIncomeCategory!.incomeCategoryId == null) {
      setState(() {
        _message = 'Invalid category selected. Please choose a valid category.';
        _isSuccess = false;
      });
      return;
    }
    // Validate description
    final description = _incomedescriptionController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _message = 'Please enter a description';
        _isSuccess = false;
      });
      return;
    }

    try {
      final finance = Finance(
        incomeCategory: _selectedIncomeCategory, // Set income category
        expenseCategory:
            null, // Explicitly set expense category to null for income transactions
        transactionDate: DateFormat(
          'yyyy-MM-dd',
        ).format(_incometransactionDate!),
        amount: amount,
        transactionType: "INCOME", // Explicitly set transaction type
        description: description,
        level: level,
      );

      // Submit to backend
      final result = await FinanceController().createFinance(
        finance,
        userId: widget.loggedInUser.userId!,
      );

      setState(() => _isLoading = false);

      // Handle backend response with more specific messages
      switch (result) {
        case 'Status 1000':
          setState(() {
            _message = 'Income record created successfully!';
            _isSuccess = true;
            _clearIncomeForm();
          });

          break;

        case 'Status 3000':
          setState(() {
            _message = 'Invalid data.';
            _isSuccess = false;
          });
          break;

        case 'Status 4000':
          setState(() {
            _message = 'User not found. Please log in again.';
            _isSuccess = false;
          });
          break;

        case 'Status 6000':
          setState(() {
            _message = 'You are not authorized to create finance records.';
            _isSuccess = false;
          });
          break;

        case 'Status 2000':
          setState(() {
            _message = 'Server error. Please try again later.';
            _isSuccess = false;
          });
          break;

        default:
          setState(() {
            _message = 'Unexpected error';
            _isSuccess = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Network error. Please check your connection and try again.';
        _isSuccess = false;
      });
      print('Error submitting finance');
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitExpenseFinance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _message = null;
      _isSuccess = false;
    });

    // Validate category selection
    if (_selectedExpenseCategory == null) {
      setState(() {
        _message = 'Please select Expense category';
        _isSuccess = false;
      });
      return;
    }

    // Validate amount
    final amountText = _expenseAmountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _message = 'Please enter an amount';
        _isSuccess = false;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _message = 'Please enter a valid amount greater than zero';
        _isSuccess = false;
      });
      return;
    }

    // Validate transaction date
    if (_expensetransactionDate == null) {
      setState(() {
        _message = 'Please select a transaction date';
        _isSuccess = false;
      });
      return;
    }

    if (_expensetransactionDate!.isAfter(DateTime.now())) {
      setState(() {
        _message = 'Transaction date cannot be in the future';
        _isSuccess = false;
      });
      return;
    }

    // Validate user ID
    if (widget.loggedInUser.userId == null) {
      setState(() {
        _message = 'User session expired. Please log in again.';
        _isSuccess = false;
      });
      return;
    }

    // Validate level/chapel selection
    final level = widget.loggedInUser.role == 'SuperAdmin'
        ? _expenseselectedSuperAdminChapel
        : widget.loggedInUser.level;

    if (level == null) {
      setState(() {
        _message = widget.loggedInUser.role == 'SuperAdmin'
            ? 'Please select a chapel for this transaction'
            : 'You are not allowed to add a transaction';
        _isSuccess = false;
      });
      return;
    }

    // Validate level ID
    if (level.levelId == null) {
      setState(() {
        _message = 'Invalid chapel selection. Please try again.';
        _isSuccess = false;
      });
      return;
    }

    // Validate expense category has ID
    if (_selectedExpenseCategory!.expenseCategoryId == null) {
      setState(() {
        _message = 'Invalid category selected. Please choose a valid category.';
        _isSuccess = false;
      });
      return;
    }
    // Validate description
    final description = _expensedescriptionController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _message = 'Please enter a description';
        _isSuccess = false;
      });
      return;
    }

    try {
      final finance = Finance(
        expenseCategory: _selectedExpenseCategory, // Set expense category
        incomeCategory: null,
        transactionDate: DateFormat(
          'yyyy-MM-dd',
        ).format(_expensetransactionDate!),
        amount: amount,
        transactionType: "EXPENSE", // Explicitly set transaction type
        description: description,
        level: level,
      );

      // Submit to backend
      final result = await FinanceController().createFinance(
        finance,
        userId: widget.loggedInUser.userId!,
      );

      setState(() => _isExpenseLoading = false);

      // Handle backend response with more specific messages
      switch (result) {
        case 'Status 1000':
          setState(() {
            _message = 'Expense record created successfully!';
            _isSuccess = true;
            _clearExpenseForm();
          });

          break;

        case 'Status 3000':
          setState(() {
            _message = 'Invalid data.';
            _isSuccess = false;
          });
          break;

        case 'Status 4000':
          setState(() {
            _message = 'User not found. Please log in again.';
            _isSuccess = false;
          });
          break;

        case 'Status 6000':
          setState(() {
            _message = 'You are not authorized to create finance records.';
            _isSuccess = false;
          });
          break;

        case 'Status 2000':
          setState(() {
            _message = 'Server error. Please try again later.';
            _isSuccess = false;
          });
          break;

        default:
          setState(() {
            _message = 'Unexpected error';
            _isSuccess = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _isExpenseLoading = false;
        _message = 'Network error. Please check your connection and try again.';
        _isSuccess = false;
      });
      print('Error submitting finance');
    } finally {
      if (mounted && _isExpenseLoading) {
        setState(() => _isExpenseLoading = false);
      }
    }
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
                child: _buildAddFinanceScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFinanceScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const TopHeaderWidget(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Add Financial Transaction",
                        style: GoogleFonts.inter(
                          color: titlepageColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message Container
                    if (_message != null)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          constraints: const BoxConstraints(maxWidth: 600),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isSuccess ? Colors.green : Colors.red,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isSuccess ? Icons.check_circle : Icons.error,
                                color: _isSuccess
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _message!,
                                  style: GoogleFonts.inter(
                                    color: _isSuccess
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, 'refresh'),
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
                    const SizedBox(height: 24),

                    /// Income Information Section
                    Text(
                      "Income Transaction",
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
                      children: [
                        _buildIncomeCategoryDropdown(
                          'Income Category',
                          _selectedIncomeCategory,
                          (dept) =>
                              setState(() => _selectedIncomeCategory = dept),
                        ),
                        _buildTextField(
                          'Amount',
                          _incomeAmountController,
                          readOnly: false,
                        ),
                        _buildDatePickerField(
                          context,
                          'Transaction Date (MM/dd/yyyy)',
                          _incomeTransactionDateController,
                          (date) => setState(() {
                            _incometransactionDate = date;
                            _incomeTransactionDateController.text = DateFormat(
                              'MM/dd/yyyy',
                            ).format(date);
                          }),
                          _incometransactionDate,
                        ),

                        if (widget.loggedInUser.role == 'SuperAdmin') ...[
                          _buildIncomeSuperAdminChapelDropdown(
                            'Select Chapel',
                            _incomeselectedSuperAdminChapel,
                            (chapel) => setState(
                              () => _incomeselectedSuperAdminChapel = chapel,
                            ),
                          ),
                        ],
                        _buildTextField(
                          'Description',
                          _incomedescriptionController,
                          readOnly: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 11),

                    /// Save Button
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitFinance,
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
                              child: Text(
                                "Save Income",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),

                    /// Expense Information Section
                    Text(
                      "Expense Transaction",
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
                      children: [
                        _buildExpenseCategoryDropdown(
                          'Expense Category',
                          _selectedExpenseCategory,
                          (dept) =>
                              setState(() => _selectedExpenseCategory = dept),
                        ),
                        _buildTextField(
                          'Amount',
                          _expenseAmountController,
                          readOnly: false,
                        ),
                        _buildDatePickerField(
                          context,
                          'Transaction Date (MM/dd/yyyy)',
                          _expenseTransactionDateController,
                          (date) => setState(() {
                            _expensetransactionDate = date;
                            _expenseTransactionDateController.text = DateFormat(
                              'MM/dd/yyyy',
                            ).format(date);
                          }),
                          _expensetransactionDate,
                        ),

                        if (widget.loggedInUser.role == 'SuperAdmin') ...[
                          _buildExpenseSuperAdminChapelDropdown(
                            'Select Chapel',
                            _expenseselectedSuperAdminChapel,
                            (chapel) => setState(
                              () => _expenseselectedSuperAdminChapel = chapel,
                            ),
                          ),
                        ],
                        _buildTextField(
                          'Description',
                          _expensedescriptionController,
                          readOnly: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 11),

                    /// Save Button
                    Center(
                      child: _isExpenseLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitExpenseFinance,
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
                              child: Text(
                                "Save Expense",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required bool readOnly,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
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

  Widget _buildIncomeSuperAdminChapelDropdown(
    String label,
    Level? _selectedSuperAdminBaptismChapel,
    void Function(Level?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: _selectedSuperAdminBaptismChapel,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _chapels.map((chapel) {
          return DropdownMenuItem<Level>(
            value: chapel,
            child: Text(chapel.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,

        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildExpenseSuperAdminChapelDropdown(
    String label,
    Level? _selectedSuperAdminBaptismChapel,
    void Function(Level?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: _selectedSuperAdminBaptismChapel,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _expenseChapels.map((chapel) {
          return DropdownMenuItem<Level>(
            value: chapel,
            child: Text(chapel.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,

        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildIncomeCategoryDropdown(
    String label,
    IncomeCategory? selectedIncomeCategory,
    void Function(IncomeCategory?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: selectedIncomeCategory?.incomeCategoryId ?? 'none',
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: [
          const DropdownMenuItem(
            value: 'none',
            child: Text('Select Income Category'),
          ),
          ..._incomeCategories.map((incomeCategory) {
            return DropdownMenuItem<String>(
              value: incomeCategory.incomeCategoryId,
              child: Text(incomeCategory.name),
            );
          }),
          const DropdownMenuItem(value: 'others', child: Text('Others')),
        ],
        onChanged: (String? selectedId) async {
          if (selectedId == 'others') {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    IncomeCategoryScreen(loggedInUser: widget.loggedInUser),
              ),
            );
            if (result != null) {
              await _loadIncomeCategories();
            }
          } else if (selectedId == 'none') {
            setState(() {
              _selectedIncomeCategory = null;
            });
          } else {
            final dept = _incomeCategories.firstWhere(
              (d) => d.incomeCategoryId == selectedId,
              orElse: () => _incomeCategories.first,
            );
            setState(() {
              _selectedIncomeCategory = dept;
            });
            onChanged(dept);
          }
        },

        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildExpenseCategoryDropdown(
    String label,
    ExpenseCategory? selectedExpenseCategory,
    void Function(ExpenseCategory?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: selectedExpenseCategory?.expenseCategoryId ?? 'none',
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: [
          const DropdownMenuItem(
            value: 'none',
            child: Text('Select Expense Category'),
          ),
          ..._expenseCategories.map((expenseCategory) {
            return DropdownMenuItem<String>(
              value: expenseCategory.expenseCategoryId,
              child: Text(expenseCategory.name),
            );
          }),
          const DropdownMenuItem(value: 'others', child: Text('Others')),
        ],
        onChanged: (String? selectedId) async {
          if (selectedId == 'others') {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ExpenseCategoryScreen(loggedInUser: widget.loggedInUser),
              ),
            );
            if (result != null) {
              await _loadExpenseCategories();
            }
          } else if (selectedId == 'none') {
            setState(() {
              _selectedExpenseCategory = null;
            });
          } else {
            final dept = _expenseCategories.firstWhere(
              (d) => d.expenseCategoryId == selectedId,
              orElse: () => _expenseCategories.first,
            );
            setState(() {
              _selectedExpenseCategory = dept;
            });
            onChanged(dept);
          }
        },

        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    String label,
    TextEditingController controller,
    void Function(DateTime) onDateSelected,
    DateTime? initialDate,
  ) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () {
          DateTime tempSelectedDate = initialDate ?? DateTime.now();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: SizedBox(
                  height: 350,
                  width: 300,
                  child: SfDateRangePicker(
                    view: DateRangePickerView.month,
                    showNavigationArrow: true,
                    initialSelectedDate: tempSelectedDate,
                    minDate: DateTime(1900),
                    maxDate: DateTime.now(),
                    showActionButtons: true,
                    onSelectionChanged: (args) {
                      tempSelectedDate = args.value;
                    },
                    onSubmit: (value) {
                      final selected = value as DateTime;
                      controller.text = DateFormat(
                        'MM/dd/yyyy',
                      ).format(selected);
                      onDateSelected(selected);
                      Navigator.pop(context);
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
