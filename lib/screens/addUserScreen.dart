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
import 'package:flutter_churchcrm_system/model/roleType_model.dart';
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

class AddUserScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const AddUserScreen({super.key, required this.loggedInUser});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController userController = UserController();
  // Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  RoleType? _selectedRoleType;
  List<RoleType> _roleTypes = [
    RoleType.SuperAdmin,
    RoleType.RegionAdmin,
    RoleType.ParishAdmin,
    RoleType.ChapelAdmin,
    RoleType.CellAdmin,
  ];

  Level? _selectedLevel;
  // ignore: unused_field
  String? _selectedLevelId;
  Country? _selectedCountry;
  LevelType? _selectedLevelType;
  // ignore: unused_field
  List<LevelType> _levelTypes = [
    LevelType.HEADQUARTER,
    LevelType.REGION,
    LevelType.PARISH,
    LevelType.CHAPEL,
    LevelType.CELL,
  ];
  List<Level> _availableLevels = [];

  Future<void> _loadLevels(LevelType type) async {
    try {
      final levels = await LevelController().getLevelsByType(type);
      setState(() {
        _availableLevels = levels;
        _selectedLevel = null;
        _selectedLevelId = null;
      });
    } catch (e) {
      setState(() {
        _availableLevels = [];
      });
    }
  }

  bool _isClearing = false;
  void _clearoneForm() {
    _isClearing = true;
    setState(() {
      // Reset form validation
      _formKey.currentState?.reset();
      // Clear text fields
      _nameController.clear();
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _nationalIdController.clear();

      // Clear dropdown selections
      _selectedRoleType = null;
      _selectedLevelType = null;
      _selectedLevel = null;
      _selectedLevelId = null;
      _selectedCountry = null;
      _availableLevels = [];

      // Clear image
      _imageBytes = null;
      _fileExtension = null;
    });

    _isClearing = false;
  }

  // State variables
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _fileExtension;

  // Message state variables
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext =
          lookupMimeType(picked.path)?.split('/').last.toLowerCase() ?? 'jpg';

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _fileExtension = ext;
        });
      }
    }
  }

  Future<void> _submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _message = 'Please enter a valid email address';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }

    if (widget.loggedInUser.userId == null) {
      setState(() {
        _message = 'User ID not found. Please log in again.';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _message = null;
      });
    }
    final password = _passwordController.text.trim();
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (!passwordRegex.hasMatch(password)) {
      setState(() {
        _message =
            'Password is too weak. Use at least:'
            ' 8 characters,'
            ' 1 uppercase letter,'
            ' 1 lowercase letter,'
            ' 1 number,'
            ' 1 special character (@\$!%*?&)';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }
    final phoneCode = _selectedCountry != null
        ? '+${_selectedCountry!.phoneCode}'
        : '+250';
    final fullPhone = '$phoneCode${_phoneController.text.trim()}';

    int? nationalId;
    try {
      nationalId = int.parse(_nationalIdController.text.trim());
    } catch (e) {
      setState(() {
        _message = 'Please enter a valid numeric National ID';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }
    if (_selectedRoleType == null) {
      setState(() {
        _message = 'Please select a Role Type';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }

    if (_selectedLevelType == null) {
      setState(() {
        _message = 'Please select a Level Type';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }

    if (_selectedLevel == null) {
      setState(() {
        _message = 'Please select a Level Name';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }

    if (_imageBytes == null ||
        _fileExtension == null ||
        _fileExtension!.isEmpty) {
      setState(() {
        _message = 'Please select a profile image';
        _isSuccess = false;
        _isLoading = false;
      });
      return;
    }
    try {
      final user = UserModel(
        names: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: email,
        password: _passwordController.text.trim(),
        phone: fullPhone,
        nationalId: nationalId,
        role: _selectedRoleType?.name ?? '',
        profilePic: _imageBytes!,
        level: _selectedLevel!,
      );

      final result = await userController.createUser(
        user,
        profilePic: _imageBytes!,
        fileExtension: _fileExtension!,
        userId: widget.loggedInUser.userId!,
      );

      if (mounted) setState(() => _isLoading = false);

      if (!mounted) return;

      if (result == 'Status 1000') {
        setState(() {
          _message = 'User created successfully';
          _isSuccess = true;
        });
        _clearoneForm();
      } else if (result == 'Status 3000') {
        setState(() {
          _message = 'Level not found';
          _isSuccess = false;
        });
      } else if (result == 'Status 4000') {
        setState(() {
          _message = 'Logged-in user not found';
          _isSuccess = false;
        });
      } else if (result == 'Status 5000') {
        setState(() {
          _message = 'Email already exists';
          _isSuccess = false;
        });
      } else if (result == 'Status 6000') {
        setState(() {
          _message = 'Unauthorized: only SuperAdmins can create users';
          _isSuccess = false;
        });
      } else if (result == 'Status 9999') {
        setState(() {
          _message = 'Server error';
          _isSuccess = false;
        });
      } else {
        setState(() {
          _message = 'Unexpected error: $result';
          _isSuccess = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = 'Error submitting user';
          _isSuccess = false;
        });
      }
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
                child: _buildAddUserScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddUserScreen() {
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

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextField('Name', _nameController),
                        _buildTextField('Username', _usernameController),
                        _buildTextField('Email', _emailController),
                        _buildTextField('Password', _passwordController),
                        _buildPhoneField(_phoneController),
                        _buildTextField('NationalID', _nationalIdController),
                        _buildRoleTypeDropdown(
                          label: 'Role Type',
                          selectedroleType: _selectedRoleType,
                          readOnly: false,
                          onChanged: (type) async {
                            setState(() {
                              _selectedRoleType = type;
                              _selectedLevelType = _mapRoleToLevelType(type);
                              _selectedLevel = null;
                              _availableLevels = [];
                            });

                            if (_selectedLevelType != null) {
                              await _loadLevels(_selectedLevelType!);
                              if (mounted && _availableLevels.isNotEmpty) {
                                setState(() {
                                  _selectedLevel = _availableLevels.first;
                                  _selectedLevelId = _selectedLevel?.levelId;
                                });
                              }
                            }
                          },
                        ),

                        _buildLevelTypeDropdown(
                          label: ' Level Type',
                          selectedType: _selectedLevelType,
                          readOnly: true,
                          onChanged: (type) async {
                            setState(() {
                              _selectedLevelType = type;
                              _selectedLevel = null;
                              _availableLevels = [];
                            });
                            if (type != null) {
                              await _loadLevels(type);
                            }
                          },
                        ),

                        _buildLevelNameDropdown(
                          label: 'Level Name',
                          selectednameLevel: _selectedLevel,
                          onChanged: (level) => setState(() {
                            _selectedLevel = level;
                            _selectedLevelId = level?.levelId;
                          }),
                        ),

                        _buildFilePicker(
                          previewBytes: _imageBytes,
                          onPicked: (bytes, ext) {
                            setState(() {
                              _imageBytes = bytes;
                              _fileExtension = ext;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Save Button
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitUser,
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

  Widget _buildLevelTypeDropdown({
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
        items: LevelType.values.map((type) {
          return DropdownMenuItem<LevelType>(
            value: type,
            child: Text(type.name),
          );
        }).toList(),
        onChanged: readOnly ? null : onChanged,
      ),
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
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  LevelType? _mapRoleToLevelType(RoleType? role) {
    switch (role) {
      case RoleType.SuperAdmin:
        return LevelType.HEADQUARTER;
      case RoleType.RegionAdmin:
        return LevelType.REGION;
      case RoleType.ParishAdmin:
        return LevelType.PARISH;
      case RoleType.ChapelAdmin:
        return LevelType.CHAPEL;
      case RoleType.CellAdmin:
        return LevelType.CELL;
      default:
        return null;
    }
  }

  Widget _buildRoleTypeDropdown({
    required String label,
    required RoleType? selectedroleType,
    required void Function(RoleType?) onChanged,
    required bool readOnly,
  }) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<RoleType>(
        value: selectedroleType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _roleTypes.map((type) {
          return DropdownMenuItem<RoleType>(
            value: type,
            child: Text(type.name),
          );
        }).toList(),
        onChanged: readOnly
            ? null
            : (RoleType? selectedRole) async {
                if (_isClearing) return;
                setState(() {
                  _selectedRoleType = selectedRole;
                  _selectedLevelType = _mapRoleToLevelType(selectedRole);
                  _selectedLevel = null;
                  _availableLevels = [];
                });

                if (_selectedLevelType != null) {
                  final levels = await LevelController().getLevelsByType(
                    _selectedLevelType!,
                  );
                  if (mounted) {
                    setState(() {
                      _availableLevels = levels;
                      if (levels.isNotEmpty) {
                        _selectedLevel = levels.first;
                        _selectedLevelId = levels.first.levelId;
                      }
                    });
                  }
                }

                onChanged(selectedRole);
              },
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        style: GoogleFonts.inter(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          prefixIcon: InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                countryListTheme: CountryListThemeData(
                  backgroundColor: backgroundcolor,
                ),
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              width: 80,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _selectedCountry?.flagEmoji ?? '🇷🇼',
                      style: GoogleFonts.inter(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry != null
                          ? '+${_selectedCountry!.phoneCode}'
                          : '+250',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildLevelNameDropdown({
    required String label,
    required Level? selectednameLevel,
    required void Function(Level?) onChanged,
  }) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: selectednameLevel,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _availableLevels.map((level) {
          return DropdownMenuItem<Level>(
            value: level,
            child: Text(level.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFilePicker({
    required void Function(Uint8List bytes, String ext) onPicked,
    Uint8List? previewBytes,
  }) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Choose Profile", style: GoogleFonts.inter()),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 30,
                backgroundImage: previewBytes != null
                    ? MemoryImage(previewBytes)
                    : null,
                backgroundColor: Colors.grey[200],
                child: previewBytes == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
