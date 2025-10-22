import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/expenseCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/incomeCategory_controller.dart';

import 'package:flutter_churchcrm_system/controller/user_controller.dart';

import 'package:flutter_churchcrm_system/model/department_model.dart';

import 'package:flutter/material.dart';

import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/expenseCategory_model.dart';
import 'package:flutter_churchcrm_system/model/incomeCategory_model.dart';

import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AddExpenseCategoryScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const AddExpenseCategoryScreen({super.key, required this.loggedInUser});

  @override
  State<AddExpenseCategoryScreen> createState() =>
      _AddExpenseCategoryScreenState();
}

class _AddExpenseCategoryScreenState extends State<AddExpenseCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController userController = UserController();
  final ExpenseCategoryController expenseCategoryController =
      ExpenseCategoryController();

  // Controllers
  final _nameController = TextEditingController();

  // ignore: unused_field
  bool _isClearing = false;
  void _clearoneForm() {
    _isClearing = true;
    setState(() {
      // Reset form validation
      _formKey.currentState?.reset();
    });

    _isClearing = false;
  }

  // State variables
  bool _isLoading = false;

  // Message state variables
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _addExpenseCategory() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _message = 'Please enter expense category name';
        _isSuccess = false;
      });

      return;
    }

    final expenseCategoryName = _nameController.text.trim();

    try {
      final newExpenseCategory = ExpenseCategory(name: expenseCategoryName);

      final result = await expenseCategoryController.createExpenseCategory(
        newExpenseCategory,
      );

      if (result == 'Status 1000') {
        setState(() {
          _message = 'Expense Category created successfully!';
          _isSuccess = true;
        });

        _clearoneForm();
      } else if (result == 'Status 5000') {
        setState(() {
          _message = 'Expense Category name already exists';
          _isSuccess = false;
        });
      } else if (result == 'Status 7000') {
        setState(() {
          _message = 'Network error';
          _isSuccess = false;
        });
      } else {
        setState(() {
          _message = 'Unexpected error';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error creating Expense Category';
        _isSuccess = false;
      });
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
                child: _buildAddExpenseCategoryScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExpenseCategoryScreen() {
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
                        "Add Expense Category",
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

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [_buildTextField('Name', _nameController)],
                    ),

                    const SizedBox(height: 10),

                    /// Save Button
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _addExpenseCategory,
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
                                "Save",
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
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
