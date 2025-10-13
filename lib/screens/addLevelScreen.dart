import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/controller/member_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/baptismInformation_model.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/model/member_model.dart';
import 'package:flutter_churchcrm_system/screens/deparmentScreen.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';

import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';

import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';

class AddLevelScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const AddLevelScreen({super.key, required this.loggedInUser});

  @override
  State<AddLevelScreen> createState() => _AddLevelScreenState();
}

class _AddLevelScreenState extends State<AddLevelScreen> {
  final _formKey = GlobalKey<FormState>();
  final LevelController levelController = LevelController();
  final UserController userController = UserController();
  // Controllers
  final _headquarterNameController = TextEditingController();
  final _headquarterAddressController = TextEditingController();
  final _regionNameController = TextEditingController();
  final _regionAddressController = TextEditingController();
  final _parishNameController = TextEditingController();
  final _parishAddressController = TextEditingController();
  final _chapelNameController = TextEditingController();
  final _chapelAddressController = TextEditingController();
  final _cellNameController = TextEditingController();
  final _cellAddressController = TextEditingController();

  // Message state variables
  String? _message;
  bool _isSuccess = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _headquarterNameController.dispose();
    _headquarterAddressController.dispose();
    _regionNameController.dispose();
    _regionAddressController.dispose();
    _parishNameController.dispose();
    _parishAddressController.dispose();
    _chapelNameController.dispose();
    _cellNameController.dispose();
    _cellAddressController.dispose();
    super.dispose();
  }

  void _clearForm() {
    // Clear text controllers
    _headquarterNameController.clear();
    _headquarterAddressController.clear();
    _regionNameController.clear();
    _regionAddressController.clear();
    _parishNameController.clear();
    _parishAddressController.clear();
    _chapelNameController.clear();
    _cellNameController.clear();
    _cellAddressController.clear();

    // Reset form validation
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final loggedInUser = await userController.loadUserFromStorage();
    if (loggedInUser == null || loggedInUser.userId == null) {
      setState(() {
        _isLoading = false;
        _message = 'User ID not found. Please log in again.';
        _isSuccess = false;
      });
      return;
    }

    try {
      final result = await LevelController().createAllLevels(
        userId: loggedInUser.userId!,
        payload: {
          if (_headquarterNameController.text.trim().isNotEmpty)
            'headquarterName': _headquarterNameController.text.trim(),
          if (_headquarterAddressController.text.trim().isNotEmpty)
            'headquarterAddress': _headquarterAddressController.text.trim(),
          if (_regionNameController.text.trim().isNotEmpty)
            'regionName': _regionNameController.text.trim(),
          if (_regionAddressController.text.trim().isNotEmpty)
            'regionAddress': _regionAddressController.text.trim(),
          if (_parishNameController.text.trim().isNotEmpty)
            'parishName': _parishNameController.text.trim(),
          if (_parishAddressController.text.trim().isNotEmpty)
            'parishAddress': _parishAddressController.text.trim(),
          if (_chapelNameController.text.trim().isNotEmpty)
            'chapelName': _chapelNameController.text.trim(),
          if (_chapelAddressController.text.trim().isNotEmpty)
            'chapelAddress': _chapelAddressController.text.trim(),
          if (_cellNameController.text.trim().isNotEmpty)
            'cellName': _cellNameController.text.trim(),
          if (_cellAddressController.text.trim().isNotEmpty)
            'cellAddress': _cellAddressController.text.trim(),
        },
      );

      setState(() => _isLoading = false);

      if (result == 'Status 1000') {
        setState(() {
          _message = 'Levels created successfully';
          _isSuccess = true;
        });
        _clearForm();
      } else if (result == 'Status 3000') {
        setState(() {
          _message =
              'No headquarter found. Please provide headquarter details.';
          _isSuccess = false;
        });
      } else if (result == 'Status 4000') {
        setState(() {
          _message = 'User not found. Please log in again.';
          _isSuccess = false;
        });
      } else if (result == 'Status 6000') {
        setState(() {
          _message = 'Unauthorized role. Only SuperAdmins can create levels.';
          _isSuccess = false;
        });
      } else if (result == 'Status 7000') {
        setState(() {
          _message = 'Network error. Please check your connection.';
          _isSuccess = false;
        });
      } else if (result == 'Status 9999') {
        setState(() {
          _message = 'Server error. Please try again.';
          _isSuccess = false;
        });
      } else {
        setState(() {
          _message = 'Unexpected error: $result';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error submitting levels: $e';
        _isSuccess = false;
      });
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
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
                selectedTitle: 'Users',
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
                  selectedTitle: 'Users',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildAddLevelScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddLevelScreen() {
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
                        "Add User",
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
                    const SizedBox(height: 24),

                    // Add all levels at once
                    Text(
                      "Add All Levels",
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
                        _buildTextField(
                          'Headquarter Name',
                          _headquarterNameController,
                        ),
                        _buildTextField(
                          'Headquarter Address',
                          _headquarterAddressController,
                        ),
                        _buildTextField('Region Name', _regionNameController),
                        _buildTextField(
                          'Region Address',
                          _regionAddressController,
                        ),
                        _buildTextField('Parish Name', _parishNameController),
                        _buildTextField(
                          'Parish Address',
                          _parishAddressController,
                        ),
                        _buildTextField('Chapel Name', _chapelNameController),
                        _buildTextField(
                          'Chapel Address',
                          _chapelAddressController,
                        ),
                        _buildTextField('Cell Name', _cellNameController),
                        _buildTextField('Cell Address', _cellAddressController),
                        const SizedBox(width: 50),

                        /// Save All levels Button
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _submit,
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
                                  "Save All",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Text(
                    //   "Add One Level",
                    //   style: GoogleFonts.inter(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //     color: titlepageColor,
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    // Wrap(
                    //   spacing: 16,
                    //   runSpacing: 16,
                    //   children: [
                    //     _buildDepartmentDropdown(
                    //       'Department',
                    //       _selectedDepartment,
                    //       (dept) => setState(() => _selectedDepartment = dept),
                    //     ),
                    //     _buildDropdown(
                    //       'Baptism Status',
                    //       ['Baptized', 'Not Baptized'],
                    //       _baptismStatus,
                    //       (val) {
                    //         setState(() {
                    //           _baptismStatus = val;
                    //           if (val == 'Not Baptized') {
                    //             _sameReligion = null;
                    //             _selectedBaptismCell = null;
                    //             _otherChurchNameController.clear();
                    //             _otherChurchAddressController.clear();
                    //           }
                    //         });
                    //       },
                    //     ),

                    //     if (_baptismStatus == 'Baptized')
                    //       _buildDropdown(
                    //         'Same Religion',
                    //         ['Yes', 'No'],
                    //         _sameReligion,
                    //         (val) {
                    //           setState(() {
                    //             _sameReligion = val;
                    //             if (val == 'Yes') {
                    //               _otherChurchNameController.clear();
                    //               _otherChurchAddressController.clear();
                    //             } else if (val == 'No') {
                    //               _selectedBaptismCell = null;
                    //             }
                    //           });
                    //         },
                    //       ),

                    //     if (_baptismStatus == 'Baptized' &&
                    //         _sameReligion == 'Yes')
                    //       _buildCellDropdown(
                    //         'Baptism Cell',
                    //         _selectedBaptismCell,
                    //         (cell) =>
                    //             setState(() => _selectedBaptismCell = cell),
                    //       ),

                    //     if (_baptismStatus == 'Baptized' &&
                    //         _sameReligion == 'No') ...[
                    //       _buildTextField(
                    //         'Other Church Name',
                    //         _otherChurchNameController,
                    //       ),
                    //       _buildTextField(
                    //         'Other Church Address',
                    //         _otherChurchAddressController,
                    //       ),
                    //     ],
                    //   ],
                    // ),

                    // const SizedBox(height: 32),

                    // /// Save Button
                    // Center(
                    //   child: _isLoading
                    //       ? const CircularProgressIndicator()
                    //       : ElevatedButton(
                    //           onPressed: _submit,
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.deepPurple,
                    //             foregroundColor: Colors.white,
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 40,
                    //               vertical: 16,
                    //             ),
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(12),
                    //             ),
                    //           ),
                    //           child: Text(
                    //             "Save",
                    //             style: GoogleFonts.inter(
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //         ),
                    // ),
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
