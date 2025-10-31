import 'dart:io';
import 'package:flutter_churchcrm_system/controller/equipmentCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

class AddEquipmentCategoryScreen extends StatefulWidget {
  final UserModel loggedInUser;

  const AddEquipmentCategoryScreen({super.key, required this.loggedInUser});

  @override
  State<AddEquipmentCategoryScreen> createState() =>
      _AddEquipmentCategoryScreenState();
}

class _AddEquipmentCategoryScreenState
    extends State<AddEquipmentCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController userController = UserController();
  final EquipmentCategoryController equipmentCategoryController =
      EquipmentCategoryController();

  // Controllers
  final _nameController = TextEditingController();

  // ignore: unused_field
  bool _isClearing = false;
  void _clearoneForm() {
    _isClearing = true;
    setState(() {
      // Reset form validation
      _formKey.currentState?.reset();
    });

    _isClearing = false;
  }

  // State variables
  bool _isLoading = false;
  bool _isUploading = false;

  // Message state variables
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addEquipmentCategory() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _message = 'Please enter equipment category name';
        _isSuccess = false;
      });
      return;
    }

    final equipmentCategoryName = _nameController.text.trim();

    try {
      setState(() {
        _isLoading = true;
      });

      final newEquipmentCategory = EquipmentCategory(
        name: equipmentCategoryName,
      );

      final result = await equipmentCategoryController.createEquipmentCategory(
        newEquipmentCategory,
      );

      if (result == 'Status 1000') {
        setState(() {
          _message = 'Equipment Category created successfully!';
          _isSuccess = true;
        });
        _clearoneForm();
      } else if (result == 'Status 5000') {
        setState(() {
          _message = 'Equipment Category name already exists';
          _isSuccess = false;
        });
      } else if (result == 'Status 7000') {
        setState(() {
          _message = 'Network error';
          _isSuccess = false;
        });
      } else {
        setState(() {
          _message = 'Unexpected error';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error creating Equipment Category';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Excel file upload
  Future<void> _uploadExcelFile() async {
    try {
      print('=== FILE UPLOAD START ===');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null) {
        print('User canceled file selection');
        return;
      }

      if (result.files.isEmpty) {
        setState(() {
          _message = 'No file selected';
          _isSuccess = false;
        });
        return;
      }

      PlatformFile platformFile = result.files.first;

      print('File details:');
      print('- Name: ${platformFile.name}');
      print('- Size: ${platformFile.size} bytes');
      print('- Bytes available: ${platformFile.bytes != null}');
      print('- Path: ${platformFile.path}');

      if (platformFile.bytes == null) {
        setState(() {
          _message = 'Could not read file data. Please try another file.';
          _isSuccess = false;
        });
        return;
      }

      setState(() {
        _isUploading = true;
        _message = 'Uploading ${platformFile.name}...';
        _isSuccess = false;
      });

      // Call the controller with PlatformFile
      final response = await equipmentCategoryController
          .uploadExcelEquipmentCategory(platformFile);

      print('Upload response received: $response');

      // Parse the response and set appropriate message
      _handleUploadResponse(response);
    } catch (e) {
      print('ERROR in _uploadExcelFile: $e');
      print('Error type: ${e.runtimeType}');
      setState(() {
        _message = 'Error during file upload: ${e.toString()}';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
      print('=== FILE UPLOAD END ===');
    }
  }

  //  Handle the upload response based on Spring backend messages
  void _handleUploadResponse(String response) {
    if (response.contains('Status 1000')) {
      // Success case - extract the detailed message
      setState(() {
        _message = response.replaceFirst('Status 1000: ', '');
        _isSuccess = true;
      });
    } else if (response.contains('Status 4000')) {
      setState(() {
        _message = 'File is empty. Please select a valid Excel file.';
        _isSuccess = false;
      });
    } else if (response.contains('Status 4001')) {
      setState(() {
        _message = 'Please upload an Excel file (.xlsx or .xls format).';
        _isSuccess = false;
      });
    } else if (response.contains('Status 4002')) {
      setState(() {
        _message =
            'No valid data found in the Excel file. Please check the file format.';
        _isSuccess = false;
      });
    } else if (response.contains('Status 5000')) {
      // Extract duplicate names from the message
      final duplicateMessage = response.replaceFirst('Status 5000: ', '');
      setState(() {
        _message = duplicateMessage;
        _isSuccess = false;
      });
    } else if (response.contains('Status 2000')) {
      setState(() {
        _message = 'Error processing the file. Please try again.';
        _isSuccess = false;
      });
    } else if (response.contains('Status 9999')) {
      setState(() {
        _message = 'Unexpected error occurred. Please contact support.';
        _isSuccess = false;
      });
    } else if (response.contains('Status 7000')) {
      setState(() {
        _message = 'Network error. Please check your connection and try again.';
        _isSuccess = false;
      });
    } else {
      setState(() {
        _message = response;
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? Drawer(
              child: SideMenuWidget(
                selectedTitle: 'Equipment',
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
                  selectedTitle: 'Equipment',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildAddEquipmentCategoryScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEquipmentCategoryScreen() {
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
                        "Add Equipment Category",
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

                    // Back Button
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

                    // Excel Upload Section
                    Card(
                      elevation: 2,
                      color: containerColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upload via Excel",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Upload an Excel file to add multiple equipment categories at once.",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUploading
                                        ? null
                                        : _uploadExcelFile,
                                    icon: _isUploading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(Icons.upload_file),
                                    label: Text(
                                      _isUploading
                                          ? 'Uploading...'
                                          : 'Upload Excel File',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Supported formats: .xlsx, .xls\nExcel should have 'Category Name' in the first column starting from row 2",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),

                    // Manual Entry Section
                    Center(
                      child: Text(
                        "Or Add Manually",
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [_buildTextField('Name', _nameController)],
                    ),

                    const SizedBox(height: 10),

                    /// Save Button
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _addEquipmentCategory,
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
      ),
    );
  }
}
