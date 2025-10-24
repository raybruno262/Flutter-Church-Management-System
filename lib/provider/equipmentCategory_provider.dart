// providers/equipment_category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/equipmentCategory_model.dart';
import '../controller/equipmentCategory_controller.dart';

// Provider for EquipmentCategoryController
final equipmentCategoryControllerProvider =
    Provider<EquipmentCategoryController>((ref) {
      return EquipmentCategoryController();
    });

// State for equipment categories
class EquipmentCategoryState {
  final List<EquipmentCategory> equipmentCategories;
  final List<EquipmentCategory> allEquipmentCategories;
  final List<EquipmentCategory> filteredEquipmentCategories;
  final int equipmentCategoryCount;
  final bool isLoading;
  final int currentPage;
  final int pageSize;
  final bool isFiltering;
  final String searchQuery;
  final String? error;
  final int refreshTrigger;

  EquipmentCategoryState({
    this.equipmentCategories = const [],
    this.allEquipmentCategories = const [],
    this.filteredEquipmentCategories = const [],
    this.equipmentCategoryCount = 0,
    this.isLoading = false,
    this.currentPage = 0,
    this.pageSize = 5,
    this.isFiltering = false,
    this.searchQuery = '',
    this.error,
    this.refreshTrigger = 0,
  });

