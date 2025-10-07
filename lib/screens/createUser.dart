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
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final mimeType = lookupMimeType(picked.path);
      final ext = mimeType?.split('/').last;

      setState(() {
        _imageBytes = bytes;
        _fileExtension = ext;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        names: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        nationalId: int.tryParse(_nationalIdController.text),
        role: 'ChapelAdmin',
        isActive: true,
        level: Level(levelId: _levelIdController.text),
      );

      final controller = UserController();
      final result = await controller.createUser(
        user,
        profilePic: _imageBytes,
        fileExtension: _fileExtension,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Future<void> _update() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = UserModel(
        names: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        nationalId: int.tryParse(_nationalIdController.text),
        role: 'ChapelAdmin',
        isActive: true,
        level: Level(levelId: _levelIdController.text),
      );

      final controller = UserController();
      final result = await controller.updateUser(
        '68e3ce8904f9d52aaf6c275d', // Replace with actual userId
        updatedUser,
        profilePic: _imageBytes,
        fileExtension: _fileExtension,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create / Update User'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 👈 Back to previous screen
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _nationalIdController,
                decoration: InputDecoration(labelText: 'National ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _levelIdController,
                decoration: InputDecoration(labelText: 'Level ID'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),
              if (_imageBytes != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.memory(_imageBytes!, height: 150),
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _submit, child: Text('Submit')),
                  ElevatedButton(
                    onPressed: _update,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    child: Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
