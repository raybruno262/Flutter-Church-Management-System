import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';

class UpdateUserPage extends StatefulWidget {
  final UserModel user;
  UpdateUserPage({required this.user});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalIdController;
  late TextEditingController _levelIdController;

  late Uint8List _imageBytes;
  String? _fileExtension;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.names);
    _emailController = TextEditingController(text: u.email);
    _passwordController = TextEditingController(text: u.password);
    _phoneController = TextEditingController(text: u.phone);
    _nationalIdController = TextEditingController(
      text: u.nationalId.toString(),
    );
    _levelIdController = TextEditingController(text: u.level.levelId);
    _imageBytes = u.profilePic;

    // Try to infer file extension from existing image
    _fileExtension ??=
        lookupMimeType('', headerBytes: _imageBytes)?.split('/').last ?? 'png';
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = lookupMimeType(picked.path)?.split('/').last;
      setState(() {
        _imageBytes = bytes;
        _fileExtension = ext ?? 'png';
      });
    }
  }

  Future<void> _update() async {
    if (_imageBytes.isEmpty || _fileExtension == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid profile image')),
      );
      return;
    }

    final updatedUser = UserModel(
      userId: widget.user.userId,
      names: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      nationalId: int.parse(_nationalIdController.text),
      role: widget.user.role,
      isActive: widget.user.isActive,
      level: Level(levelId: _levelIdController.text),
      profilePic: _imageBytes,
    );

    final result = await UserController().updateUser(
      widget.user.userId!,
      updatedUser,
      profilePic: _imageBytes,
      fileExtension: _fileExtension!,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Member')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_passwordController, 'Password', obscure: true),
              _buildTextField(_phoneController, 'Phone'),
              _buildTextField(
                _nationalIdController,
                'National ID',
                number: true,
              ),
              _buildTextField(_levelIdController, 'Level ID'),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.memory(_imageBytes, height: 150),
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _update, child: Text('Update')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    bool number = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscure,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