  EquipmentCategoryState copyWith({
    List<EquipmentCategory>? equipmentCategories,
    List<EquipmentCategory>? allEquipmentCategories,
    List<EquipmentCategory>? filteredEquipmentCategories,
    int? equipmentCategoryCount,
    bool? isLoading,
    int? currentPage,
    int? pageSize,
    bool? isFiltering,
    String? searchQuery,
    String? error,
    int? refreshTrigger, // Add refresh trigger to copyWith
  }) {
    return EquipmentCategoryState(
      equipmentCategories: equipmentCategories ?? this.equipmentCategories,
      allEquipmentCategories:
          allEquipmentCategories ?? this.allEquipmentCategories,
      filteredEquipmentCategories:
          filteredEquipmentCategories ?? this.filteredEquipmentCategories,
      equipmentCategoryCount:
          equipmentCategoryCount ?? this.equipmentCategoryCount,
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

// Equipment Category Notifier
class EquipmentCategoryNotifier extends StateNotifier<EquipmentCategoryState> {
  final EquipmentCategoryController _controller;

  EquipmentCategoryNotifier(this._controller)
    : super(EquipmentCategoryState()) {
    _loadInitialData();
  }

  // Load initial data - NO UI BLOCKING
  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        _fetchEquipmentCategoryCount(),
        _fetchEquipmentCategories(),
      ]);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load initial data');
    }
  }

  // Fetch paginated equipment categories - NO BLOCKING LOADING
  Future<void> _fetchEquipmentCategories() async {
    try {
      final equipmentCategories = await _controller
          .getPaginatedEquipmentCategories(
            page: state.currentPage,
            size: state.pageSize,
          );
      state = state.copyWith(
        equipmentCategories: equipmentCategories,
        error: null,
        refreshTrigger: state.refreshTrigger + 1, // Force UI update
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load equipment categories',
        refreshTrigger:
            state.refreshTrigger + 1, // Force UI update even on error
      );
    }
  }

  // Fetch all equipment categories - NO BLOCKING LOADING
  Future<void> _fetchAllEquipmentCategories() async {
    try {
      final allEquipmentCategories = await _controller
          .getAllEquipmentCategories();
      state = state.copyWith(
        allEquipmentCategories: allEquipmentCategories,
        error: null,
        refreshTrigger: state.refreshTrigger + 1, // Force UI update
      );

      // AUTO-SYNC STATS: Update stats when all data is loaded
      _syncStatsWithTableData();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load all equipment categories',
        refreshTrigger:
            state.refreshTrigger + 1, // Force UI update even on error
      );
    }
  }

  // Fetch equipment category count - ENSURED PROPER STATS UPDATE
  Future<void> _fetchEquipmentCategoryCount() async {
    try {
      final count = await _controller.getEquipmentCategoryCount();
      // Force immediate update of stats count
      state = state.copyWith(
        equipmentCategoryCount: count,
        refreshTrigger: state.refreshTrigger + 1, // Force UI update
      );
    } catch (e) {
      // Ensure stats show 0 on error
      state = state.copyWith(
        equipmentCategoryCount: 0,
        refreshTrigger:
            state.refreshTrigger + 1, // Force UI update even on error
      );
    }
  }

  // FIXED METHOD: Auto-sync stats with table data
  void _syncStatsWithTableData() {
    // Only sync stats with table data when filtering or when we have all data
    // Don't override the actual count from API during initial load
    if (state.isFiltering) {
      final filteredCount = state.filteredEquipmentCategories.length;
      if (filteredCount != state.equipmentCategoryCount) {
        state = state.copyWith(
          equipmentCategoryCount: filteredCount,
          refreshTrigger: state.refreshTrigger + 1, // Force UI update
        );
      }
    }
    // Don't sync with paginated data - keep the actual count from _fetchEquipmentCategoryCount()
  }

  // Handle filter changes - OPTIMIZED
  Future<void> handleFilterChange(String nameQuery) async {
    final isDefaultFilter = nameQuery.isEmpty;

    if (isDefaultFilter) {
      state = state.copyWith(
        isFiltering: false,
        currentPage: 0,
        searchQuery: '',
        refreshTrigger: state.refreshTrigger + 1, // Force UI update
      );
      await _fetchEquipmentCategories();

      // RESTORE ACTUAL COUNT when clearing filter
      await _fetchEquipmentCategoryCount();
    } else {
      state = state.copyWith(
        isFiltering: true,
        searchQuery: nameQuery,
        refreshTrigger: state.refreshTrigger + 1, // Force UI update
      );

      // Only fetch all data if we don't have it yet
      if (state.allEquipmentCategories.isEmpty) {
        await _fetchAllEquipmentCategories();
      }

      // Apply filter locally - INSTANT response
      _applySearchFilter(nameQuery);

      // AUTO-SYNC STATS after filtering
      _syncStatsWithTableData();
    }
  }

  // Apply search filter - INSTANT (no API call)
  void _applySearchFilter(String nameQuery) {
    final filtered = state.allEquipmentCategories.where((equipmentCategory) {
      final matchesName = equipmentCategory.name.toLowerCase().contains(
        nameQuery.toLowerCase(),
      );
      return matchesName;
    }).toList();

    state = state.copyWith(
      filteredEquipmentCategories: filtered,
      currentPage: 0,
      searchQuery: nameQuery,
      refreshTrigger: state.refreshTrigger + 1, // Force UI update
    );

    // AUTO-SYNC STATS after applying filter
    _syncStatsWithTableData();
  }

  // Update search query for instant filtering
  void updateSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      refreshTrigger: state.refreshTrigger + 1, // Force UI update
    );

    // Apply filter immediately without API call
    if (state.isFiltering && state.allEquipmentCategories.isNotEmpty) {
      _applySearchFilter(query);
    }
  }

  // Create equipment category - NON BLOCKING
  Future<String> createEquipmentCategory(EquipmentCategory category) async {
    try {
      final result = await _controller.createEquipmentCategory(category);
      if (result == 'Status 1000') {
        await _refreshAllData(); // Refresh ALL data including table
      }
      return result;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // Update equipment category - NON BLOCKING
  Future<String> updateEquipmentCategory(
    String equipmentCategoryId,
    EquipmentCategory updatedCategory,
  ) async {
    try {
      final result = await _controller.updateEquipmentCategory(
        equipmentCategoryId,
        updatedCategory,
      );
      if (result == 'Status 1000') {
        await _refreshAllData(); // Refresh ALL data including table
      }
      return result;
    } catch (e) {
      return 'Status 7000';
    }
  }

  // ENHANCED METHOD: Refresh all data including table and stats
  Future<void> _refreshAllData() async {
    try {
      // COMPLETELY RESET all data to empty state first
      state = state.copyWith(
        currentPage: 0,
        equipmentCategories: const [],
        allEquipmentCategories: const [],
        filteredEquipmentCategories: const [],
        equipmentCategoryCount: 0, // Reset stats to 0 immediately
        isLoading: false,
        error: null,
        refreshTrigger: state.refreshTrigger + 1, // Force UI update
      );

      // Now fetch ALL fresh data from the database
      await Future.wait([
        _fetchEquipmentCategoryCount(), // Fetch actual count from API
        _fetchEquipmentCategories(),
        _fetchAllEquipmentCategories(), // ALWAYS fetch all data to ensure consistency
      ]);

      // Re-apply search filter if filtering is active
      if (state.isFiltering && state.searchQuery.isNotEmpty) {
        _applySearchFilter(state.searchQuery);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to refresh data',
        refreshTrigger:
            state.refreshTrigger + 1, // Force UI update even on error
      );
    }
  }

  // ENHANCED SMART REFRESH: Check if data has changed and refresh only if needed
  Future<void> smartRefresh() async {
    try {
      // Quick check: Get current count from database
      final currentCount = await _controller.getEquipmentCategoryCount();

      // If count is different, refresh all data
      if (currentCount != state.equipmentCategoryCount) {
        await _refreshAllData();
      } else {
        // Even if count is same, ensure stats are synced
        state = state.copyWith(
          equipmentCategoryCount: currentCount,
          refreshTrigger: state.refreshTrigger + 1, // Force UI update
        );
      }
    } catch (e) {
      // Silently fail - this is just a background check
      print('Smart refresh check failed: $e');
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
      refreshTrigger: state.refreshTrigger + 1, // Force immediate UI update
    );
    if (!state.isFiltering) {
      await _fetchEquipmentCategories();
    }
  }

  // Change page size - UPDATED FOR SMOOTH PAGINATION
  Future<void> changePageSize(int newSize) async {
    state = state.copyWith(
      pageSize: newSize,
      currentPage: 0,
      refreshTrigger: state.refreshTrigger + 1, // Force immediate UI update
    );
    if (state.isFiltering) {
      _applySearchFilter(state.searchQuery);
    } else {
      await _fetchEquipmentCategories();
    }
  }

  // Clear filters - UPDATED FOR SMOOTH PAGINATION
  Future<void> clearFilters() async {
    state = state.copyWith(
      isFiltering: false,
      searchQuery: '',
      currentPage: 0,
      refreshTrigger: state.refreshTrigger + 1, // Force immediate UI update
    );
    await _fetchEquipmentCategories();

    // RESTORE ACTUAL COUNT when clearing filters
    await _fetchEquipmentCategoryCount();
  }

  // Refresh data - PUBLIC METHOD
  Future<void> refreshData() async {
    await _refreshAllData();
  }

  // Get displayed equipment categories based on current state
  List<EquipmentCategory> get displayedEquipmentCategories {
    if (state.isFiltering) {
      if (state.filteredEquipmentCategories.isEmpty) return [];
      final start = state.currentPage * state.pageSize;
      final end = start + state.pageSize;
      return state.filteredEquipmentCategories.sublist(
        start,
        end > state.filteredEquipmentCategories.length
            ? state.filteredEquipmentCategories.length
            : end,
      );
    } else {
      return state.equipmentCategories;
    }
  }

  // Next page - UPDATED FOR SMOOTH PAGINATION
  Future<void> nextPage() async {
    if (state.isFiltering) {
      if ((state.currentPage + 1) * state.pageSize <
          state.filteredEquipmentCategories.length) {
        await changePage(state.currentPage + 1);
      }
    } else {
      // Check if there are more pages available
      if ((state.currentPage + 1) * state.pageSize <
          state.equipmentCategoryCount) {
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
      return (state.filteredEquipmentCategories.length / state.pageSize).ceil();
    } else {
      return (state.equipmentCategoryCount / state.pageSize).ceil();
    }
  }

  // NEW: Check if next page is available
  bool get hasNextPage {
    if (state.isFiltering) {
      return (state.currentPage + 1) * state.pageSize <
          state.filteredEquipmentCategories.length;
    } else {
      return (state.currentPage + 1) * state.pageSize <
          state.equipmentCategoryCount;
    }
  }

  // NEW: Check if previous page is available
  bool get hasPreviousPage {
    return state.currentPage > 0;
  }
}

// Provider for EquipmentCategoryNotifier
final equipmentCategoryProvider =
    StateNotifierProvider<EquipmentCategoryNotifier, EquipmentCategoryState>((
      ref,
    ) {
      final controller = ref.watch(equipmentCategoryControllerProvider);
      return EquipmentCategoryNotifier(controller);
    });
