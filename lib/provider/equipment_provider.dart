// providers/equipment_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/equipment_model.dart';
import '../model/equipmentCategory_model.dart';
import '../controller/equipment_controller.dart';
import '../controller/equipmentCategory_controller.dart';

// Provider for EquipmentController
final equipmentControllerProvider = Provider<EquipmentController>((ref) {
  return EquipmentController();
});

// Provider for EquipmentCategoryController
final equipmentCategoryControllerProvider =
    Provider<EquipmentCategoryController>((ref) {
      return EquipmentCategoryController();
    });

// State for equipment
class EquipmentState {
  final List<Equipment> equipment;
  final List<Equipment> allEquipment;
  final List<Equipment> filteredEquipment;
  final List<EquipmentCategory> equipmentCategories;
  final Map<String, dynamic> equipmentStats;
  final int equipmentCount;
  final bool isLoading;
  final int currentPage;
  final int pageSize;
  final bool isFiltering;
  final String searchQuery;
  final String? error;
  final int refreshTrigger;

  EquipmentState({
    this.equipment = const [],
    this.allEquipment = const [],
    this.filteredEquipment = const [],
    this.equipmentCategories = const [],
    this.equipmentStats = const {
      'totalEquipment': 0,
      'excellentCount': 0,
      'goodCount': 0,
      'needsRepairCount': 0,
      'outOfServiceCount': 0,
    },
    this.equipmentCount = 0,
    this.isLoading = false,
    this.currentPage = 0,
    this.pageSize = 5,
    this.isFiltering = false,
    this.searchQuery = '',
    this.error,
    this.refreshTrigger = 0,
  });

  EquipmentState copyWith({
    List<Equipment>? equipment,
    List<Equipment>? allEquipment,
    List<Equipment>? filteredEquipment,
    List<EquipmentCategory>? equipmentCategories,
    Map<String, dynamic>? equipmentStats,
    int? equipmentCount,
    bool? isLoading,
    int? currentPage,
    int? pageSize,
    bool? isFiltering,
    String? searchQuery,
    String? error,
    int? refreshTrigger,
  }) {
    return EquipmentState(
      equipment: equipment ?? this.equipment,
      allEquipment: allEquipment ?? this.allEquipment,
      filteredEquipment: filteredEquipment ?? this.filteredEquipment,
      equipmentCategories: equipmentCategories ?? this.equipmentCategories,
      equipmentStats: equipmentStats ?? this.equipmentStats,
      equipmentCount: equipmentCount ?? this.equipmentCount,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isFiltering: isFiltering ?? this.isFiltering,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
      refreshTrigger: refreshTrigger ?? this.refreshTrigger,
    );
  }
}

// Equipment Notifier
class EquipmentNotifier extends StateNotifier<EquipmentState> {
  final EquipmentController _controller;
  final EquipmentCategoryController _categoryController;
  final String _userId;

  EquipmentNotifier(this._controller, this._categoryController, this._userId)
    : super(EquipmentState()) {
    _loadInitialData();
  }

