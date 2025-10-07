import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';

class CreateUserPage extends StatefulWidget {
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _levelIdController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileExtension;

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
    if (_formKey.currentState!.validate()) {
      if (_imageBytes == null || _fileExtension == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a profile image')),
        );
        return;
      }

      final user = UserModel(
        names: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        nationalId: int.parse(_nationalIdController.text),
        role: 'ChapelAdmin',
        isActive: true,
        level: Level(levelId: _levelIdController.text),
        profilePic: _imageBytes!,
      );

      final result = await UserController().createUser(
        user,
        profilePic: _imageBytes!,
        fileExtension: _fileExtension!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));

      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Member')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
              if (_imageBytes != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.memory(_imageBytes!, height: 150),
                ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: Text('Create')),
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
