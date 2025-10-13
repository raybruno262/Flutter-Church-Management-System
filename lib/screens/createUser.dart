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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _levelIdController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileExtension;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext =
          lookupMimeType(picked.path)?.split('/').last.toLowerCase() ?? 'jpg';

      print('Picked image path: ${picked.path}');
      print('Image size: ${bytes.length}');
      print('File extension: $ext');

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

      setState(() => _isLoading = true);

      try {
        final user = UserModel(
          names: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          nationalId: int.parse(_nationalIdController.text.trim()),
          role: 'ChapelAdmin',
          isActive: true,
          level: Level(levelId: _levelIdController.text.trim()),
          profilePic: _imageBytes!,
        );

        final result = await UserController().createUser(
          user,
          profilePic: _imageBytes!,
          fileExtension: _fileExtension!,
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
        ).showSnackBar(SnackBar(content: Text('Error creating user: $e')));
      }
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
              _buildTextField(_usernameController, 'Username'),
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
                Column(
                  children: [
                    Text('Image selected'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.memory(_imageBytes!, height: 150),
                    ),
                  ],
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
      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
    );
  }
}
