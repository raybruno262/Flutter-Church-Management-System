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

class AddMemberScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const AddMemberScreen({super.key, required this.loggedInUser});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  String? _selectedDepartmentId = 'none';
  List<Department> _departments = [];

  List<Level> _cells = [];
  Level? _selectedCell;
  final LevelController _levelController = LevelController();
  final DepartmentController _departmentController = DepartmentController();
  TextEditingController _dobController = TextEditingController();
  Country? _selectedCountry;

  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phonesaveController = TextEditingController();
  final _addressController = TextEditingController();
  final _otherChurchNameController = TextEditingController();
  final _otherChurchAddressController = TextEditingController();

  // State
  Uint8List? _imageBytes;
  String? _fileExtension;
  String? _maritalStatus;
  String? _gender;
  DateTime? _dob;
  String? _baptismStatus;
  String? _sameReligion;
  Department? _selectedDepartment;
  Level? _selectedBaptismCell;
  String? _loggedInUserId;
  Uint8List? _profilePic;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadCells();
    _loadUserId();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _loadUserId() async {
    final user = await UserController().loadUserFromStorage();
    if (user != null && user.userId != null) {
      setState(() {
        _loggedInUserId = user.userId!;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = lookupMimeType(picked.path)?.split('/').last;
      setState(() {
        _imageBytes = bytes;
        _fileExtension = ext;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null || _fileExtension == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a profile image')));
      return;
    }

    if (_loggedInUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found. Please log in again.')),
      );
      return;
    }

    final baptismInfo = BaptismInformation(
      baptized: _baptismStatus == "Baptized",
      sameReligion: _sameReligion == "Yes",
      baptismCell: _sameReligion == "Yes" ? _selectedBaptismCell : null,
      otherChurchName: _sameReligion == "No"
          ? _otherChurchNameController.text
          : null,
      otherChurchAddress: _sameReligion == "No"
          ? _otherChurchAddressController.text
          : null,
    );

    final member = Member(
      memberId: _idController.text,
      names: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      maritalStatus: _maritalStatus ?? '',
      gender: _gender ?? '',
      status: _baptismStatus ?? '',
      dateOfBirth: _dob?.toIso8601String(),
      department: _selectedDepartment,
      baptismInformation: baptismInfo,
    );

    final result = await MemberController().createMember(
      member,
      profilePic: _imageBytes!,
      fileExtension: _fileExtension!,
      userId: _loggedInUserId!,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));

    if (result == 'Status 1000') {
      Navigator.pop(context, result);
    }
  }

  Future<void> _loadCells() async {
    final cells = await _levelController.getAllCells();
    setState(() {
      _cells = cells;
    });
  }

  Future<void> _loadDepartments() async {
    final departments = await _departmentController.getAllDepartments();
    setState(() {
      _departments = departments;
    });
  }

  final TextEditingController _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

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
                  const SizedBox(height: 15),

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

                      _buildPhoneField(_phonesaveController),

                      _buildFilePicker(
                        previewBytes: _profilePic,
                        onPicked: (bytes, ext) {
                          setState(() {
                            _profilePic = bytes;
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
                        _selectedDepartmentId,
                        (deptId) =>
                            setState(() => _selectedDepartmentId = deptId),
                      ),

                      _buildDropdown(
                        'Baptism Status',
                        ['Baptized', 'Not Baptized'],
                        _baptismStatus,
                        (val) => setState(() => _baptismStatus = val),
                      ),

                      _buildDropdown(
                        'Same Religion',
                        ['Yes', 'No'],
                        _sameReligion,
                        (val) => setState(() => _sameReligion = val),
                      ),

                      _buildCellDropdown(
                        'Select Church',
                        _selectedCell,
                        (cell) => setState(() => _selectedCell = cell),
                      ),

                      _buildTextField(
                        'Other Church Name',
                        _otherChurchNameController,
                      ),
                      _buildTextField(
                        'Other Church Address',
                        _otherChurchAddressController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_profilePic == null || _fileExtension!.isEmpty) {
                          _showError("Please select a profile image");
                          return;
                        }

                        final user = await UserController()
                            .loadUserFromStorage();
                        if (user == null || user.userId == null) {
                          _showError("User not found. Please log in again.");
                          return;
                        }

                        final baptismInfo = BaptismInformation(
                          baptized: _baptismStatus == "Baptized",
                          sameReligion: _sameReligion == "Yes",
                          baptismCell: _sameReligion == "Yes"
                              ? _selectedBaptismCell
                              : null,
                          otherChurchName: _sameReligion == "No"
                              ? _otherChurchNameController.text
                              : null,
                          otherChurchAddress: _sameReligion == "No"
                              ? _otherChurchAddressController.text
                              : null,
                        );

                        final member = Member(
                          memberId: _idController.text,
                          names: _nameController.text,
                          email: _emailController.text,
                          address: _addressController.text,
                          phone: _phoneController.text,
                          maritalStatus: _maritalStatus ?? '',
                          gender: _gender ?? '',
                          status: _baptismStatus ?? '',
                          dateOfBirth: _dob?.toIso8601String(),
                          department: _selectedDepartment,
                          baptismInformation: baptismInfo,
                        );

                        if (_fileExtension == null || _profilePic == null) {
                          _showError("Please select a profile image");
                          return;
                        }

                        final ext = _fileExtension!;
                        final result = await MemberController().createMember(
                          member,
                          profilePic: _profilePic!,
                          fileExtension: ext,
                          userId: user.userId!,
                        );

                        if (result == 'Status 1000') {
                          _showSuccess("Member created successfully");
                        } else {
                          _showError("Error: $result");
                        }
                      },
                      child: Text(
                        "Save",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
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
                    ),
                  ),
                ],
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

  Widget _buildCellDropdown(
    String label,
    Level? selectedCell,
    void Function(Level?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        initialValue: _selectedCell,
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
            child: Text(cell.name ?? 'None'),
          );
        }).toList(),
        onChanged: (Level? selected) {
          setState(() {
            _selectedCell = selected;
          });
        },
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: _phoneController,
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
                      _selectedCountry != null
                          ? _selectedCountry!.flagEmoji
                          : '🇷🇼',
                      style: GoogleFonts.inter(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry != null
                          ? '+${_selectedCountry!.phoneCode}'
                          : '+250',
                      style: GoogleFonts.inter(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown(
    String label,
    String? selectedId,
    void Function(String?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        initialValue: _selectedDepartmentId ?? 'none',
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
            return DropdownMenuItem(
              value: department.departmentId,
              child: Text(department.name),
            );
          }),
          const DropdownMenuItem(value: 'others', child: Text('Others')),
        ],
        onChanged: (String? selectedId) {
          if (selectedId == 'others') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DepartmentScreen(loggedInUser: widget.loggedInUser),
              ),
            );
          } else {
            setState(() {
              _selectedDepartmentId = selectedId;
            });
          }
        },
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
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          suffixIcon: Icon(Icons.calendar_today),
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
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      final DateTime selected = args.value;
                      setState(() {
                        _dobController.text =
                            "${selected.month}/${selected.day}/${selected.year}";
                      });
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

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
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
        onChanged: (value) {},
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
                onPressed: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    final bytes = await pickedFile.readAsBytes();

                    // Try MIME type first
                    String? ext = lookupMimeType(
                      pickedFile.path,
                    )?.split('/').last;

                    // Fallback to file extension from path
                    ext ??= pickedFile.path.split('.').last.toLowerCase();

                    onPicked(bytes, ext);
                  }
                },
                child: Text("Choose Profile", style: GoogleFonts.inter()),
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
