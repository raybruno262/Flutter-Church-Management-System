// providers/add_equipment_provider.dart
import 'package:flutter_churchcrm_system/controller/equipment_controller.dart';
import 'package:flutter_churchcrm_system/controller/equipmentCategory_controller.dart';
import 'package:flutter_churchcrm_system/controller/level_controller.dart';
import 'package:flutter_churchcrm_system/model/equipment_model.dart';
import 'package:flutter_churchcrm_system/model/equipmentCategory_model.dart';
import 'package:flutter_churchcrm_system/model/level_model.dart';
import 'package:flutter_churchcrm_system/provider/equipment_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State for Add Equipment
class AddEquipmentState {
  final bool isLoading;
  final String? message;
  final bool isSuccess;
  final bool isFormCleared;
  final List<EquipmentCategory> equipmentCategories;
  final List<Level> cells;

  AddEquipmentState({
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.isFormCleared = false,
    this.equipmentCategories = const [],
    this.cells = const [],
  });

  AddEquipmentState copyWith({
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool? isFormCleared,
    List<EquipmentCategory>? equipmentCategories,
    List<Level>? cells,
  }) {
    return AddEquipmentState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
      isFormCleared: isFormCleared ?? this.isFormCleared,
      equipmentCategories: equipmentCategories ?? this.equipmentCategories,
      cells: cells ?? this.cells,
    );
  }
}

// Add Equipment Notifier
class AddEquipmentNotifier extends StateNotifier<AddEquipmentState> {
  final EquipmentController _controller;
  final EquipmentCategoryController _categoryController;
  final LevelController _levelController;
  final Ref _ref;

  AddEquipmentNotifier(
    this._controller,
    this._categoryController,
    this._levelController,
    this._ref,
  ) : super(AddEquipmentState()) {
    _loadInitialData();
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    try {
      await Future.wait([_loadEquipmentCategories(), _loadCells()]);
    } catch (e) {
      state = state.copyWith(
        message: 'Failed to load initial data',
        isSuccess: false,
      );
    }
  }

  // Load equipment categories
  Future<void> _loadEquipmentCategories() async {
    try {
      final categories = await _categoryController.getAllEquipmentCategories();
      state = state.copyWith(equipmentCategories: categories);
    } catch (e) {
      state = state.copyWith(
        message: 'Failed to load equipment categories',
        isSuccess: false,
      );
    }
  }

  // Load cells
  Future<void> _loadCells() async {
    try {
      final cells = await _levelController.getAllCells();
      state = state.copyWith(cells: cells);
    } catch (e) {
      state = state.copyWith(message: 'Failed to load cells', isSuccess: false);
    }
  }

  // Add equipment - NON BLOCKING
  Future<String> addEquipment({
    required String name,
    required EquipmentCategory equipmentCategory,
    required String purchaseDate,
    required double purchasePrice,
    required String condition,
    required String location,
    required String description,
    required Level level,
    required String userId,
  }) async {
    // Validation
    if (name.isEmpty) {
      state = state.copyWith(
        message: 'Please enter equipment name',
        isSuccess: false,
      );
      return 'Status 4000';
    }

    if (equipmentCategory.equipmentCategoryId == null) {
      state = state.copyWith(
        message: 'Please select a valid equipment category',
        isSuccess: false,
      );
      return 'Status 4000';
    }

    if (purchasePrice < 0) {
      state = state.copyWith(
        message: 'Please enter a valid purchase price',
        isSuccess: false,
      );
      return 'Status 4000';
    }

    if (condition.isEmpty) {
      state = state.copyWith(
        message: 'Please select equipment condition',
        isSuccess: false,
      );
      return 'Status 4000';
    }

    if (location.isEmpty) {
      state = state.copyWith(
        message: 'Please enter equipment location',
        isSuccess: false,
      );
      return 'Status 4000';
    }

    if (description.isEmpty) {
      state = state.copyWith(
        message: 'Please enter equipment description',
        isSuccess: false,
      );
      return 'Status 4000';
    }

    if (level.levelId == null) {
      state = state.copyWith(
        message: 'Please select a valid level',
        isSuccess: false,
      );
      return 'Status 4000';
    }

    state = state.copyWith(isLoading: true, message: null);

    try {
      final equipment = Equipment(
        name: name.trim(),
        equipmentCategory: equipmentCategory,

        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        condition: condition,
        location: location.trim(),
        description: description.trim(),
        level: level,
      );

      final result = await _controller.createEquipment(equipment, userId);

      // Update state without blocking UI
      if (result == 'Status 1000') {
        state = state.copyWith(
          isLoading: false,
          message: 'Equipment saved successfully!',
          isSuccess: true,
        );

        // REFRESH THE MAIN TABLE DATA
        _ref.read(equipmentProvider(userId).notifier).refreshData();
      } else {
        String errorMessage;
        switch (result) {
          case 'Status 3000':
            errorMessage = 'Invalid equipment data';
            break;
          case 'Status 4000':
            errorMessage = 'User not found. Please log in again.';
            break;
          case 'Status 6000':
            errorMessage =
                'You are not authorized to create equipment records.';
            break;
          case 'Status 2000':
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = 'Unexpected error';
            break;
        }
        state = state.copyWith(
          isLoading: false,
          message: errorMessage,
          isSuccess: false,
        );
      }
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Network error. Please check your connection and try again.',
        isSuccess: false,
      );
      return 'Status 7000';
    }
  }

  // Clear form
  void clearForm() {
    state = state.copyWith(
      message: null,
      isSuccess: false,
      isFormCleared: true,
    );

    // Reset the form cleared flag after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      state = state.copyWith(isFormCleared: false);
    });
  }

  // Clear message
  void clearMessage() {
    state = state.copyWith(message: null);
  }

  // Reset state
  void resetState() {
    state = AddEquipmentState(
      equipmentCategories: state.equipmentCategories,
      cells: state.cells,
    );
  }

  // Refresh equipment categories
  Future<void> refreshEquipmentCategories() async {
    await _loadEquipmentCategories();
  }
}

// Provider for AddEquipmentNotifier
final addEquipmentProvider =
    StateNotifierProvider<AddEquipmentNotifier, AddEquipmentState>((ref) {
      final equipmentController = ref.watch(equipmentControllerProvider);
      final categoryController = ref.watch(equipmentCategoryControllerProvider);
      final levelController = ref.watch(levelControllerProvider);
      return AddEquipmentNotifier(
        equipmentController,
        categoryController,
        levelController,
        ref,
      );
    });

// Provider for LevelController
final levelControllerProvider = Provider<LevelController>((ref) {
  return LevelController();
});
