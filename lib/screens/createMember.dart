import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter_churchcrm_system/model/member_model.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/baptismInformation_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/controller/member_controller.dart';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';

class CreateMemberPage extends StatefulWidget {
  @override
  _CreateMemberPageState createState() => _CreateMemberPageState();
}

class _CreateMemberPageState extends State<CreateMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _otherChurchNameController = TextEditingController();
  final _otherChurchAddressController = TextEditingController();
  final _levelIdController = TextEditingController();
  final _userIdController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileExtension;
  bool _isLoading = false;

  String? _gender;
  String? _maritalStatus;
  String? _baptismStatus;
  String? _sameReligion;
  Department? _selectedDepartment;
  Level? _selectedBaptismCell;

  List<Department> _departments = [];
  List<Level> _cells = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadCells();
  }

  Future<void> _loadDepartments() async {
    final result = await DepartmentController().getAllDepartments();
    setState(() => _departments = result);
  }

  Future<void> _loadCells() async {
    final result = await LevelController().getAllLevels();
    setState(() => _cells = result);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext =
          lookupMimeType(picked.path)?.split('/').last?.toLowerCase() ?? 'jpg';
      setState(() {
        _imageBytes = bytes;
        _fileExtension = ext;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_imageBytes == null ||
          _fileExtension == null ||
          _fileExtension!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a profile image')),
        );
        return;
      }

      if (_selectedDepartment == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select a department')));
        return;
      }

      if (_sameReligion == 'Yes' && _selectedBaptismCell == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select a baptism cell')));
        return;
      }

      setState(() => _isLoading = true);

      try {
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

        final member = Member(
          names: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _gender ?? '',
          maritalStatus: _maritalStatus ?? '',
          status: 'Active',
          address: _addressController.text.trim(),
          profilePic: _imageBytes!,
          level: Level(levelId: _levelIdController.text.trim()),
          department: _selectedDepartment,
          baptismInformation: baptismInfo,
        );

        final result = await MemberController().createMember(
          member,
          profilePic: _imageBytes!,
          fileExtension: _fileExtension!,
          userId: _userIdController.text.trim(),
        );

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));

        if (result == 'Status 1000') {
          Navigator.pop(context, result);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating member: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Member')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_phoneController, 'Phone'),
              _buildDropdown(
                'Gender',
                ['Male', 'Female'],
                _gender,
                (val) => setState(() => _gender = val),
              ),
              _buildDropdown(
                'Marital Status',
                ['Single', 'Married', 'Divorced'],
                _maritalStatus,
                (val) => setState(() => _maritalStatus = val),
              ),
              _buildTextField(_addressController, 'Address'),
              _buildDropdown(
                'Department',
                _departments.map((d) => d.name).toList(),
                _selectedDepartment?.name,
                (val) {
                  final dept = _departments.firstWhere((d) => d.name == val);
                  setState(() => _selectedDepartment = dept);
                },
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

              if (_sameReligion == 'Yes')
                _buildDropdown(
                  'Baptism Cell',
                  _cells.map((c) => c.levelId ?? '').toList(),
                  _selectedBaptismCell?.levelId,
                  (val) {
                    final cell = _cells.firstWhere((c) => c.levelId == val);
                    setState(() => _selectedBaptismCell = cell);
                  },
                ),

              if (_sameReligion == 'No') ...[
                _buildTextField(
                  _otherChurchNameController,
                  'Other Church Name',
                ),
                _buildTextField(
                  _otherChurchAddressController,
                  'Other Church Address',
                ),
              ],

              _buildTextField(_levelIdController, 'Level ID'),
              _buildTextField(_userIdController, 'User ID'),

              SizedBox(height: 16),
              ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),

              if (_imageBytes != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.memory(_imageBytes!, height: 150),
                ),

              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _submit, child: Text('Create')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
