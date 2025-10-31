import 'dart:typed_data';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/controller/visitor_controller.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/model/visitor_model.dart';
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

class UpdateVisitorScreen extends StatefulWidget {
  final UserModel loggedInUser;
  final Visitor visitor;

  const UpdateVisitorScreen({
    super.key,
    required this.loggedInUser,
    required this.visitor,
  });

  @override
  State<UpdateVisitorScreen> createState() => _UpdateVisitorScreenState();
}

class _UpdateVisitorScreenState extends State<UpdateVisitorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _visitDateController = TextEditingController();

  // Data lists
  List<Level> _levels = [];
  List<Level> _chapels = [];

  // Controllers
  final LevelController _levelController = LevelController();
  final VisitorController _visitorController = VisitorController();

  // State variables
  bool _isLoading = false;
  bool _imageChanged = false;
  Uint8List? _imageBytes;
  String? _fileExtension;
  String? _gender;
  DateTime? _visitDate;
  String? _status;
  Level? _selectedLevel;
  Level? _selectedSuperAdminLevel;
  Country? _selectedCountry;

  // Message state variables
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadLevels();
    _loadChapels();
    _populateExistingData();
  }

  void _populateExistingData() {
    // Populate text fields
    _nameController.text = widget.visitor.names;
    _emailController.text = widget.visitor.email;
    _addressController.text = widget.visitor.address;

    // Parse and populate phone number
    final phone = widget.visitor.phone;
    if (phone.isNotEmpty) {
      // Remove leading '+' if present
      final normalized = phone.startsWith('+') ? phone.substring(1) : phone;

      // Remove country code (assumed to be 250 for Rwanda)
      if (normalized.startsWith('250')) {
        _phoneController.text = normalized.substring(3); // Strip '250'
      } else {
        _phoneController.text = normalized; // Use full number if no match
      }
    }

    // Populate gender and status
    _gender = widget.visitor.gender;
    _status = widget.visitor.status;

    // Parse and populate visit date
    if (widget.visitor.visitDate != null &&
        widget.visitor.visitDate!.isNotEmpty) {
      try {
        List<String> parts = widget.visitor.visitDate!.split('/');
        if (parts.length == 3) {
          int month = int.parse(parts[0]);
          int day = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          _visitDate = DateTime(year, month, day);
          _visitDateController.text = widget.visitor.visitDate!;
        }
      } catch (e) {
        print('Error parsing visit date: $e');
      }
    }

    // Set level (will be matched when levels load)
    _selectedLevel = widget.visitor.level;
    _selectedSuperAdminLevel = widget.visitor.level;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _visitDateController.dispose();
    super.dispose();
  }

  Future<void> _loadChapels() async {
    final chapels = await _levelController.getAllChapels();
    if (mounted) {
      setState(() => _chapels = chapels);
    }
  }

  Future<void> _loadLevels() async {
    final levels = await _levelController.getAllLevels();
    if (mounted) {
      setState(() {
        _levels = levels;
        // Match existing level if it exists
        if (widget.visitor.level != null) {
          _selectedLevel = _levels.firstWhere(
            (level) => level.levelId == widget.visitor.level!.levelId,
            orElse: () => widget.visitor.level!,
          );
          _selectedSuperAdminLevel = _selectedLevel;
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

    // Email format validation
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() {
          _message = 'Please enter a valid email address';
          _isSuccess = false;
        });
        return;
      }
    }

    // Validate image
    if (_imageBytes == null) {
      setState(() {
        _message = 'Please select a profile image';
        _isSuccess = false;
      });
      return;
    }

    // Validate level for SuperAdmin
    if (widget.loggedInUser.role == 'SuperAdmin' &&
        _selectedSuperAdminLevel == null) {
      setState(() {
        _message = 'Please select a level for this visitor';
        _isSuccess = false;
      });
      return;
    }

    // Validate level for ChapelAdmin
    if (widget.loggedInUser.role == 'ChapelAdmin' && _selectedLevel == null) {
      setState(() {
        _message = 'Please select a level for this visitor';
        _isSuccess = false;
      });
      return;
    }

    // Validate gender
    if (_gender == null) {
      setState(() {
        _message = 'Please select gender';
        _isSuccess = false;
      });
      return;
    }

    // Validate status
    if (_status == null) {
      setState(() {
        _message = 'Please select visitor status';
        _isSuccess = false;
      });
      return;
    }

    // Validate visit date
    if (_visitDate == null) {
      setState(() {
        _message = 'Please select visit date';
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

      // Build phone number with country code
      final phoneCode = _selectedCountry != null
          ? '+${_selectedCountry!.phoneCode}'
          : '+250';
      final fullPhone = '$phoneCode${_phoneController.text.trim()}';

      // Format visit date
      final formattedVisitDate = _visitDate != null
          ? '${_visitDate!.month.toString().padLeft(2, '0')}/'
                '${_visitDate!.day.toString().padLeft(2, '0')}/'
                '${_visitDate!.year}'
          : '';

      // Create updated visitor object
      final updatedVisitor = Visitor(
        visitorId: widget.visitor.visitorId, // Keep existing ID
        names: _nameController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        phone: fullPhone,
        gender: _gender ?? '',
        status: _status ?? '',
        visitDate: formattedVisitDate,
        level: widget.loggedInUser.role == 'SuperAdmin'
            ? _selectedSuperAdminLevel
            : _selectedLevel,
        followUp: widget.visitor.followUp, // Keep existing follow-ups
      );

      // Submit to backend
      String result;

      if (_imageChanged && _fileExtension != null) {
        result = await VisitorController().updateVisitor(
          visitorId: updatedVisitor.visitorId!,
          updatedVisitor: updatedVisitor,
          userId: widget.loggedInUser.userId!,
        );
      } else {
        result = await VisitorController().updateVisitor(
          visitorId: updatedVisitor.visitorId!,
          updatedVisitor: updatedVisitor,
          userId: widget.loggedInUser.userId!,
        );
      }

      // Always stop loading after getting result
      if (mounted) setState(() => _isLoading = false);

      // Handle response
      if (!mounted) return;

      if (result == 'Status 1000') {
        setState(() {
          _message = 'Visitor updated successfully';
          _isSuccess = true;
        });
      } else if (result == 'Status 3000') {
        setState(() {
          _message = 'Invalid level information';
          _isSuccess = false;
        });
      } else if (result == 'Status 4000') {
        setState(() {
          _message = 'Visitor not found';
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
          _message = 'Error updating visitor: $e';
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
                selectedTitle: 'Visitors',
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
                  selectedTitle: 'Visitors',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildUpdateVisitorScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateVisitorScreen() {
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
                        "Update Visitor",
                        style: GoogleFonts.inter(
                          color: titlepageColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

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
                    const SizedBox(height: 10),

                    /// Visitor Information Section
                    Text(
                      "Visitor Information",
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
                        _buildTextField(
                          'Email',
                          _emailController,
                          optional: true,
                        ),
                        _buildDropdown(
                          'Gender',
                          ['Male', 'Female'],
                          _gender,
                          (val) => setState(() => _gender = val),
                        ),
                        _buildDatePickerField(
                          'Visit Date (MM/dd/yyyy)',
                          _visitDateController,
                          (date) => setState(() {
                            _visitDate = date;
                            _visitDateController.text =
                                "${date.month}/${date.day}/${date.year}";
                          }),
                        ),
                        _buildTextField('Address', _addressController),
                        _buildPhoneField(_phoneController),

                        // Level selection based on user role
                        if (widget.loggedInUser.role == 'SuperAdmin')
                          _buildSuperAdminLevelDropdown(
                            'Select Level',
                            _selectedSuperAdminLevel,
                            (level) => setState(
                              () => _selectedSuperAdminLevel = level,
                            ),
                          )
                        else
                          _buildLevelDropdown(
                            'Select Level',
                            _selectedLevel,
                            (level) => setState(() => _selectedLevel = level),
                          ),

                        _buildDropdown(
                          'Status',
                          ['New', 'Follow-up', 'Converted', 'Dropped'],
                          _status,
                          (val) => setState(() => _status = val),
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
                                "Update Visitor",
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool optional = false,
  }) {
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
        validator: optional
            ? null
            : (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildLevelDropdown(
    String label,
    Level? selectedLevel,
    void Function(Level?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: selectedLevel,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _levels.map((level) {
          return DropdownMenuItem<Level>(
            value: level,
            child: Text(level.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildSuperAdminLevelDropdown(
    String label,
    Level? selectedLevel,
    void Function(Level?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: selectedLevel,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: _levels.map((level) {
          return DropdownMenuItem<Level>(
            value: level,
            child: Text(level.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
        menuMaxHeight: 250,
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
                    initialSelectedDate: _visitDate ?? DateTime.now(),
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
