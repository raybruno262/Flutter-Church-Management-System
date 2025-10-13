import 'dart:typed_data';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/controller/member_controller.dart';
import 'package:flutter_churchcrm_system/model/baptismInformation_model.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/model/member_model.dart';
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

class UpdateMemberScreen extends StatefulWidget {
  final UserModel loggedInUser;
  final Member member;

  const UpdateMemberScreen({
    super.key,
    required this.loggedInUser,
    required this.member,
  });

  @override
  State<UpdateMemberScreen> createState() => _UpdateMemberScreenState();
}

class _UpdateMemberScreenState extends State<UpdateMemberScreen> {
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
  bool _imageChanged = false;
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

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadCells();
    _populateExistingData();
  }

  void _populateExistingData() {
    // Populate text fields
    _nameController.text = widget.member.names ?? '';
    _emailController.text = widget.member.email ?? '';
    _addressController.text = widget.member.address ?? '';

    // Parse and populate phone number
    final phone = widget.member.phone ?? '';
    if (phone.isNotEmpty) {
      // Remove leading '+' if present
      final normalized = phone.startsWith('+') ? phone.substring(1) : phone;

      // Remove country code (assumed to be 250 for Rwanda)
      if (normalized.startsWith('250')) {
        _phoneController.text = normalized.substring(5); // Strip '250'
      } else {
        _phoneController.text = normalized; // Use full number if no match
      }
    }

    // Populate gender and marital status
    _gender = widget.member.gender;
    _maritalStatus = widget.member.maritalStatus;

    // Parse and populate date of birth
    if (widget.member.dateOfBirth != null &&
        widget.member.dateOfBirth!.isNotEmpty) {
      try {
        List<String> parts = widget.member.dateOfBirth!.split('/');
        if (parts.length == 3) {
          int month = int.parse(parts[0]);
          int day = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          _dob = DateTime(year, month, day);
          _dobController.text = widget.member.dateOfBirth!;
        }
      } catch (e) {
        print('Error parsing date of birth: $e');
      }
    }

    // Populate baptism information
    if (widget.member.baptismInformation != null) {
      _baptismStatus = widget.member.baptismInformation!.baptized == true
          ? 'Baptized'
          : 'Not Baptized';
      _sameReligion = widget.member.baptismInformation!.sameReligion == true
          ? 'Yes'
          : 'No';

      if (widget.member.baptismInformation!.sameReligion == true) {
        _selectedBaptismCell = widget.member.baptismInformation!.baptismCell;
      } else {
        _otherChurchNameController.text =
            widget.member.baptismInformation!.otherChurchName ?? '';
        _otherChurchAddressController.text =
            widget.member.baptismInformation!.otherChurchAddress ?? '';
      }
    }

    // Set existing profile picture
    _imageBytes = widget.member.profilePic;

    // Set department (will be matched when departments load)
    _selectedDepartment = widget.member.department;
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
      setState(() {
        _cells = cells;
        // Match existing baptism cell if it exists
        if (widget.member.baptismInformation?.baptismCell != null) {
          _selectedBaptismCell = _cells.firstWhere(
            (cell) =>
                cell.levelId ==
                widget.member.baptismInformation!.baptismCell!.levelId,
            orElse: () => widget.member.baptismInformation!.baptismCell!,
          );
        }
      });
    }
  }

  Future<void> _loadDepartments() async {
    final departments = await _departmentController.getAllDepartments();
    if (mounted) {
      setState(() {
        _departments = departments;
        // Match existing department if it exists
        if (widget.member.department != null) {
          _selectedDepartment = _departments.firstWhere(
            (dept) =>
                dept.departmentId == widget.member.department!.departmentId,
            orElse: () => widget.member.department!,
          );
        }
      });
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
          _imageChanged = true;
        });
      }
    }
  }

  Future<void> _submit() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate image
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile image')),
      );
      return;
    }

    // Validate department
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
      return;
    }

    // Validate baptism status
    if (_baptismStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select baptism status')),
      );
      return;
    }

    // Validate same religion
    if (_sameReligion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select same religion option')),
      );
      return;
    }

    // Validate baptism cell when same religion is Yes
    if (_sameReligion == 'Yes' && _selectedBaptismCell == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a baptism cell')),
      );
      return;
    }

    // Validate other church fields when same religion is No
    if (_sameReligion == 'No') {
      if (_otherChurchNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter other church name')),
        );
        return;
      }
      if (_otherChurchAddressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter other church address')),
        );
        return;
      }
    }

    // Validate gender
    if (_gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select gender')));
      return;
    }

    // Validate marital status
    if (_maritalStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select marital status')),
      );
      return;
    }

    // Start loading only after all validations pass
    if (mounted) setState(() => _isLoading = true);

    try {
      // Get user ID from logged in user
      if (widget.loggedInUser.userId == null) {
        if (mounted) setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found. Please log in again.'),
          ),
        );
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

      // Create updated member object
      final updatedMember = Member(
        memberId: widget.member.memberId, // Keep existing ID
        names: _nameController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        phone: fullPhone,
        maritalStatus: _maritalStatus ?? '',
        gender: _gender ?? '',
        status: widget.member.status, // Keep existing status
        dateOfBirth: _dob != null
            ? '${_dob!.month.toString().padLeft(2, '0')}/'
                  '${_dob!.day.toString().padLeft(2, '0')}/'
                  '${_dob!.year}'
            : widget.member.dateOfBirth,
        membershipDate:
            widget.member.membershipDate, // Keep existing membership date
        level: widget.loggedInUser.level,
        department: _selectedDepartment,
        baptismInformation: baptismInfo,
        profilePic: _imageBytes!,
      );

      // Submit to backend
      String result;
      if (_imageChanged && _fileExtension != null) {
        // If image was changed, send with new image
        result = await MemberController().updateMember(
          updatedMember.memberId!,
          updatedMember,
          userId: widget.loggedInUser.userId!,
          profilePic: _imageBytes!,
        );
      } else {
        // If image wasn't changed, send without image data
        result = await MemberController().updateMember(
          updatedMember.memberId!,
          updatedMember,
          userId: widget.loggedInUser.userId!,
        );
      }

      // Always stop loading after getting result
      if (mounted) setState(() => _isLoading = false);

      // Handle response
      if (!mounted) return;

      if (result == 'Status 1000') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member updated successfully')),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Navigator.pop(context, updatedMember);
        });
      } else if (result == 'Status 3000') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid department or baptism info')),
        );
      } else if (result == 'Status 4000') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Member not found')));
      } else if (result == 'Status 6000') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unauthorized role')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected error: $result')));
      }
    } catch (e) {
      // Always stop loading on error
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating member: $e')));
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
                child: _buildUpdateMemberScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateMemberScreen() {
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
                        "Update Member",
                        style: GoogleFonts.inter(
                          color: titlepageColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                              // Clear dependent fields when baptism status changes
                              if (val == 'Not Baptized') {
                                _sameReligion = null;
                                _selectedBaptismCell = null;
                                _otherChurchNameController.clear();
                                _otherChurchAddressController.clear();
                              }
                            });
                          },
                        ),

                        // Show Same Religion only when Baptized
                        if (_baptismStatus == 'Baptized')
                          _buildDropdown(
                            'Same Religion',
                            ['Yes', 'No'],
                            _sameReligion,
                            (val) {
                              setState(() {
                                _sameReligion = val;
                                // Clear dependent fields when same religion changes
                                if (val == 'Yes') {
                                  // Clear other church fields when switching to Yes
                                  _otherChurchNameController.clear();
                                  _otherChurchAddressController.clear();
                                } else if (val == 'No') {
                                  // Clear baptism cell when switching to No
                                  _selectedBaptismCell = null;
                                }
                              });
                            },
                          ),

                        // Show baptism cell only when baptized and same religion is Yes
                        if (_baptismStatus == 'Baptized' &&
                            _sameReligion == 'Yes')
                          _buildCellDropdown(
                            'Baptism Cell',
                            _selectedBaptismCell,
                            (cell) =>
                                setState(() => _selectedBaptismCell = cell),
                          ),

                        // Show other church fields only when baptized and same religion is No
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

                    /// Update Button
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
                                "Update",
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
      child: DropdownButtonFormField<Department>(
        value: selectedDepartment,
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
          ..._departments.map((department) {
            return DropdownMenuItem<Department>(
              value: department,
              child: Text(department.name),
            );
          }),
        ],
        onChanged: (Department? selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
        validator: (value) => value == null ? 'Required' : null,
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
                    initialSelectedDate: _dob ?? DateTime.now(),
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
                child: Text("Change Profile", style: GoogleFonts.inter()),
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
