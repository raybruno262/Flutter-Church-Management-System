import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/equipment_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/provider/addEquipment_provider.dart';
import 'package:flutter_churchcrm_system/screens/equipmentCategoryScreen.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEquipmentScreen extends ConsumerStatefulWidget {
  final UserModel loggedInUser;

  const AddEquipmentScreen({super.key, required this.loggedInUser});

  @override
  ConsumerState<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends ConsumerState<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  EquipmentCategory? _selectedEquipmentCategory;
  final _purchaseDateController = TextEditingController();
  DateTime? _purchaseDate;
  final _priceController = TextEditingController();
  String? _condition;
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  Level? _equipmentselectedSuperAdminCell;

  @override
  void initState() {
    super.initState();
    // Data is now loaded by the provider automatically
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

  void _clearEquipmentForm() {
    // Reset form validation
    _formKey.currentState?.reset();
    // Clear text controllers
    _nameController.clear();
    _purchaseDateController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _priceController.clear();

    // Reset state variables
    setState(() {
      _purchaseDate = null;
      _condition = null;
      _selectedEquipmentCategory = null;
      _equipmentselectedSuperAdminCell = null;
    });

    // Clear form in provider
    ref.read(addEquipmentProvider.notifier).clearForm();
  }

  Future<void> _submitEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(addEquipmentProvider);
    final notifier = ref.read(addEquipmentProvider.notifier);

    // Validate name
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    // Validate category
    if (_selectedEquipmentCategory == null ||
        _selectedEquipmentCategory!.equipmentCategoryId == null) {
      return;
    }

    // Validate purchase price
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);
    if (price == null || price < 0) {
      return;
    }

    // Validate purchase date
    if (_purchaseDate != null && _purchaseDate!.isAfter(DateTime.now())) {
      return;
    }

    // Validate condition
    if (_condition == null) {
      return;
    }

    // Validate location
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      return;
    }

    // Validate description
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      return;
    }

    // Validate user ID
    if (widget.loggedInUser.userId == null) {
      return;
    }

    // Validate level
    final level = widget.loggedInUser.role == 'SuperAdmin'
        ? _equipmentselectedSuperAdminCell
        : widget.loggedInUser.level;

    if (level == null || level.levelId == null) {
      return;
    }

    // Use provider to add equipment
    final result = await notifier.addEquipment(
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
      userId: widget.loggedInUser.userId!,
    );

    // If successful, clear the form
    if (result == 'Status 1000') {
      _clearEquipmentForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addEquipmentProvider);
    final notifier = ref.read(addEquipmentProvider.notifier);
    final isDesktop = Responsive.isDesktop(context);

    // Auto-clear form when provider indicates it should be cleared
    if (state.isFormCleared) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _clearEquipmentForm();
      });
    }

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
                child: _buildAddEquipmentScreen(state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEquipmentScreen(
    AddEquipmentState state,
    AddEquipmentNotifier notifier,
  ) {
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
                        "Add Equipment",
                        style: GoogleFonts.inter(
                          color: titlepageColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message Container
                    if (state.message != null)
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
                              color: state.isSuccess
                                  ? Colors.green
                                  : Colors.red,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.isSuccess
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: state.isSuccess
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  state.message!,
                                  style: GoogleFonts.inter(
                                    color: state.isSuccess
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter equipment name';
                            }
                            return null;
                          },
                        ),
                        _buildEquipmentCategoryDropdown(
                          'Equipment Category',
                          _selectedEquipmentCategory,
                          (dept) =>
                              setState(() => _selectedEquipmentCategory = dept),
                          equipmentCategories: state.equipmentCategories,
                          notifier: notifier,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter purchase price';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null) {
                              return 'Please select condition';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Location',
                          _locationController,
                          readOnly: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Description',
                          _descriptionController,
                          readOnly: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        if (widget.loggedInUser.role == 'SuperAdmin') ...[
                          _buildEquipmentSuperAdminCellDropdown(
                            'Select Cell',
                            _equipmentselectedSuperAdminCell,
                            (cell) => setState(
                              () => _equipmentselectedSuperAdminCell = cell,
                            ),
                            cells: state.cells,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a cell';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 11),

                    /// Save Button
                    Center(
                      child: state.isLoading
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
                                "Save",
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
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: validator,
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
    Level? selectedSuperAdminCell,
    void Function(Level?) onChanged, {
    required List<Level> cells,
    String? Function(Level?)? validator,
  }) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<Level>(
        value: selectedSuperAdminCell,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: cells.map((cell) {
          return DropdownMenuItem<Level>(
            value: cell,
            child: Text(cell.name ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged, {
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        validator: validator,
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
    void Function(EquipmentCategory?) onChanged, {
    required List<EquipmentCategory> equipmentCategories,
    required AddEquipmentNotifier notifier,
  }) {
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
          ...equipmentCategories.map((equipmentCategory) {
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
              // Refresh categories after adding new one
              notifier.refreshEquipmentCategories();
            }
          } else if (selectedId == 'none') {
            setState(() {
              _selectedEquipmentCategory = null;
            });
          } else {
            final dept = equipmentCategories.firstWhere(
              (d) => d.equipmentCategoryId == selectedId,
              orElse: () => equipmentCategories.first,
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
