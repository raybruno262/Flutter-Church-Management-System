// providers/add_equipment_category_provider.dart
import 'package:flutter_churchcrm_system/controller/equipmentCategory_controller.dart';
import 'package:flutter_churchcrm_system/provider/equipmentCategory_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/equipmentCategory_model.dart';

// State for Add Equipment Category
class AddEquipmentCategoryState {
  final bool isLoading;
  final String? message;
  final bool isSuccess;
  final bool isFormCleared;

  AddEquipmentCategoryState({
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.isFormCleared = false,
  });

  AddEquipmentCategoryState copyWith({
    bool? isLoading,
    String? message,
    bool? isSuccess,
    bool? isFormCleared,
  }) {
    return AddEquipmentCategoryState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
      isFormCleared: isFormCleared ?? this.isFormCleared,
    );
  }
}

// Add Equipment Category Notifier
class AddEquipmentCategoryNotifier
    extends StateNotifier<AddEquipmentCategoryState> {
  final EquipmentCategoryController _controller;
  final Ref _ref; // Add Ref to access other providers

  AddEquipmentCategoryNotifier(this._controller, this._ref)
    : super(AddEquipmentCategoryState());

  // Add equipment category - NON BLOCKING
  Future<String> addEquipmentCategory(String name) async {
    if (name.isEmpty) {
      state = state.copyWith(
        message: 'Please enter equipment category name',
        isSuccess: false,
      );
      return 'Status 4000'; // Validation error
    }

    state = state.copyWith(isLoading: true, message: null);

    try {
      final equipmentCategoryName = name.trim();
      final newEquipmentCategory = EquipmentCategory(
        name: equipmentCategoryName,
      );

      final result = await _controller.createEquipmentCategory(
        newEquipmentCategory,
      );

      // Update state without blocking UI
      if (result == 'Status 1000') {
        state = state.copyWith(
          isLoading: false,
          message: 'Equipment Category created successfully!',
          isSuccess: true,
        );

        // REFRESH THE MAIN TABLE DATA
        _ref.read(equipmentCategoryProvider.notifier).refreshData();
      } else if (result == 'Status 5000') {
        state = state.copyWith(
          isLoading: false,
          message: 'Equipment Category name already exists',
          isSuccess: false,
        );
      } else if (result == 'Status 7000') {
        state = state.copyWith(
          isLoading: false,
          message: 'Network error',
          isSuccess: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          message: 'Unexpected error',
          isSuccess: false,
        );
      }
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Error creating Equipment Category',
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

  // Reset state - IMPORTANT: Add this method
  void resetState() {
    state = AddEquipmentCategoryState();
  }
}

// Provider for AddEquipmentCategoryNotifier - UPDATED
final addEquipmentCategoryProvider =
    StateNotifierProvider<
      AddEquipmentCategoryNotifier,
      AddEquipmentCategoryState
    >((ref) {
      final controller = ref.watch(equipmentCategoryControllerProvider);
      return AddEquipmentCategoryNotifier(
        controller,
        ref,
      ); // Pass ref to the notifier
    });
