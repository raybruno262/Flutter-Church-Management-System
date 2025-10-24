import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/equipment_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/provider/updateEquipment_provider.dart';
import 'package:flutter_churchcrm_system/screens/equipmentCategoryScreen.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateEquipmentScreen extends ConsumerStatefulWidget {
  final UserModel loggedInUser;
  final Equipment equipment;

  const UpdateEquipmentScreen({
    super.key,
    required this.loggedInUser,
    required this.equipment,
  });

  @override
  ConsumerState<UpdateEquipmentScreen> createState() =>
      _UpdateEquipmentScreenState();
}

class _UpdateEquipmentScreenState extends ConsumerState<UpdateEquipmentScreen> {
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
    // Set the equipment in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateEquipmentProvider.notifier).setEquipment(widget.equipment);
      _populateExistingData();
    });
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

  void _populateExistingData() {
    final state = ref.read(updateEquipmentProvider);

    _nameController.text = widget.equipment.name;

    // Set equipment category
    if (widget.equipment.equipmentCategory.equipmentCategoryId != null) {
      final category = state.equipmentCategories.firstWhere(
        (cat) =>
            cat.equipmentCategoryId ==
            widget.equipment.equipmentCategory.equipmentCategoryId,
        orElse: () => widget.equipment.equipmentCategory,
      );
      setState(() {
        _selectedEquipmentCategory = category;
      });
    }

    // Parse and set purchase date
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
      print('Error parsing date: $e');
    }

    _priceController.text = widget.equipment.purchasePrice.toString();
    _condition = widget.equipment.condition;
    _locationController.text = widget.equipment.location!;
    _descriptionController.text = widget.equipment.description!;

    // Set level for SuperAdmin
    if (widget.loggedInUser.role == 'SuperAdmin' &&
        widget.equipment.level != null) {
      setState(() {
        _equipmentselectedSuperAdminCell = widget.equipment.level;
      });
    }
  }

  Future<void> _updateEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(updateEquipmentProvider);
    final notifier = ref.read(updateEquipmentProvider.notifier);

    // Validate level
    final level = widget.loggedInUser.role == 'SuperAdmin'
        ? _equipmentselectedSuperAdminCell
        : widget.loggedInUser.level;

    if (level == null || level.levelId == null) {
      return;
    }

    // Use provider to update equipment
    await notifier.updateEquipment(
      name: _nameController.text,
      equipmentCategory: _selectedEquipmentCategory!,
      purchaseDate: _purchaseDate != null
          ? DateFormat('yyyy-MM-dd').format(_purchaseDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      purchasePrice: double.parse(_priceController.text),
      condition: _condition!,
      location: _locationController.text,
      description: _descriptionController.text,
      level: level,
      userId: widget.loggedInUser.userId!,
    );
  }

  void _resetForm() {
    _populateExistingData();
    ref.read(updateEquipmentProvider.notifier).clearMessage();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateEquipmentProvider);
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
                child: _buildUpdateEquipmentScreen(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateEquipmentScreen(UpdateEquipmentState state) {
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
                        "Update Equipment",
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
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: const BoxConstraints(maxWidth: 600),
                          decoration: BoxDecoration(
                            color: state.isSuccess
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.isSuccess
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.isSuccess
                                    ? Icons.check_circle
                                    : Icons.error_outline,
                                color: state.isSuccess
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.message!,
                                  style: GoogleFonts.inter(
                                    color: state.isSuccess
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (!state.isSuccess)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    ref
                                        .read(updateEquipmentProvider.notifier)
                                        .clearMessage();
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Current Equipment Info
                    if (state.equipment != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Editing: ${state.equipment!.name}',
                              style: GoogleFonts.inter(
                                color: Colors.blue.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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

                    // Form Fields
                    Center(
                      child: Wrap(
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
                            (dept) => setState(
                              () => _selectedEquipmentCategory = dept,
                            ),
                            equipmentCategories: state.equipmentCategories,
                            notifier: ref.read(
                              updateEquipmentProvider.notifier,
                            ),
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
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset Button
                          ElevatedButton(
                            onPressed: state.isLoading ? null : _resetForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Reset",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Update Button
                          state.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _updateEquipment,
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
                                    "Update",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
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
      child: DropdownButtonFormField<String>(
        value: selectedSuperAdminCell?.levelId,
        validator: (value) {
          if (validator != null) {
            final selectedLevel = cells.firstWhere(
              (cell) => cell.levelId == value,
              orElse: () => Level(), // Return dummy level if not found
            );
            return validator(
              selectedLevel.levelId == null ? null : selectedLevel,
            );
          }
          return null;
        },
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
          ...cells.map((cell) {
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
            final selectedLevel = cells.firstWhere(
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
    required UpdateEquipmentNotifier notifier,
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
