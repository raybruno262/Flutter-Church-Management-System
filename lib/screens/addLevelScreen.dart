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

  final _levelNameController = TextEditingController();
  final _levelAddressController = TextEditingController();

  // Message state variables
  String? _message;
  bool _isSuccess = false;
  bool _isLoading = false;
  bool _issaveOneLoading = false;

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

  Level? _selectedParentLevel;
  LevelType? _selectedParentType;
  String? _selectedParentId;

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

  void _clearoneForm() {
    _levelNameController.clear();
    _levelAddressController.clear();
    _selectedParentId = null;
    _selectedParentLevel = null;

    // Reset form validation
    _formKey.currentState?.reset();
  }

  Future<void> _submitOneLevel() async {
    if (!_formKey.currentState!.validate()) return;
    final levelName = _levelNameController.text.trim();
    final levelAddress = _levelAddressController.text.trim();

    String? missingField;

    if (levelName.isEmpty) {
      missingField = 'Level Name';
    } else if (levelAddress.isEmpty) {
      missingField = 'Level Address';
    } else if (_selectedParentId == null) {
      missingField = 'Parent Level';
    }

    if (missingField != null) {
      setState(() {
        _message = '$missingField is required.';
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
      final result = await LevelController().addOneLevel(
        userId: loggedInUser.userId!,
        levelName: _levelNameController.text.trim(),
        levelAddress: _levelAddressController.text.trim(),
        parentId: _selectedParentId!,
      );

      setState(() => _issaveOneLoading = false);

      switch (result) {
        case 'Status 1000':
          setState(() {
            _message = 'Level created successfully';
            _isSuccess = true;
          });
          _clearoneForm();
          break;
        case 'Status 3000':
          _message = 'Missing fields or invalid parent.';
          break;
        case 'Status 4000':
          _message = 'User not found.';
          break;
        case 'Status 6000':
          _message = 'Unauthorized role.';
          break;
        case 'Status 7000':
          _message = 'Network error.';
          break;
        case 'Status 9999':
          _message = 'Server error.';
          break;
        default:
          _message = 'Unexpected error: $result';
      }
    } catch (e) {
      setState(() {
        _issaveOneLoading = false;
        _message = 'Error submitting level: $e';
        _isSuccess = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final hqName = _headquarterNameController.text.trim();
    final hqAddress = _headquarterAddressController.text.trim();
    final regionName = _regionNameController.text.trim();
    final regionAddress = _regionAddressController.text.trim();
    final parishName = _parishNameController.text.trim();
    final parishAddress = _parishAddressController.text.trim();
    final chapelName = _chapelNameController.text.trim();
    final chapelAddress = _chapelAddressController.text.trim();
    final cellName = _cellNameController.text.trim();
    final cellAddress = _cellAddressController.text.trim();

    final levelPairs = {
      'Headquarter': [hqName, hqAddress],
      'Region': [regionName, regionAddress],
      'Parish': [parishName, parishAddress],
      'Chapel': [chapelName, chapelAddress],
      'Cell': [cellName, cellAddress],
    };

    for (final entry in levelPairs.entries) {
      final name = entry.value[0];
      final address = entry.value[1];
      if ((name.isEmpty && address.isNotEmpty) ||
          (name.isNotEmpty && address.isEmpty)) {
        setState(() {
          _isLoading = false;
          _message = '${entry.key} requires both name and address.';
          _isSuccess = false;
        });
        return;
      }
    }

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

    final payload = <String, String>{};
    if (hqName.isNotEmpty && hqAddress.isNotEmpty) {
      payload['headquarterName'] = hqName;
      payload['headquarterAddress'] = hqAddress;
    }
    if (regionName.isNotEmpty && regionAddress.isNotEmpty) {
      payload['regionName'] = regionName;
      payload['regionAddress'] = regionAddress;
    }
    if (parishName.isNotEmpty && parishAddress.isNotEmpty) {
      payload['parishName'] = parishName;
      payload['parishAddress'] = parishAddress;
    }
    if (chapelName.isNotEmpty && chapelAddress.isNotEmpty) {
      payload['chapelName'] = chapelName;
      payload['chapelAddress'] = chapelAddress;
    }
    if (cellName.isNotEmpty && cellAddress.isNotEmpty) {
      payload['cellName'] = cellName;
      payload['cellAddress'] = cellAddress;
    }
    if (payload.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'At least one level is required.';
        _isSuccess = false;
      });
      return;
    }
    try {
      final result = await LevelController().createAllLevels(
        userId: loggedInUser.userId!,
        payload: payload,
      );

      setState(() => _isLoading = false);

      switch (result) {
        case 'Status 1000':
          setState(() {
            _message = 'Levels created successfully';
            _isSuccess = true;
          });
          _clearForm();
          break;
        case 'Status 3000':
          if (hqName.isNotEmpty && hqAddress.isNotEmpty) {
            _message = 'Headquarter already exists. Only one is allowed.';
          } else {
            _message =
                'No headquarter found. Please provide headquarter details.';
          }
          _isSuccess = false;
          break;
        case 'Status 4000':
          _message = 'User not found. Please log in again.';
          _isSuccess = false;
          break;
        case 'Status 6000':
          _message = 'Unauthorized role. Only SuperAdmins can create levels.';
          _isSuccess = false;
          break;
        case 'Status 7000':
          _message = 'Network error. Please check your connection.';
          _isSuccess = false;
          break;
        case 'Status 9999':
          _message = 'Server error. Please try again.';
          _isSuccess = false;
          break;
        default:
          _message = 'Unexpected error: $result';
          _isSuccess = false;
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
                        "Add Level",
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

                    const SizedBox(height: 26),

                    Text(
                      "Add One Level",
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
                        _buildTextField('Level Name', _levelNameController),
                        _buildTextField(
                          'Level Address',
                          _levelAddressController,
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

                        /// Save Button
                        _issaveOneLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _submitOneLevel,
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

  Widget _buildParentTypeDropdown({
    required String label,
    required LevelType? selectedType,
    required void Function(LevelType?) onChanged,
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
        onChanged: onChanged,
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

        menuMaxHeight: 250,
      ),
    );
  }
}
