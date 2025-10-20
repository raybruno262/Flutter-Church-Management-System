import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/visitorBoxWidget.dart';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/controller/visitor_controller.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/followup_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/model/visitor_model.dart';
import 'package:flutter_churchcrm_system/screens/addVisitorScreen.dart';
import 'package:flutter_churchcrm_system/screens/updateVisitorScreen.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';

class VisitorScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const VisitorScreen({super.key, required this.loggedInUser});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  final _nameFilterController = TextEditingController();
  final _phoneFilterController = TextEditingController();
  String _genderFilter = 'All Gender';
  final _emailFilterController = TextEditingController();
  final _addressFilterController = TextEditingController();
  final _visitDateFilterController = TextEditingController();
  String _statusFilter =
      'All Status'; // Options: New, Follow-up, Converted, Dropped
  final _levelFilterController = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();
  final VisitorController _visitorController = VisitorController();
  final UserController _usercontroller = UserController();

  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  List<Visitor> _visitors = [];
  List<Visitor> _allVisitors = [];
  List<Visitor> _filteredVisitors = [];

  bool _isLoading = true;
  bool _isFiltering = false;

  Map<String, int> _visitorStats = {
    'total': 0,
    'new': 0,
    'followedUp': 0,
    'converted': 0,
    'dropped': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchVisitors();
    _fetchAllVisitors();
    _fetchVisitorStats();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _nameFilterController.dispose();
    _phoneFilterController.dispose();
    _emailFilterController.dispose();
    _addressFilterController.dispose();
    _visitDateFilterController.dispose();
    _levelFilterController.dispose();
    super.dispose();
  }

  Future<void> _fetchVisitors() async {
    setState(() => _isLoading = true);
    try {
      final visitors = await _visitorController.getPaginatedVisitors(
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _visitors = visitors;
        _filteredVisitors = visitors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllVisitors() async {
    try {
      final allVisitors = await _visitorController.getAllVisitors();
      setState(() {
        _allVisitors = allVisitors;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();
    final phoneQuery = _phoneFilterController.text.toLowerCase();
    final emailQuery = _emailFilterController.text.toLowerCase();
    final addressQuery = _addressFilterController.text.toLowerCase();
    final visitDateQuery = _visitDateFilterController.text;
    final levelQuery = _levelFilterController.text.toLowerCase();

    final filtered = _allVisitors.where((visitor) {
      final matchesName = visitor.names.toLowerCase().contains(nameQuery);
      final matchesPhone = visitor.phone.toLowerCase().contains(phoneQuery);
      final matchesGender =
          _genderFilter == 'All Gender' || visitor.gender == _genderFilter;
      final matchesEmail = visitor.email.toLowerCase().contains(emailQuery);
      final matchesAddress = visitor.address.toLowerCase().contains(
        addressQuery,
      );
      final matchesVisitDate =
          visitDateQuery.isEmpty ||
          (visitor.visitDate?.contains(visitDateQuery) ?? false);
      final matchesStatus =
          _statusFilter == 'All Status' || visitor.status == _statusFilter;
      final matchesLevel =
          levelQuery.isEmpty ||
          (visitor.level?.name?.toLowerCase().contains(levelQuery) ?? false);

      return matchesName &&
          matchesPhone &&
          matchesEmail &&
          matchesGender &&
          matchesAddress &&
          matchesVisitDate &&
          matchesLevel &&
          matchesStatus;
    }).toList();

    setState(() {
      _filteredVisitors = filtered;
      _currentPage = 0;
    });
  }

  void _onFilterChanged() async {
    final hasActiveFilters =
        _nameFilterController.text.isNotEmpty ||
        _phoneFilterController.text.isNotEmpty ||
        _genderFilter != 'All Gender' ||
        _emailFilterController.text.isNotEmpty ||
        _addressFilterController.text.isNotEmpty ||
        _visitDateFilterController.text.isNotEmpty ||
        _statusFilter != 'All Status' ||
        _levelFilterController.text.isNotEmpty;

    if (!hasActiveFilters && _isFiltering) {
      setState(() {
        _isFiltering = false;
        _currentPage = 0;
      });
      await _fetchVisitors();
    } else if (hasActiveFilters && !_isFiltering) {
      setState(() {
        _isFiltering = true;
        _currentPage = 0;
      });
      _applySearchFilter();
    } else if (hasActiveFilters && _isFiltering) {
      _applySearchFilter();
    }
  }

  Future<void> _nextPage() async {
    if (_isFiltering) {
      final totalPages = (_filteredVisitors.length / _pageSize).ceil();
      if (_currentPage + 1 < totalPages) {
        setState(() => _currentPage++);
      }
    } else {
      final totalPages = (_visitorStats['total']! / _pageSize).ceil();
      if (_currentPage + 1 < totalPages) {
        setState(() => _currentPage++);
        await _fetchVisitors();
      }
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      if (!_isFiltering) {
        await _fetchVisitors();
      }
    }
  }

  List<Visitor> get displayedVisitors {
    if (_isFiltering) {
      if (_filteredVisitors.isEmpty) return [];
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      return _filteredVisitors.sublist(
        start,
        end > _filteredVisitors.length ? _filteredVisitors.length : end,
      );
    } else {
      return _visitors;
    }
  }

  bool get hasNextPage {
    if (_isFiltering) {
      return (_currentPage + 1) * _pageSize < _filteredVisitors.length;
    } else {
      return (_currentPage + 1) * _pageSize < _visitorStats['total']!;
    }
  }

  bool get hasPreviousPage {
    return _currentPage > 0;
  }

  Future<void> _fetchVisitorStats() async {
    try {
      final loggedInUser = await _usercontroller.loadUserFromStorage();

      if (loggedInUser == null || loggedInUser.userId == null) {
        setState(() {
          _visitorStats = {
            'total': 0,
            'new': 0,
            'followedUp': 0,
            'converted': 0,
            'dropped': 0,
          };
        });
        return;
      }

      final stats = await _visitorController.getVisitorStats(
        loggedInUser.userId!,
      );

      setState(() {
        _visitorStats = {
          'total': stats['total'] ?? 0,
          'new': stats['new'] ?? 0,
          'followedUp': stats['followedUp'] ?? 0,
          'converted': stats['converted'] ?? 0,
          'dropped': stats['dropped'] ?? 0,
        };
      });
    } catch (e) {
      setState(() {
        _visitorStats = {
          'total': 0,
          'new': 0,
          'followedUp': 0,
          'converted': 0,
          'dropped': 0,
        };
      });
    }
  }

  DataRow _buildDataRow(Visitor visitor) {
    return DataRow(
      cells: [
        DataCell(Text(visitor.names, style: GoogleFonts.inter())),
        DataCell(Text(visitor.phone, style: GoogleFonts.inter())),
        DataCell(Text(visitor.gender, style: GoogleFonts.inter())),
        DataCell(Text(visitor.email, style: GoogleFonts.inter())),
        DataCell(Text(visitor.address, style: GoogleFonts.inter())),
        DataCell(Text(visitor.visitDate ?? 'N/A', style: GoogleFonts.inter())),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(visitor.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusDotColor(visitor.status),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  visitor.status,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(visitor.status),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(visitor.level?.name ?? 'N/A', style: GoogleFonts.inter()),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                tooltip: 'View Visitor',
                onPressed: () {
                  _showVisitorDetailsDialog(visitor);
                },
              ),
              if (widget.loggedInUser.role == 'CellAdmin' ||
                  widget.loggedInUser.role == 'SuperAdmin')
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Update Visitor',
                  onPressed: () async {
                    final updatedVisitor = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateVisitorScreen(
                          loggedInUser: widget.loggedInUser,
                          visitor: visitor,
                        ),
                      ),
                    );

                    if (updatedVisitor != null && updatedVisitor is Visitor) {
                      setState(() {
                        final index = _visitors.indexWhere(
                          (v) => v.visitorId == updatedVisitor.visitorId,
                        );
                        if (index != -1) {
                          _visitors[index] = updatedVisitor;
                        }

                        final filteredIndex = _filteredVisitors.indexWhere(
                          (v) => v.visitorId == updatedVisitor.visitorId,
                        );
                        if (filteredIndex != -1) {
                          _filteredVisitors[filteredIndex] = updatedVisitor;
                        }
                      });

                      await _fetchVisitorStats();
                      await _fetchVisitors();
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVisitorDetailsDialog(Visitor visitor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: SingleChildScrollView(
          child: Container(
            width: 700,
            decoration: BoxDecoration(
              color: backgroundcolor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade700, Colors.red.shade700],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Visitor Icon
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.person_add_alt_1,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          visitor.names,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getVisitorStatusColor(visitor.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatVisitorStatus(visitor.status),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSectionHeader('Visitor Information'),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildEnhancedDetailCard(
                                    'Email',
                                    visitor.email ?? 'N/A',
                                    Icons.email_outlined,
                                    Colors.blue,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Phone',
                                    visitor.phone ?? 'N/A',
                                    Icons.phone_outlined,
                                    Colors.green,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Gender',
                                    visitor.gender ?? 'N/A',
                                    Icons.person_outline,
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildEnhancedDetailCard(
                                    'Visit Date',
                                    visitor.visitDate ?? 'N/A',
                                    Icons.calendar_today_outlined,
                                    Colors.orange,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Status',
                                    _formatVisitorStatus(visitor.status),
                                    Icons.flag_outlined,
                                    _getVisitorStatusColor(visitor.status),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Church Level',
                                    visitor.level?.name ?? 'N/A',
                                    Icons.church_outlined,
                                    Colors.teal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedDetailCard(
                          'Address',
                          visitor.address ?? 'N/A',
                          Icons.location_on_outlined,
                          Colors.deepOrange,
                          fullWidth: true,
                        ),

                        const SizedBox(height: 24),

                        // Follow-up History Section
                        _buildSectionHeader('Follow-up History'),
                        const SizedBox(height: 16),

                        // if (visitor.followUp.isEmpty)
                        //   _buildEmptyStateCard(
                        //     'No follow-ups recorded yet',
                        //     Icons.history_toggle_off_outlined,
                        //     Colors.grey,
                        //   )
                        // else
                        //   ...visitor.followUps
                        //       .map((followUp) => _buildFollowUpCard(followUp))
                        //       .toList(),
                        const SizedBox(height: 24),

                        // Quick Actions Section
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin')
                          _buildSectionHeader('Quick Actions'),
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin')
                          const SizedBox(height: 16),
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin')
                          _buildQuickActions(visitor),
                      ],
                    ),
                  ),

                  // Actions section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin')
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.orange.shade800,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton.icon(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                'Update Visitor',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () async {
                                // final updatedVisitor = await Navigator.push(
                                //   context,
                                //   // MaterialPageRoute(
                                //   //   builder: (context) => UpdateVisitorScreen(
                                //   //     loggedInUser: widget.loggedInUser,
                                //   //     visitor: visitor,
                                //   //   ),
                                //   // ),
                                // // );
                                // if (updatedVisitor != null &&
                                //     updatedVisitor is Visitor) {
                                //   setState(() {
                                //     final index = _visitors.indexWhere(
                                //       (v) =>
                                //           v.visitorId ==
                                //           updatedVisitor.visitorId,
                                //     );
                                //     if (index != -1) {
                                //       _visitors[index] = updatedVisitor;
                                //     }
                                //     final filteredIndex = _filteredVisitors
                                //         .indexWhere(
                                //           (v) =>
                                //               v.visitorId ==
                                //               updatedVisitor.visitorId,
                                //         );
                                //     if (filteredIndex != -1) {
                                //       _filteredVisitors[filteredIndex] =
                                //           updatedVisitor;
                                //     }
                                //   });
                                //   await _fetchVisitorStats();
                                //   await _fetchVisitors();
                                // }
                              },
                            ),
                          ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Close',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpCard(FollowUp followUp) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFollowUpMethodColor(followUp.method).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFollowUpMethodIcon(followUp.method),
              color: _getFollowUpMethodColor(followUp.method),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      followUp.followUpDate ?? 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getFollowUpOutcomeColor(
                          followUp.outcome,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getFollowUpOutcomeColor(
                            followUp.outcome,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        followUp.outcome,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getFollowUpOutcomeColor(followUp.outcome),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.record_voice_over_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Method: ${followUp.method}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'By: ${followUp.followedUpBy}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (followUp.notes != null && followUp.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes: ${followUp.notes!}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Visitor visitor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionButton(
            'Add Follow-up',
            Icons.add_circle_outline,
            Colors.green,
            () {
              _showAddFollowUpDialog(visitor);
            },
          ),
          _buildQuickActionButton(
            'Convert to Member',
            Icons.person_add,
            Colors.blue,
            () {
              _showConvertToMemberDialog(visitor);
            },
          ),
          _buildQuickActionButton(
            'Schedule Visit',
            Icons.calendar_today,
            Colors.orange,
            () {
              _showScheduleVisitDialog(visitor);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard(String message, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 2,
          width: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade800,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.grey.shade300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDetailCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Status color helpers
  Color _getVisitorStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'follow-up':
        return Colors.orange;
      case 'converted':
        return Colors.green;
      case 'dropped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatVisitorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'New Visitor';
      case 'follow-up':
        return 'In Follow-up ';
      case 'converted':
        return 'Converted to Member';
      case 'dropped':
        return 'No Longer Visiting';
      default:
        return status;
    }
  }

  Color _getFollowUpMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'call':
        return Colors.green;
      case 'visit':
        return Colors.blue;
      case 'sms':
        return Colors.purple;
      case 'whatsapp':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getFollowUpMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'call':
        return Icons.phone;
      case 'visit':
        return Icons.home;
      case 'sms':
        return Icons.sms;
      case 'whatsapp':
        return Icons.chat;
      default:
        return Icons.record_voice_over;
    }
  }

  Color _getFollowUpOutcomeColor(String outcome) {
    switch (outcome.toLowerCase()) {
      case 'interested':
        return Colors.green;
      case 'needs prayer':
        return Colors.orange;
      case 'converted':
        return Colors.blue;
      case 'not interested':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Table status colors
  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue.shade100;
      case 'Follow-up':
        return Colors.orange.shade100;
      case 'Converted':
        return Colors.green.shade100;
      case 'Dropped':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusDotColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue;
      case 'Follow-up':
        return Colors.orange;
      case 'Converted':
        return Colors.green;
      case 'Dropped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue.shade800;
      case 'Follow-up':
        return Colors.orange.shade800;
      case 'Converted':
        return Colors.green.shade800;
      case 'Dropped':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  // TODO: Implement these dialog methods
  void _showAddFollowUpDialog(Visitor visitor) {
    // Implement add follow-up dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Follow-up for ${visitor.names}'),
        content: Text('Follow-up functionality to be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showConvertToMemberDialog(Visitor visitor) {
    // Implement convert to member dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Convert ${visitor.names} to Member'),
        content: Text('Convert to member functionality to be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showScheduleVisitDialog(Visitor visitor) {
    // Implement schedule visit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Visit for ${visitor.names}'),
        content: Text('Schedule visit functionality to be implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
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
                child: _buildVisitorScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const TopHeaderWidget(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Manage Visitors",
                      style: GoogleFonts.inter(
                        color: titlepageColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: containerColor,
                      ),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Visitorboxwidget(
                            iconPath: 'assets/icons/allvi.svg',
                            label: 'Total Visitors',
                            count: _visitorStats['total'].toString(),
                            backgroundColor: statboxColor,
                          ),
                          Visitorboxwidget(
                            label: 'New',
                            count: _visitorStats['new'].toString(),
                            iconPath: 'assets/icons/newm.svg',
                            backgroundColor: statboxColor,
                          ),
                          Visitorboxwidget(
                            label: 'In Follow-up',
                            count: _visitorStats['followedUp'].toString(),
                            iconPath: 'assets/icons/followup.svg',
                            backgroundColor: statboxColor,
                          ),
                          Visitorboxwidget(
                            label: 'Converted',
                            count: _visitorStats['converted'].toString(),
                            iconPath: 'assets/icons/converted.svg',
                            backgroundColor: statboxColor,
                          ),
                          Visitorboxwidget(
                            label: 'Dropped',
                            count: _visitorStats['dropped'].toString(),
                            iconPath: 'assets/icons/drop.svg',
                            backgroundColor: statboxColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header with Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 460),
                        Text(
                          "Visitors List",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 280),
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin')
                          ElevatedButton.icon(
                            onPressed: () async {
                              final newVisitor = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddVisitorScreen(
                                    loggedInUser: widget.loggedInUser,
                                  ),
                                ),
                              );
                              if (newVisitor != null && newVisitor is Visitor) {
                                setState(() {
                                  _visitors.insert(0, newVisitor);
                                  _filteredVisitors = _visitors;
                                  _currentPage = 0;
                                });
                                await _fetchVisitorStats();
                              }
                            },
                            icon: SvgPicture.asset("assets/icons/visitor.svg"),
                            label: Text(
                              'Add Visitor',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Data Table
                  _isLoading
                      ? Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Scrollbar(
                            controller: _horizontalScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _horizontalScrollController,
                              child: Column(
                                children: [
                                  // Filter Row
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        _buildFilterField(
                                          _nameFilterController,
                                          'Search Name',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _phoneFilterController,
                                          'Search Phone',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildGenderDropdown(),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _emailFilterController,
                                          'Search Email',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _addressFilterController,
                                          'Search Address',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _visitDateFilterController,
                                          'Visit Date (MM/dd/yyyy)',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusDropdown(),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _levelFilterController,
                                          'Search Level',
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Data Table
                                  Stack(
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 300,
                                        ),
                                        child: SizedBox(
                                          width: 1600,
                                          child: DataTable(
                                            horizontalMargin: 12,
                                            dataRowMaxHeight: 56,
                                            headingRowHeight: 48,
                                            dividerThickness: 1,
                                            headingRowColor:
                                                WidgetStateProperty.all(
                                                  Colors.deepPurple,
                                                ),
                                            dataRowColor:
                                                WidgetStateProperty.all(
                                                  backgroundcolor,
                                                ),
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                              verticalInside: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                              top: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                              bottom: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                              left: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                              right: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            columns: [
                                              DataColumn(
                                                label: Text(
                                                  'Name',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Phone',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Gender',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Email',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Address',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Visit Date',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'STATUS',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Level Name',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Actions',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            rows: displayedVisitors.isEmpty
                                                ? [
                                                    DataRow(
                                                      cells: List.generate(
                                                        9,
                                                        (_) => const DataCell(
                                                          SizedBox(),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                : displayedVisitors
                                                      .map(_buildDataRow)
                                                      .toList(),
                                          ),
                                        ),
                                      ),
                                      if (displayedVisitors.isEmpty)
                                        Positioned(
                                          left: 426,
                                          top: 120,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.search_off,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'No Visitors found',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Pagination Controls
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: hasPreviousPage
                                              ? _previousPage
                                              : null,
                                          icon: const Icon(Icons.arrow_back),
                                          label: const Text('Previous'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: hasPreviousPage
                                                ? Colors.deepPurple
                                                : Colors.grey,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Page ${_currentPage + 1}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton.icon(
                                          onPressed: hasNextPage
                                              ? _nextPage
                                              : null,
                                          icon: const Icon(Icons.arrow_forward),
                                          label: const Text('Next'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: hasNextPage
                                                ? Colors.deepPurple
                                                : Colors.grey,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 36),
                                        // Page size selector
                                        Container(
                                          height: 43,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.deepPurple.shade700,
                                                Colors.deepPurple.shade500,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: DropdownButton<int>(
                                            value: _pageSize,
                                            underline: const SizedBox(),
                                            dropdownColor:
                                                Colors.deepPurple.shade600,
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.white,
                                            ),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            items: _pageSizeOptions.map((size) {
                                              return DropdownMenuItem(
                                                value: size,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.table_rows,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '$size rows',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            selectedItemBuilder: (context) {
                                              return _pageSizeOptions.map((
                                                size,
                                              ) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.view_list,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '$size rows',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList();
                                            },
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _pageSize = value;
                                                  _currentPage = 0;
                                                });
                                                if (_isFiltering) {
                                                  _applySearchFilter();
                                                } else {
                                                  _fetchVisitors();
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Footer
                  Center(
                    child: Text(
                      '© 2025 All rights reserved. Church CRM System',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterField(TextEditingController controller, String hint) {
    return SizedBox(
      width: 207,
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: (_) => _onFilterChanged(),
        style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return SizedBox(
      width: 150,
      height: 40,
      child: DropdownButtonFormField<String>(
        value: _statusFilter,
        onChanged: (value) {
          setState(() {
            _statusFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Status', 'New', 'Follow-up', 'Converted', 'Dropped'].map((
          status,
        ) {
          return DropdownMenuItem(
            value: status,
            child: Text(
              status,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Status', 'New', 'Follow-up', 'Converted', 'Dropped'].map(
            (status) {
              return Text(
                status,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
              );
            },
          ).toList();
        },
        dropdownColor: backgroundcolor,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return SizedBox(
      width: 150,
      height: 40,
      child: DropdownButtonFormField<String>(
        value: _genderFilter,
        onChanged: (value) {
          setState(() {
            _genderFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Gender', 'Male', 'Female'].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Text(
              gender,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Gender', 'Male', 'Female'].map((gender) {
            return Text(
              gender,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
            );
          }).toList();
        },
        dropdownColor: backgroundcolor,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
