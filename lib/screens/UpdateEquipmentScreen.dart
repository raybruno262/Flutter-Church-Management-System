import 'package:flutter_churchcrm_system/controller/equipmentCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/equipment_controller.dart';

import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/equipment_model.dart';

import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/screens/equipmentCategoryScreen.dart';

import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:flutter/material.dart';

import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';

import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateEquipmentScreen extends StatefulWidget {
  final UserModel loggedInUser;
  final Equipment equipment;
  const UpdateEquipmentScreen({
    super.key,
    required this.loggedInUser,
    required this.equipment,
  });

  @override
  State<UpdateEquipmentScreen> createState() => _UpdateEquipmentScreenState();
}

class _UpdateEquipmentScreenState extends State<UpdateEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<EquipmentCategory> _equipmentCategories = [];
  EquipmentCategory? _selectedEquipmentCategory;
  final _purchaseDateController = TextEditingController();
  DateTime? _purchaseDate;
  final _priceController = TextEditingController();
  String? _condition;
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final LevelController _levelController = LevelController();
  List<Level> _cells = [];
  Level? _equipmentselectedSuperAdminCell;
  final EquipmentCategoryController _equipmentCatController =
      EquipmentCategoryController();
  final EquipmentController _equipmentController = EquipmentController();

  bool _isLoading = false;

  // Message state variables
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load all data first
    await Future.wait([_loadEquipmentCategories(), _loadCells()]);

    // Then populate the form
    if (mounted) {
      setState(() {
        _populateFormFromEquipment();
      });
    }
  }

  void _populateFormFromEquipment() {
    _nameController.text = widget.equipment.name;

    if (widget.equipment.equipmentCategory.equipmentCategoryId != null) {
      final category = _equipmentCategories.firstWhere(
        (cat) =>
            cat.equipmentCategoryId ==
            widget.equipment.equipmentCategory.equipmentCategoryId,
        orElse: () => widget.equipment.equipmentCategory,
      );
      setState(() {
        _selectedEquipmentCategory = category;
      });
    }
    try {
      DateTime? parsedDate;
      if (widget.equipment.purchaseDate.contains('/')) {
        List<String> parts = widget.equipment.purchaseDate.split('/');
        if (parts.length == 3) {
          int month = int.parse(parts[0]);
          int day = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          parsedDate = DateTime(year, month, day);
        }
      } else {
        parsedDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(widget.equipment.purchaseDate);
      }

      if (parsedDate != null) {
        setState(() {
          _purchaseDate = parsedDate;
        });
        _purchaseDateController.text = DateFormat(
          'MM/dd/yyyy',
        ).format(parsedDate);
      }
    } catch (e) {
      print('Error parsing Date');
    }

    _priceController.text = widget.equipment.purchasePrice.toString();
    _condition = widget.equipment.condition;
    _locationController.text = widget.equipment.location!;
    _descriptionController.text = widget.equipment.description!;

    if (widget.loggedInUser.role == 'SuperAdmin' &&
        widget.equipment.level != null) {
      setState(() {
        _equipmentselectedSuperAdminCell = widget.equipment.level;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseDateController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _loadCells() async {
    final cells = await _levelController.getAllCells();
    if (mounted) {
      setState(() => _cells = cells);
    }
  }

  Future<void> _loadEquipmentCategories() async {
    final equipmentCategory = await _equipmentCatController
        .getAllEquipmentCategories();
    if (mounted) {
      setState(() => _equipmentCategories = equipmentCategory);
    }
  }

  Future<void> _submitEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _message = null;
      _isSuccess = false;
    });

    // Validate name
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _message = 'Please enter equipment name';
        _isSuccess = false;
      });
      return;
    }

    // Validate category
    if (_selectedEquipmentCategory == null ||
        _selectedEquipmentCategory!.equipmentCategoryId == null) {
      setState(() {
        _message = 'Please select a valid equipment category';
        _isSuccess = false;
      });
      return;
    }

    // Validate purchase price
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);
    if (price == null || price < 0) {
      setState(() {
        _message = 'Please enter a valid purchase price';
        _isSuccess = false;
      });
      return;
    }

    // Validate purchase date
    if (_purchaseDate != null && _purchaseDate!.isAfter(DateTime.now())) {
      setState(() {
        _message = 'Purchase date cannot be in the future';
        _isSuccess = false;
      });
      return;
    }

    // Validate condition
    if (_condition == null) {
      setState(() {
        _message = 'Please select equipment condition';
        _isSuccess = false;
      });
      return;
    }

    // Validate location
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      setState(() {
        _message = 'Please enter equipment location';
        _isSuccess = false;
      });
      return;
    }

    // Validate description
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _message = 'Please enter equipment description';
        _isSuccess = false;
      });
      return;
    }

    // Validate user ID
    if (widget.loggedInUser.userId == null) {
      setState(() {
        _message = 'User session expired. Please log in again.';
        _isSuccess = false;
      });
      return;
    }

    // Validate level
    final level = widget.loggedInUser.role == 'SuperAdmin'
        ? _equipmentselectedSuperAdminCell
        : widget.loggedInUser.level;

    if (level == null || level.levelId == null) {
      setState(() {
        _message = widget.loggedInUser.role == 'SuperAdmin'
            ? 'Please select a cell for this equipment'
            : 'You are not allowed to add equipment';
        _isSuccess = false;
      });
      return;
    }

    try {
      final equipment = Equipment(
        name: name,
        equipmentCategory: _selectedEquipmentCategory!,
        purchaseDate: _purchaseDate != null
            ? DateFormat('yyyy-MM-dd').format(_purchaseDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
        purchasePrice: price,
        condition: _condition!,
        location: location,
        description: description,
        level: level,
      );

      final result = await _equipmentController.updateEquipment(
        widget.equipment.equipmentId!,
        equipment,
        widget.loggedInUser.userId!,
      );

      setState(() => _isLoading = false);

      switch (result) {
        case 'Status 1000':
          setState(() {
            _message = 'Equipment updated successfully!';
            _isSuccess = true;
          });
          break;
        case 'Status 3000':
          setState(() {
            _message = 'Invalid equipment data';
            _isSuccess = false;
          });
          break;
        case 'Status 4000':
          setState(() {
            _message = 'User not found. Please log in again.';
            _isSuccess = false;
          });
          break;
        case 'Status 6000':
          setState(() {
            _message = 'You are not authorized to create equipment records.';
            _isSuccess = false;
          });
          break;
        case 'Status 2000':
          setState(() {
            _message = 'Server error. Please try again later.';
            _isSuccess = false;
          });
          break;
        default:
          setState(() {
            _message = 'Unexpected error';
            _isSuccess = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Network error. Please check your connection and try again.';
        _isSuccess = false;
      });
      print('Error submitting equipment');
    } finally {
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
                child: _buildUpdateEquipmentScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateEquipmentScreen() {
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
                        "Add Equipment ",
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

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextField(
                          'Name',
                          _nameController,
                          readOnly: false,
                        ),
                        _buildEquipmentCategoryDropdown(
                          'Equipment Category',
                          _selectedEquipmentCategory,
                          (dept) =>
                              setState(() => _selectedEquipmentCategory = dept),
                        ),
                        _buildDatePickerField(
                          context,
                          'Purchase Date (MM/dd/yyyy)',
                          _purchaseDateController,
                          (date) => setState(() {
                            _purchaseDate = date;
                            _purchaseDateController.text = DateFormat(
                              'MM/dd/yyyy',
                            ).format(date);
                          }),
                          _purchaseDate,
                        ),

                        _buildTextField(
                          'Price',
                          _priceController,
                          readOnly: false,
                        ),
                        _buildDropdown(
                          'Condition',
                          [
                            'Excellent',
                            'Good',
                            'Needs Repair',
                            'Out of Service',
                          ],
                          _condition,
                          (val) => setState(() => _condition = val),
                        ),
                        _buildTextField(
                          'Location',
                          _locationController,
                          readOnly: false,
                        ),
                        _buildTextField(
                          'Description',
                          _descriptionController,
                          readOnly: false,
                        ),

                        if (widget.loggedInUser.role == 'SuperAdmin') ...[
                          _buildEquipmentSuperAdminCellDropdown(
                            'Select Cell',
                            _equipmentselectedSuperAdminCell,
                            (cell) => setState(
                              () => _equipmentselectedSuperAdminCell = cell,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 11),

                    /// Save Button
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitEquipment,
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
                                "Save ",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
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
    required bool readOnly,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
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

  Widget _buildEquipmentSuperAdminCellDropdown(
    String label,
    Level? selectedCell,
    void Function(Level?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value:
            selectedCell?.levelId, // Use levelId as value for proper comparison
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
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Select Cell'),
          ),
          ..._cells.map((cell) {
            return DropdownMenuItem<String>(
              value: cell.levelId,
              child: Text(cell.name ?? 'Unknown'),
            );
          }).toList(),
        ],
        onChanged: (String? selectedId) {
          if (selectedId == null) {
            onChanged(null);
          } else {
            final selectedLevel = _cells.firstWhere(
              (cell) => cell.levelId == selectedId,
            );
            onChanged(selectedLevel);
          }
        },
        menuMaxHeight: 250,
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
      ),
    );
  }

  Widget _buildEquipmentCategoryDropdown(
    String label,
    EquipmentCategory? selectedEquipmentCategory,
    void Function(EquipmentCategory?) onChanged,
  ) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: selectedEquipmentCategory?.equipmentCategoryId ?? 'none',
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
          const DropdownMenuItem(
            value: 'none',
            child: Text('Select Equipment Category'),
          ),
          ..._equipmentCategories.map((equipmentCategory) {
            return DropdownMenuItem<String>(
              value: equipmentCategory.equipmentCategoryId,
              child: Text(equipmentCategory.name),
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
                    EquipmentCategoryScreen(loggedInUser: widget.loggedInUser),
              ),
            );
            if (result != null) {
              await _loadEquipmentCategories();
            }
          } else if (selectedId == 'none') {
            setState(() {
              _selectedEquipmentCategory = null;
            });
          } else {
            final dept = _equipmentCategories.firstWhere(
              (d) => d.equipmentCategoryId == selectedId,
              orElse: () => _equipmentCategories.first,
            );
            setState(() {
              _selectedEquipmentCategory = dept;
            });
            onChanged(dept);
          }
        },

        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    String label,
    TextEditingController controller,
    void Function(DateTime) onDateSelected,
    DateTime? initialDate,
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
          DateTime tempSelectedDate = initialDate ?? DateTime.now();

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
                    initialSelectedDate: tempSelectedDate,
                    minDate: DateTime(1900),
                    maxDate: DateTime.now(),
                    showActionButtons: true,
                    onSelectionChanged: (args) {
                      tempSelectedDate = args.value;
                    },
                    onSubmit: (value) {
                      final selected = value as DateTime;
                      controller.text = DateFormat(
                        'MM/dd/yyyy',
                      ).format(selected);
                      onDateSelected(selected);
                      Navigator.pop(context);
                    },
                    onCancel: () {
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
}
