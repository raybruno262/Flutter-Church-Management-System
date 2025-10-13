import 'dart:typed_data';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/controller/member_controller.dart';
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

class AddMemberScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const AddMemberScreen({super.key, required this.loggedInUser});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _otherChurchNameController = TextEditingController();
  final _otherChurchAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  // Data lists
  List<Department> _departments = [];
  List<Level> _cells = [];

  // Controllers
  final LevelController _levelController = LevelController();
  final DepartmentController _departmentController = DepartmentController();

  // State variables
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _fileExtension;
  String? _maritalStatus;
  String? _gender;
  DateTime? _dob;
  String? _baptismStatus;
  String? _sameReligion;
  Department? _selectedDepartment;
  Level? _selectedBaptismCell;
  Country? _selectedCountry;

  // Message state variables
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadCells();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _otherChurchNameController.dispose();
    _otherChurchAddressController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadCells() async {
    final cells = await _levelController.getAllCells();
    if (mounted) {
      setState(() => _cells = cells);
    }
  }

  Future<void> _loadDepartments() async {
    final departments = await _departmentController.getAllDepartments();
    if (mounted) {
      setState(() => _departments = departments);
    }
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

  void _clearForm() {
    // Clear text controllers
    _nameController.clear();
    _emailController.clear();
    _addressController.clear();
    _otherChurchNameController.clear();
    _otherChurchAddressController.clear();
    _phoneController.clear();
    _dobController.clear();

    // Reset state variables
    setState(() {
      _imageBytes = null;
      _fileExtension = null;
      _maritalStatus = null;
      _gender = null;
      _dob = null;
      _baptismStatus = null;
      _sameReligion = null;
      _selectedDepartment = null;
      _selectedBaptismCell = null;
      _selectedCountry = null;
    });

    // Reset form validation
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    //  Email format validation
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _message = 'Please enter a valid email address';
        _isSuccess = false;
      });
      return;
    }
    // Validate image
    if (_imageBytes == null ||
        _fileExtension == null ||
        _fileExtension!.isEmpty) {
      setState(() {
        _message = 'Please select a profile image';
        _isSuccess = false;
      });
      return;
    }

    // Validate department
    if (_selectedDepartment == null) {
      setState(() {
        _message = 'Please select a department';
        _isSuccess = false;
      });
      return;
    }

    // Validate baptism status
    if (_baptismStatus == null) {
      setState(() {
        _message = 'Please select baptism status';
        _isSuccess = false;
      });
      return;
    }

    // Validate same religion
    if (_sameReligion == null) {
      setState(() {
        _message = 'Please select same religion option';
        _isSuccess = false;
      });
      return;
    }

    // Validate baptism cell when same religion is Yes
    if (_sameReligion == 'Yes' && _selectedBaptismCell == null) {
      setState(() {
        _message = 'Please select a baptism cell';
        _isSuccess = false;
      });
      return;
    }

    // Validate other church fields when same religion is No
    if (_sameReligion == 'No') {
      if (_otherChurchNameController.text.trim().isEmpty) {
        setState(() {
          _message = 'Please enter other church name';
          _isSuccess = false;
        });
        return;
      }
      if (_otherChurchAddressController.text.trim().isEmpty) {
        setState(() {
          _message = 'Please enter other church address';
          _isSuccess = false;
        });
        return;
      }
    }

    // Validate gender
    if (_gender == null) {
      setState(() {
        _message = 'Please select gender';
        _isSuccess = false;
      });
      return;
    }

    // Validate marital status
    if (_maritalStatus == null) {
      setState(() {
        _message = 'Please select marital status';
        _isSuccess = false;
      });
      return;
    }

    // Start loading only after all validations pass
    if (mounted) {
      setState(() {
        _isLoading = true;
        _message = null;
      });
    }

    try {
      // Get user ID from logged in user
      if (widget.loggedInUser.userId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _message = 'User ID not found. Please log in again.';
            _isSuccess = false;
          });
        }
        return;
      }

      // Create baptism information
      final baptismInfo = BaptismInformation(
        baptized: _baptismStatus == "Baptized",
        sameReligion: _sameReligion == "Yes",
        baptismCell: _sameReligion == "Yes" ? _selectedBaptismCell : null,
        otherChurchName: _sameReligion == "No"
            ? _otherChurchNameController.text.trim()
            : null,
        otherChurchAddress: _sameReligion == "No"
            ? _otherChurchAddressController.text.trim()
            : null,
      );

      // Build phone number with country code
      final phoneCode = _selectedCountry != null
          ? '+${_selectedCountry!.phoneCode}'
          : '+250';
      final fullPhone = '$phoneCode${_phoneController.text.trim()}';

      // Create member object
      final member = Member(
        names: _nameController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        phone: fullPhone,
        maritalStatus: _maritalStatus ?? '',
        gender: _gender ?? '',
        status: 'Active',
        dateOfBirth: _dob != null
            ? '${_dob!.month.toString().padLeft(2, '0')}/'
                  '${_dob!.day.toString().padLeft(2, '0')}/'
                  '${_dob!.year}'
            : '',
        membershipDate:
            '${DateTime.now().month.toString().padLeft(2, '0')}/'
            '${DateTime.now().day.toString().padLeft(2, '0')}/'
            '${DateTime.now().year}',
        level: widget.loggedInUser.level,
        department: _selectedDepartment,
        baptismInformation: baptismInfo,
        profilePic: _imageBytes!,
      );

      // Submit to backend
      final result = await MemberController().createMember(
        member,
        profilePic: _imageBytes!,
        fileExtension: _fileExtension!,
        userId: widget.loggedInUser.userId!,
      );

      // Always stop loading after getting result
      if (mounted) setState(() => _isLoading = false);

      // Handle response
      if (!mounted) return;

      if (result == 'Status 1000') {
        setState(() {
          _message = 'Member created successfully';
          _isSuccess = true;
        });
        // Clear the form after successful save
        _clearForm();
      } else if (result == 'Status 3000') {
        setState(() {
          _message = 'Invalid department or baptism info';
          _isSuccess = false;
        });
      } else if (result == 'Status 4000') {
        setState(() {
          _message = 'User not found';
          _isSuccess = false;
        });
      } else if (result == 'Status 6000') {
        setState(() {
          _message = 'Unauthorized role';
          _isSuccess = false;
        });
      } else {
        setState(() {
          _message = 'Unexpected error: $result';
          _isSuccess = false;
        });
      }
    } catch (e) {
      // Always stop loading on error
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = 'Error submitting member: $e';
          _isSuccess = false;
        });
      }
    } finally {
      // Final safety net to ensure loading stops
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
                selectedTitle: 'Members',
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
                  selectedTitle: 'Members',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildAddMemberScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberScreen() {
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
                        "Add Member",
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

                    /// Personal Information Section
                    Text(
                      "Personal Information",
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
                        _buildTextField('Name', _nameController),
                        _buildTextField('Email', _emailController),
                        _buildDropdown(
                          'Marital Status',
                          ['Single', 'Married', 'Divorced'],
                          _maritalStatus,
                          (val) => setState(() => _maritalStatus = val),
                        ),
                        _buildDatePickerField(
                          'Date of Birth (MM/dd/yyyy)',
                          _dobController,
                          (date) => setState(() {
                            _dob = date;
                            _dobController.text =
                                "${date.month}/${date.day}/${date.year}";
                          }),
                        ),
                        _buildDropdown(
                          'Gender',
                          ['Male', 'Female'],
                          _gender,
                          (val) => setState(() => _gender = val),
                        ),
                        _buildTextField('Address', _addressController),
                        _buildPhoneField(_phoneController),
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

                    const SizedBox(height: 32),

                    /// Church Information Section
                    Text(
                      "Church Information",
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
                        _buildDepartmentDropdown(
                          'Department',
                          _selectedDepartment,
                          (dept) => setState(() => _selectedDepartment = dept),
                        ),
                        _buildDropdown(
                          'Baptism Status',
                          ['Baptized', 'Not Baptized'],
                          _baptismStatus,
                          (val) {
                            setState(() {
                              _baptismStatus = val;
                              if (val == 'Not Baptized') {
                                _sameReligion = null;
                                _selectedBaptismCell = null;
                                _otherChurchNameController.clear();
                                _otherChurchAddressController.clear();
                              }
                            });
                          },
                        ),

                        if (_baptismStatus == 'Baptized')
                          _buildDropdown(
                            'Same Religion',
                            ['Yes', 'No'],
                            _sameReligion,
                            (val) {
                              setState(() {
                                _sameReligion = val;
                                if (val == 'Yes') {
                                  _otherChurchNameController.clear();
                                  _otherChurchAddressController.clear();
                                } else if (val == 'No') {
                                  _selectedBaptismCell = null;
                                }
                              });
                            },
                          ),

                        if (_baptismStatus == 'Baptized' &&
                            _sameReligion == 'Yes')
                          _buildCellDropdown(
                            'Baptism Cell',
                            _selectedBaptismCell,
                            (cell) =>
                                setState(() => _selectedBaptismCell = cell),
                          ),

                        if (_baptismStatus == 'Baptized' &&
                            _sameReligion == 'No') ...[
                          _buildTextField(
                            'Other Church Name',
                            _otherChurchNameController,
                          ),
                          _buildTextField(
                            'Other Church Address',
                            _otherChurchAddressController,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// Save Button
                    Center(
                      child: _isLoading
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
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildCellDropdown(
    String label,
    Level? selectedCell,
    void Function(Level?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: selectedCell,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _cells.map((cell) {
          return DropdownMenuItem<Level>(
            value: cell,
            child: Text(cell.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (_sameReligion == 'Yes' && value == null) {
            return 'Required';
          }
          return null;
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

  Widget _buildDepartmentDropdown(
    String label,
    Department? selectedDepartment,
    void Function(Department?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: selectedDepartment?.departmentId ?? 'none',
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
          const DropdownMenuItem(value: 'none', child: Text('None')),
          ..._departments.map((department) {
            return DropdownMenuItem<String>(
              value: department.departmentId,
              child: Text(department.name),
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
                    DepartmentScreen(loggedInUser: widget.loggedInUser),
              ),
            );
            if (result != null) {
              await _loadDepartments();
            }
          } else if (selectedId == 'none') {
            setState(() {
              _selectedDepartment = null;
            });
          } else {
            final dept = _departments.firstWhere(
              (d) => d.departmentId == selectedId,
              orElse: () => _departments.first,
            );
            setState(() {
              _selectedDepartment = dept;
            });
            onChanged(dept);
          }
        },
        validator: (value) =>
            value == null || value == 'none' ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePickerField(
    String label,
    TextEditingController controller,
    void Function(DateTime) onDateSelected,
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
                    initialSelectedDate: DateTime.now(),
                    minDate: DateTime(1900),
                    maxDate: DateTime.now(),
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                          final DateTime selected = args.value;
                          onDateSelected(selected);
                          Navigator.pop(context);
                        },
                  ),
                ),
              );
            },
          );
        },
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
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
