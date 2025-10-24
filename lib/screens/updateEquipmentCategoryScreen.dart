// screens/update_equipment_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/provider/updateEquipmentCategory_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateEquipmentCategoryScreen extends ConsumerStatefulWidget {
  final UserModel loggedInUser;
  final EquipmentCategory equipmentCategory;

  const UpdateEquipmentCategoryScreen({
    super.key,
    required this.loggedInUser,
    required this.equipmentCategory,
  });

  @override
  ConsumerState<UpdateEquipmentCategoryScreen> createState() =>
      _UpdateEquipmentCategoryScreenState();
}

class _UpdateEquipmentCategoryScreenState
    extends ConsumerState<UpdateEquipmentCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the equipment category in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(updateEquipmentCategoryProvider.notifier)
          .setEquipmentCategory(widget.equipmentCategory);
      _populateExistingData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _populateExistingData() {
    _nameController.text = widget.equipmentCategory.name;
  }

  Future<void> _updateEquipmentCategory() async {
    if (_formKey.currentState!.validate()) {
      final result = await ref
          .read(updateEquipmentCategoryProvider.notifier)
          .updateEquipmentCategory(_nameController.text);

      if (result == 'Status 1000') {
        // Success - auto-navigate back after a delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context, 'refresh');
          }
        });
      }
    }
  }

  void _resetForm() {
    _populateExistingData();
    ref.read(updateEquipmentCategoryProvider.notifier).clearMessage();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateEquipmentCategoryProvider);
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
                child: _buildUpdateEquipmentCategoryScreen(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateEquipmentCategoryScreen(
    UpdateEquipmentCategoryState state,
  ) {
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
                        "Update Equipment Category",
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
                                          updateEquipmentCategoryProvider
                                              .notifier,
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

                    // Current Equipment Category Info
                    if (state.equipmentCategory != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Editing: ${state.equipmentCategory!.name}',
                              style: GoogleFonts.inter(
                                color: Colors.blue.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Back Button
                    ElevatedButton.icon(
                      onPressed: () {
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
                          // Reset Button
                          ElevatedButton(
                            onPressed: state.isLoading ? null : _resetForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
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
                              "Reset",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Update Button
                          state.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _updateEquipmentCategory,
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
                                    "Update",
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