  // Load initial data - NO UI BLOCKING
  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        _fetchEquipmentStats(),
        _fetchEquipmentCategories(),
        _fetchEquipment(),
      ]);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load initial data');
    }
  }

  // Fetch paginated equipment - NO BLOCKING LOADING
  Future<void> _fetchEquipment() async {
    try {
      final equipment = await _controller.getScopedPaginatedEquipment(
        userId: _userId,
        page: state.currentPage,
        size: state.pageSize,
      );
      state = state.copyWith(
        equipment: equipment,
        error: null,
        refreshTrigger: state.refreshTrigger + 1,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load equipment',
        refreshTrigger: state.refreshTrigger + 1,
      );
    }
  }

  // Fetch all equipment - NO BLOCKING LOADING
  Future<void> _fetchAllEquipment() async {
    try {
      final allEquipment = await _controller.getAllEquipment();
      state = state.copyWith(
        allEquipment: allEquipment,
        error: null,
        refreshTrigger: state.refreshTrigger + 1,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load all equipment',
        refreshTrigger: state.refreshTrigger + 1,
      );
    }
  }

  // Fetch equipment categories
  Future<void> _fetchEquipmentCategories() async {
    try {
      final categories = await _categoryController.getAllEquipmentCategories();
      state = state.copyWith(
        equipmentCategories: categories,
        error: null,
        refreshTrigger: state.refreshTrigger + 1,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load equipment categories',
        refreshTrigger: state.refreshTrigger + 1,
      );
    }
  }

  // Fetch equipment stats
  Future<void> _fetchEquipmentStats() async {
    try {
      final stats = await _controller.getEquipmentStats(_userId);
      state = state.copyWith(
        equipmentStats: stats,
        equipmentCount: stats['totalEquipment'] ?? 0,
        error: null,
        refreshTrigger: state.refreshTrigger + 1,
      );
    } catch (e) {
      state = state.copyWith(
        equipmentStats: {
          'totalEquipment': 0,
          'excellentCount': 0,
          'goodCount': 0,
          'needsRepairCount': 0,
          'outOfServiceCount': 0,
        },
        equipmentCount: 0,
        refreshTrigger: state.refreshTrigger + 1,
      );
    }
  }

  // Handle filter changes - OPTIMIZED
  Future<void> handleFilterChange(Map<String, String> filters) async {
    final isDefaultFilter = filters.values.every((value) => value.isEmpty);

    if (isDefaultFilter) {
      state = state.copyWith(
        isFiltering: false,
        currentPage: 0,
        refreshTrigger: state.refreshTrigger + 1,
      );
      await _fetchEquipment();
      await _fetchEquipmentStats();
    } else {
      state = state.copyWith(
        isFiltering: true,
        refreshTrigger: state.refreshTrigger + 1,
      );

      // Only fetch all data if we don't have it yet
      if (state.allEquipment.isEmpty) {
        await _fetchAllEquipment();
      }

      // Apply filter locally - INSTANT response
      _applySearchFilter(filters);
    }
  }

  // Apply search filter - INSTANT (no API call)
  void _applySearchFilter(Map<String, String> filters) {
    final filtered = state.allEquipment.where((equipment) {
      final matchesName = equipment.name.toLowerCase().contains(
        filters['name']?.toLowerCase() ?? '',
      );
      final matchesCategory =
          filters['category']?.isEmpty == true ||
          equipment.equipmentCategory.name.toLowerCase().contains(
            filters['category']?.toLowerCase() ?? '',
          );
      final matchesPurchaseDate =
          filters['purchaseDate']?.isEmpty == true ||
          equipment.purchaseDate.contains(filters['purchaseDate'] ?? '');
      final matchesPrice =
          filters['purchasePrice']?.isEmpty == true ||
          equipment.purchasePrice.toString().contains(
            filters['purchasePrice'] ?? '',
          );
      final matchesLocation =
          filters['location']?.isEmpty == true ||
          equipment.location?.toLowerCase().contains(
                filters['location']?.toLowerCase() ?? '',
              ) ==
              true;
      final matchesDescription =
          filters['description']?.isEmpty == true ||
          equipment.description?.toLowerCase().contains(
                filters['description']?.toLowerCase() ?? '',
              ) ==
              true;
      final matchesLevel =
          filters['level']?.isEmpty == true ||
          equipment.level?.name?.toLowerCase().contains(
                filters['level']?.toLowerCase() ?? '',
              ) ==
              true;
      final matchesCondition =
          filters['condition'] == 'All Conditions' ||
          equipment.condition == filters['condition'];

      return matchesName &&
          matchesCategory &&
          matchesPurchaseDate &&
          matchesPrice &&
          matchesLocation &&
          matchesDescription &&
          matchesLevel &&
          matchesCondition;
    }).toList();

    state = state.copyWith(
      filteredEquipment: filtered,
      currentPage: 0,
      refreshTrigger: state.refreshTrigger + 1,
    );
  }

  // Update search query for instant filtering
  void updateSearchQuery(Map<String, String> filters) {
    state = state.copyWith(refreshTrigger: state.refreshTrigger + 1);

    // Apply filter immediately without API call
    if (state.isFiltering && state.allEquipment.isNotEmpty) {
      _applySearchFilter(filters);
    }
  }

  // ENHANCED METHOD: Refresh all data including table and stats
  Future<void> _refreshAllData() async {
    try {
      // COMPLETELY RESET all data to empty state first
      state = state.copyWith(
        currentPage: 0,
        equipment: const [],
        allEquipment: const [],
        filteredEquipment: const [],
        equipmentCount: 0,
        isLoading: false,
        error: null,
        refreshTrigger: state.refreshTrigger + 1,
      );

      // Now fetch ALL fresh data from the database
      await Future.wait([
        _fetchEquipmentStats(),
        _fetchEquipment(),
        _fetchAllEquipment(),
      ]);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to refresh data',
        refreshTrigger: state.refreshTrigger + 1,
      );
    }
  }

  // FORCE REFRESH - Public method that other providers can call
  Future<void> forceRefresh() async {
    await _refreshAllData();
  }

  // Change page - UPDATED FOR SMOOTH PAGINATION
  Future<void> changePage(int newPage) async {
    state = state.copyWith(
      currentPage: newPage,
      refreshTrigger: state.refreshTrigger + 1,
    );
    if (!state.isFiltering) {
      await _fetchEquipment();
    }
  }

  // Change page size - UPDATED FOR SMOOTH PAGINATION
  Future<void> changePageSize(int newSize) async {
    state = state.copyWith(
      pageSize: newSize,
      currentPage: 0,
      refreshTrigger: state.refreshTrigger + 1,
    );
    if (state.isFiltering) {
      // Re-apply current filters
      _applySearchFilter({
        'name': state.searchQuery,
        'category': '',
        'purchaseDate': '',
        'purchasePrice': '',
        'location': '',
        'description': '',
        'level': '',
        'condition': 'All Conditions',
      });
    } else {
      await _fetchEquipment();
    }
  }

  // Clear filters - UPDATED FOR SMOOTH PAGINATION
  Future<void> clearFilters() async {
    state = state.copyWith(
      isFiltering: false,
      currentPage: 0,
      refreshTrigger: state.refreshTrigger + 1,
    );
    await _fetchEquipment();
    await _fetchEquipmentStats();
  }

  // Refresh data - PUBLIC METHOD
  Future<void> refreshData() async {
    await _refreshAllData();
  }

  // Get displayed equipment based on current state
  List<Equipment> get displayedEquipment {
    if (state.isFiltering) {
      if (state.filteredEquipment.isEmpty) return [];
      final start = state.currentPage * state.pageSize;
      final end = start + state.pageSize;
      return state.filteredEquipment.sublist(
        start,
        end > state.filteredEquipment.length
            ? state.filteredEquipment.length
            : end,
      );
    } else {
      return state.equipment;
    }
  }

  // Next page - UPDATED FOR SMOOTH PAGINATION
  Future<void> nextPage() async {
    if (state.isFiltering) {
      if ((state.currentPage + 1) * state.pageSize <
          state.filteredEquipment.length) {
        await changePage(state.currentPage + 1);
      }
    } else {
      // Check if there are more pages available
      if ((state.currentPage + 1) * state.pageSize < state.equipmentCount) {
        await changePage(state.currentPage + 1);
      }
    }
  }

  // Previous page - UPDATED FOR SMOOTH PAGINATION
  Future<void> previousPage() async {
    if (state.currentPage > 0) {
      await changePage(state.currentPage - 1);
    }
  }

  // NEW: Get total pages for pagination info
  int get totalPages {
    if (state.isFiltering) {
      return (state.filteredEquipment.length / state.pageSize).ceil();
    } else {
      return (state.equipmentCount / state.pageSize).ceil();
    }
  }

  // NEW: Check if next page is available
  bool get hasNextPage {
    if (state.isFiltering) {
      return (state.currentPage + 1) * state.pageSize <
          state.filteredEquipment.length;
    } else {
      return (state.currentPage + 1) * state.pageSize < state.equipmentCount;
    }
  }

  // NEW: Check if previous page is available
  bool get hasPreviousPage {
    return state.currentPage > 0;
  }

  // Helper method to get condition colors
  Color getConditionBackgroundColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green.shade50;
      case 'Good':
        return Colors.blue.shade50;
      case 'Needs Repair':
        return Colors.orange.shade50;
      case 'Out of Service':
        return Colors.red.shade50;
      case 'All Conditions':
      default:
        return Colors.white;
    }
  }

  Color getConditionDotColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Needs Repair':
        return Colors.orange;
      case 'Out of Service':
        return Colors.red;
      case 'All Conditions':
      default:
        return Colors.grey;
    }
  }

  Color getConditionTextColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green.shade800;
      case 'Good':
        return Colors.blue.shade800;
      case 'Needs Repair':
        return Colors.orange.shade800;
      case 'Out of Service':
        return Colors.red.shade800;
      case 'All Conditions':
      default:
        return Colors.grey.shade800;
    }
  }
}

// Provider for EquipmentNotifier
final equipmentProvider =
    StateNotifierProvider.family<EquipmentNotifier, EquipmentState, String>((
      ref,
      userId,
    ) {
      final controller = ref.watch(equipmentControllerProvider);
      final categoryController = ref.watch(equipmentCategoryControllerProvider);
      return EquipmentNotifier(controller, categoryController, userId);
    });
