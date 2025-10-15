import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/controller/member_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/baptismInformation_model.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/levelType_model.dart';
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

class UpdateLevelScreen extends StatefulWidget {
  final UserModel loggedInUser;
  final Level level;
  const UpdateLevelScreen({
    super.key,
    required this.loggedInUser,
    required this.level,
  });

  @override
  State<UpdateLevelScreen> createState() => _UpdateLevelScreenState();
}

class _UpdateLevelScreenState extends State<UpdateLevelScreen> {
  final _formKey = GlobalKey<FormState>();
  final LevelController levelController = LevelController();
  final UserController userController = UserController();
  // Controllers

  final _levelNameController = TextEditingController();
  final _levelAddressController = TextEditingController();
  final _levelTypeController = TextEditingController();
  // Message state variables
  String? _message;
  bool _isSuccess = false;

  bool _issaveOneLoading = false;

  @override
  void initState() {
    super.initState();
    _populateExistingData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Level? _selectedParentLevel;
  LevelType? _selectedParentType;
  String? _selectedParentId;
  String? _isActive;
  List<LevelType> _parentTypes = [
    LevelType.HEADQUARTER,
    LevelType.REGION,
    LevelType.PARISH,
    LevelType.CHAPEL,
  ];

  List<Level> _availableParents = [];

  Future<void> _loadParentLevels(LevelType type) async {
    try {
      final levels = await LevelController().getLevelsByType(type);
      setState(() {
        _availableParents = levels;
        _selectedParentLevel = null;
        _selectedParentId = null;
      });
    } catch (e) {
      print('Error loading parent levels: $e');
      setState(() {
        _availableParents = [];
      });
    }
  }

  void _populateExistingData() async {
    _levelNameController.text = widget.level.name ?? '';
    _levelAddressController.text = widget.level.address ?? '';
    _levelTypeController.text = widget.level.levelType ?? '';
    _isActive = widget.level.isActive == true ? 'Active' : 'Inactive';

    final parent = widget.level.parent;

    if (parent != null) {
      // Convert levelType string to enum
      final parentLevelTypeString = parent.levelType;
      final match = LevelType.values
          .where((e) => e.name == parentLevelTypeString)
          .toList();
      _selectedParentType = match.isNotEmpty ? match.first : null;

      // Load available parents for that type
      if (_selectedParentType != null) {
        final levels = await LevelController().getLevelsByType(
          _selectedParentType!,
        );
        setState(() {
          _availableParents = levels;

          //  Match parent level by ID
          final matchedParent = levels.firstWhere(
            (lvl) => lvl.levelId == parent.levelId,
            orElse: () => parent,
          );

          _selectedParentLevel = matchedParent;
          _selectedParentId = matchedParent.levelId;
        });
      }
    }
  }
Future<void> _submitUpdateLevel(String levelId) async {
  if (!_formKey.currentState!.validate()) return;

  final levelName = _levelNameController.text.trim();
  final levelAddress = _levelAddressController.text.trim();
  final levelTypeString = _levelTypeController.text.trim();

  String? missingField;
  if (levelName.isEmpty) {
    missingField = 'Level Name';
  } else if (levelAddress.isEmpty) {
    missingField = 'Level Address';
  } else if (levelTypeString.isEmpty) {
    missingField = 'Level Type';
  }

  if (missingField != null) {
    setState(() {
      _message = '$missingField is required.';
      _isSuccess = false;
    });
    return;
  }

  if (_isActive == null) {
    setState(() {
      _message = 'Please select Status';
      _isSuccess = false;
    });
    return;
  }

  setState(() {
    _issaveOneLoading = true;
    _message = null;
  });

  final loggedInUser = await userController.loadUserFromStorage();
  if (loggedInUser == null || loggedInUser.userId == null) {
    setState(() {
      _issaveOneLoading = false;
      _message = 'User ID not found. Please log in again.';
      _isSuccess = false;
    });
    return;
  }

  try {
    final levelTypeEnum = LevelType.values.firstWhere(
      (type) => type.name == levelTypeString,
      orElse: () => LevelType.CHAPEL,
    );
    final statusString = _isActive ?? 'Inactive';
    final isActiveBool = statusString == 'Active';

    final updatedLevel = Level(
      levelId: levelId,
      name: levelName,
      address: levelAddress,
      levelType: levelTypeEnum.name,
      parent: _selectedParentLevel,
      isActive: isActiveBool,
    );

    final result = await levelController.updateLevel(
      levelId: levelId,
      userId: loggedInUser.userId!,
      updatedData: updatedLevel,
    );

    setState(() => _issaveOneLoading = false);

    if (result == 'Status 1000') {
      setState(() {
        _message = 'Level updated successfully';
        _isSuccess = true;
      });
    } else if (result.startsWith('Blocked by')) {
      setState(() {
        _message = result;
        _isSuccess = false;
      });
    } else if (result == 'Invalid level data or parent mismatch.') {
      setState(() {
        _message = result;
        _isSuccess = false;
      });
    } else if (result == 'User not found.') {
      setState(() {
        _message = result;
        _isSuccess = false;
      });
    } else if (result == 'Unauthorized: only SuperAdmins can update levels.') {
      setState(() {
        _message = result;
        _isSuccess = false;
      });
    } else if (result == 'Server error.') {
      setState(() {
        _message = result;
        _isSuccess = false;
      });
    } else if (result == 'Network error.') {
      setState(() {
        _message = result;
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
      _issaveOneLoading = false;
      _message = 'Error updating level: $e';
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
                selectedTitle: 'Levels',
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
                  selectedTitle: 'Levels',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildUpdateLevelScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateLevelScreen() {
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
                        "Update Level",
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
                      children: [
                        _buildTextField(
                          'Level Name',
                          _levelNameController,
                          readOnly: false,
                        ),
                        _buildTextField(
                          'Level Address',
                          _levelAddressController,
                          readOnly: false,
                        ),
                        _buildTextField(
                          'Level Type',
                          _levelTypeController,
                          readOnly: true,
                        ),

                        _buildDropdown(
                          'Status',
                          ['Active', 'Inactive'],
                          _isActive,
                          (val) {
                            setState(() {
                              _isActive = val;
                            });
                          },
                        ),

                        _buildParentTypeDropdown(
                          label: 'Parent Level Type',
                          selectedType: _selectedParentType,

                          onChanged: (type) async {
                            setState(() {
                              _selectedParentType = type;
                              _selectedParentLevel = null;
                              _availableParents = [];
                            });
                            if (type != null) {
                              await _loadParentLevels(type);
                            }
                          },
                          readOnly: true,
                        ),

                        _buildParentNameDropdown(
                          label: 'Parent Level Name',
                          selectedLevel: _selectedParentLevel,
                          onChanged: (level) => setState(() {
                            _selectedParentLevel = level;
                            _selectedParentId = level?.levelId;
                          }),
                        ),
                        const SizedBox(width: 50),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Save Button
                    Center(
                      child: _issaveOneLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () =>
                                  _submitUpdateLevel(widget.level.levelId!),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
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

  Widget _buildParentTypeDropdown({
    required String label,
    required LevelType? selectedType,
    required void Function(LevelType?) onChanged,
    required bool readOnly,
  }) {
    return SizedBox(
      width: 300,

      child: DropdownButtonFormField<LevelType>(
        value: selectedType,

        decoration: InputDecoration(
          labelText: label,

          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _parentTypes.map((type) {
          return DropdownMenuItem<LevelType>(
            value: type,
            child: Text(type.name),
          );
        }).toList(),
        onChanged: readOnly ? null : onChanged,
      ),
    );
  }

  Widget _buildParentNameDropdown({
    required String label,
    required Level? selectedLevel,
    required void Function(Level?) onChanged,
  }) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: selectedLevel,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _availableParents.map((level) {
          return DropdownMenuItem<Level>(
            value: level,
            child: Text(level.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
