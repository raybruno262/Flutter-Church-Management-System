// screens/add_equipment_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/provider/addEquipmentCategory_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEquipmentCategoryScreen extends ConsumerStatefulWidget {
  final UserModel loggedInUser;

  const AddEquipmentCategoryScreen({super.key, required this.loggedInUser});

  @override
  ConsumerState<AddEquipmentCategoryScreen> createState() =>
      _AddEquipmentCategoryScreenState();
}

class _AddEquipmentCategoryScreenState
    extends ConsumerState<AddEquipmentCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset provider state when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addEquipmentCategoryProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addEquipmentCategory() async {
    if (_formKey.currentState!.validate()) {
      final result = await ref
          .read(addEquipmentCategoryProvider.notifier)
          .addEquipmentCategory(_nameController.text);

      if (result == 'Status 1000') {
        // Success - clear form
        _formKey.currentState!.reset();
        _nameController.clear();

        // Auto-navigate back after success with refresh signal
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context, 'refresh');
          }
        });
      }
      // If not success, the error message will show automatically via state
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    ref.read(addEquipmentCategoryProvider.notifier).clearForm();
    ref.read(addEquipmentCategoryProvider.notifier).clearMessage();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addEquipmentCategoryProvider);
    final isDesktop = Responsive.isDesktop(context);

    // Listen for form cleared state
    if (state.isFormCleared) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.reset();
        _nameController.clear();
      });
    }

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
                child: _buildAddEquipmentCategoryScreen(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEquipmentCategoryScreen(AddEquipmentCategoryState state) {
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
                        "Add Equipment Category",
                        style: GoogleFonts.inter(
                          color: titlepageColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message Container
                    if (state.message != null)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: const BoxConstraints(maxWidth: 600),
                          decoration: BoxDecoration(
                            color: state.isSuccess
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.isSuccess
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.isSuccess
                                    ? Icons.check_circle
                                    : Icons.error_outline,
                                color: state.isSuccess
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.message!,
                                  style: GoogleFonts.inter(
                                    color: state.isSuccess
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (!state.isSuccess)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    ref
                                        .read(
                                          addEquipmentCategoryProvider.notifier,
                                        )
                                        .clearMessage();
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Back Button - ALWAYS WORKING
                    ElevatedButton.icon(
                      onPressed: () {
                        // Clear any state before going back
                        ref
                            .read(addEquipmentCategoryProvider.notifier)
                            .resetState();
                        Navigator.pop(context);
                      },
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

                    // Form Fields
                    Center(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [_buildNameField()],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Clear Button - ALWAYS WORKING
                          ElevatedButton(
                            onPressed: state.isLoading ? null : _clearForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Clear",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Save Button
                          state.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _addEquipmentCategory,
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
                        ],
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

  Widget _buildNameField() {
    return SizedBox(
      width: 400,
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Equipment Category Name',
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Enter equipment category name',
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: _nameController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _nameController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter equipment category name';
          }
          if (value.trim().length < 2) {
            return 'Name must be at least 2 characters long';
          }
          return null;
        },
        onChanged: (value) => setState(() {}),
      ),
    );
  }
}
