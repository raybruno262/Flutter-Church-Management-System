// providers/update_equipment_category_provider.dart
import 'package:flutter_churchcrm_system/provider/equipmentCategory_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/equipmentCategory_model.dart';
import '../controller/equipmentCategory_controller.dart';

// State for Update Equipment Category
class UpdateEquipmentCategoryState {
  final bool isLoading;
  final String? message;
  final bool isSuccess;
  final EquipmentCategory? equipmentCategory;
  final bool isFormPopulated;

  UpdateEquipmentCategoryState({
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.equipmentCategory,
    this.isFormPopulated = false,
  });

  UpdateEquipmentCategoryState copyWith({
    bool? isLoading,
    String? message,
    bool? isSuccess,
    EquipmentCategory? equipmentCategory,
    bool? isFormPopulated,
  }) {
    return UpdateEquipmentCategoryState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
      equipmentCategory: equipmentCategory ?? this.equipmentCategory,
      isFormPopulated: isFormPopulated ?? this.isFormPopulated,
    );
  }
}

// Update Equipment Category Notifier
class UpdateEquipmentCategoryNotifier
    extends StateNotifier<UpdateEquipmentCategoryState> {
  final EquipmentCategoryController _controller;
  final Ref _ref; // Add Ref to access other providers

  UpdateEquipmentCategoryNotifier(this._controller, this._ref)
    : super(UpdateEquipmentCategoryState());

  // Set equipment category for editing
  void setEquipmentCategory(EquipmentCategory equipmentCategory) {
    state = state.copyWith(
      equipmentCategory: equipmentCategory,
      isFormPopulated: true,
      message: null, // Clear any previous messages
      isSuccess: false, // Reset success state
    );
  }

  // Update equipment category - NON BLOCKING
  Future<String> updateEquipmentCategory(String name) async {
    if (name.isEmpty) {
      state = state.copyWith(
        message: 'Please enter equipment category name',
        isSuccess: false,
      );
      return 'Status 4000'; // Validation error
    }

    if (state.equipmentCategory == null) {
      state = state.copyWith(
        message: 'Equipment category not found',
        isSuccess: false,
      );
      return 'Status 3000';
    }

    state = state.copyWith(isLoading: true, message: null);

    try {
      final equipmentCategoryName = name.trim();
      final updatedEquipmentCategory = EquipmentCategory(
        name: equipmentCategoryName,
      );

      final result = await _controller.updateEquipmentCategory(
        state.equipmentCategory!.equipmentCategoryId!,
        updatedEquipmentCategory,
      );

      // Update state without blocking UI
      if (result == 'Status 1000') {
        state = state.copyWith(
          isLoading: false,
          message: 'Equipment Category updated successfully!',
          isSuccess: true,
        );

        // REFRESH THE MAIN TABLE DATA
        _ref.read(equipmentCategoryProvider.notifier).refreshData();
      } else if (result == 'Status 3000') {
        state = state.copyWith(
          isLoading: false,
          message: 'Equipment Category not found',
          isSuccess: false,
        );
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
          message: 'Unexpected error: $result',
          isSuccess: false,
        );
      }
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Error updating Equipment Category: $e',
        isSuccess: false,
      );
      return 'Status 7000';
    }
  }

  // Clear message
  void clearMessage() {
    state = state.copyWith(message: null);
  }

  // Reset state - IMPORTANT: Add this method
  void resetState() {
    state = UpdateEquipmentCategoryState();
  }
}

// Provider for UpdateEquipmentCategoryNotifier - UPDATED
final updateEquipmentCategoryProvider =
    StateNotifierProvider<
      UpdateEquipmentCategoryNotifier,
      UpdateEquipmentCategoryState
    >((ref) {
      final controller = ref.watch(equipmentCategoryControllerProvider);
      return UpdateEquipmentCategoryNotifier(
        controller,
        ref,
      ); // Pass ref to the notifier
    });
