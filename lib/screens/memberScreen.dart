import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/controller/department_controller.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/department_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/addMemberScreen.dart';
import 'package:flutter_churchcrm_system/screens/updateMemberScreen.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_churchcrm_system/controller/member_controller.dart';
import 'package:flutter_churchcrm_system/model/member_model.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';

class MemberScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const MemberScreen({super.key, required this.loggedInUser});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  String _statusFilter =
      'All Status'; // Options: All, Active, Inactive, Transferred
  final _nameFilterController = TextEditingController();
  final _phoneFilterController = TextEditingController();
  final _emailFilterController = TextEditingController();
  String _genderFilter = 'All Gender';
  String _maritalFilter = 'All Marital Status';
  String _baptismFilter = 'All Baptism Status';

  final _addressFilterController = TextEditingController();
  final _dobFilterController = TextEditingController();
  final _membershipFilterController = TextEditingController();
  final _departmentFilterController = TextEditingController();
  final _levelFilterController = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();

  final MemberController _controller = MemberController();
  final UserController _usercontroller = UserController();
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 15, 20];
  List<Member> _members = [];
  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  List<Department> _departments = [];
  final DepartmentController _departmentController = DepartmentController();
  Department? _selectedDepartment;
  bool _isLoading = true;

  bool _isFiltering = false;
  Future<void> _loadDepartments() async {
    final departments = await _departmentController.getAllDepartments();
    if (mounted) {
      setState(() => _departments = departments);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _fetchAllMembers();
    _fetchMemberStats();
    _loadDepartments();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _controller.getPaginatedMembers(
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _members = members;
        _filteredMembers = _members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllMembers() async {
    try {
      final allMembers = await _controller.getAllMembers();
      setState(() {
        _allMembers = allMembers;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();
    final dobQuery = _dobFilterController.text;
    final phoneQuery = _phoneFilterController.text.toLowerCase();

    final emailQuery = _emailFilterController.text.toLowerCase();
    final addressQuery = _addressFilterController.text.toLowerCase();
    final membershipQuery = _membershipFilterController.text;

    final levelQuery = _levelFilterController.text.toLowerCase();

    final filtered = _allMembers.where((member) {
      final matchesName = member.names.toLowerCase().contains(nameQuery);
      final matchesPhone = member.phone.toLowerCase().contains(phoneQuery);
      final matchesEmail = member.email.toLowerCase().contains(emailQuery);
      final matchesGender =
          _genderFilter == 'All Gender' || member.gender == _genderFilter;
      final matchesMarital =
          _maritalFilter == 'All Marital Status' ||
          member.maritalStatus == _maritalFilter;

      final selectedDeptId = _selectedDepartment?.departmentId;

      final matchesDept = selectedDeptId == null || selectedDeptId == 'all'
          ? true
          : selectedDeptId == 'none'
          ? member.department == null
          : selectedDeptId == 'others'
          ? member.department == null || member.department?.name == 'Others'
          : member.department!.departmentId == selectedDeptId;

      final matchesAddress = member.address.toLowerCase().contains(
        addressQuery,
      );

      // Date filters - only apply if query is not empty
      final matchesDOB =
          dobQuery.isEmpty || (member.dateOfBirth?.contains(dobQuery) ?? false);
      final matchesMembership =
          membershipQuery.isEmpty ||
          (member.membershipDate?.contains(membershipQuery) ?? false);

      final matchesLevel =
          levelQuery.isEmpty ||
          (member.level?.name?.toLowerCase().contains(levelQuery) ?? false);

      final status = (member.baptismInformation!.baptized)
          ? 'Baptized'
          : 'Not Baptized';
      final matchesBaptismStatus =
          _baptismFilter == 'All Baptism Status' || status == _baptismFilter;

      // Status filter
      final matchesStatus =
          _statusFilter == 'All Status' || member.status == _statusFilter;

      return matchesName &&
          matchesPhone &&
          matchesEmail &&
          matchesGender &&
          matchesMarital &&
          matchesAddress &&
          matchesDOB &&
          matchesMembership &&
          matchesDept &&
          matchesLevel &&
          matchesBaptismStatus &&
          matchesStatus;
    }).toList();

    setState(() {
      _filteredMembers = filtered;
      _currentPage = 0; // Reset to first page when filtering
    });
  }

  void _onFilterChanged() async {
    final isDefaultFilter =
        _nameFilterController.text.isEmpty &&
        _phoneFilterController.text.isEmpty &&
        _emailFilterController.text.isEmpty &&
        _genderFilter == 'All Gender' &&
        _maritalFilter == 'All Marital Status' &&
        _addressFilterController.text.isEmpty &&
        _dobFilterController.text.isEmpty &&
        _membershipFilterController.text.isEmpty &&
        _departmentFilterController.text.isEmpty &&
        _levelFilterController.text.isEmpty &&
        _baptismFilter == 'All Baptism Status' &&
        _statusFilter == 'All Status';

    if (isDefaultFilter) {
      _isFiltering = false;
      _currentPage = 0;
      await _fetchMembers();
    } else {
      _isFiltering = true;
      await _fetchAllMembers();
      _applySearchFilter();
    }
  }

  Future<void> _nextPage() async {
    if (_isFiltering) {
      if ((_currentPage + 1) * _pageSize < _filteredMembers.length) {
        setState(() => _currentPage++);
      }
    } else {
      setState(() => _currentPage++);
      await _fetchMembers();
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      if (_isFiltering) {
        // No need to fetch for filtered data, just update UI
        setState(() {});
      } else {
        await _fetchMembers();
      }
    }
  }

  List<Member> get displayedMembers {
    if (_isFiltering) {
      if (_filteredMembers.isEmpty) return [];
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      return _filteredMembers.sublist(
        start,
        end > _filteredMembers.length ? _filteredMembers.length : end,
      );
    } else {
      return _members;
    }
  }

  Map<String, int> _memberStats = {
    'total': 0,
    'active': 0,
    'inactive': 0,
    'transferred': 0,
  };

  Future<void> _fetchMemberStats() async {
    try {
      final loggedInUser = await _usercontroller.loadUserFromStorage();

      if (loggedInUser == null || loggedInUser.userId == null) {
        setState(() {
          _memberStats = {
            'total': 0,
            'active': 0,
            'inactive': 0,
            'transferred': 0,
          };
        });
        return;
      }

      final stats = await _controller.getMemberStats(loggedInUser.userId!);

      final updatedStats = {
        'total': stats['total'] ?? 0,
        'active': stats['active'] ?? 0,
        'inactive': stats['inactive'] ?? 0,
        'transferred': stats['transferred'] ?? 0,
      };

      setState(() {
        _memberStats = updatedStats;
      });
    } catch (e) {
      setState(() {
        _memberStats = {
          'total': 0,
          'active': 0,
          'inactive': 0,
          'transferred': 0,
        };
      });
    }
  }

  DataRow _buildDataRow(Member member) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              member.profilePic != null
                  ? CircleAvatar(
                      radius: 12,
                      backgroundImage: MemoryImage(member.profilePic!),
                    )
                  : const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(member.names, style: GoogleFonts.inter(fontSize: 13)),
            ],
          ),
        ),
        DataCell(Text(member.dateOfBirth ?? 'N/A', style: GoogleFonts.inter())),
        DataCell(Text(member.phone, style: GoogleFonts.inter())),
        DataCell(Text(member.gender, style: GoogleFonts.inter())),
        DataCell(Text(member.maritalStatus, style: GoogleFonts.inter())),
        DataCell(Text(member.email, style: GoogleFonts.inter())),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(member.status),
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
                    color: _getStatusDotColor(member.status),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  member.status,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(member.status),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(Text(member.address, style: GoogleFonts.inter())),
        DataCell(
          Text(member.membershipDate ?? 'N/A', style: GoogleFonts.inter()),
        ),
        DataCell(
          Text(member.department?.name ?? 'N/A', style: GoogleFonts.inter()),
        ),
        DataCell(Text(member.level?.name ?? 'N/A', style: GoogleFonts.inter())),
        DataCell(
          Text(
            member.baptismInformation?.baptized == true ? 'Yes' : 'No',
            style: GoogleFonts.inter(),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                tooltip: 'View Member',
                onPressed: () {
                  _showMemberDetailsDialog(member);
                },
              ),
              if (widget.loggedInUser.role == 'CellAdmin' ||
                  widget.loggedInUser.role == 'SuperAdmin') ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Update Member',
                  onPressed: () async {
                    final updatedMember = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateMemberScreen(
                          loggedInUser: widget.loggedInUser,
                          member: member,
                        ),
                      ),
                    );

                    if (updatedMember != null && updatedMember is Member) {
                      setState(() {
                        final index = _members.indexWhere(
                          (m) => m.memberId == updatedMember.memberId,
                        );
                        if (index != -1) {
                          _members[index] = updatedMember;
                        }

                        final filteredIndex = _filteredMembers.indexWhere(
                          (m) => m.memberId == updatedMember.memberId,
                        );
                        if (filteredIndex != -1) {
                          _filteredMembers[filteredIndex] = updatedMember;
                        }
                      });

                      await _fetchMemberStats();
                      await _fetchMembers();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showMemberDetailsDialog(Member member) {
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
                  // Header with profile image
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.purple.shade700],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Large Profile Image
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
                          ),
                          child: ClipOval(
                            child: member.profilePic != null
                                ? Image.memory(
                                    member.profilePic!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildDefaultAvatar(120),
                                  )
                                : _buildDefaultAvatar(120),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name with beautiful typography
                        Text(
                          member.names,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(member.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            member.status,
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
                        // Personal Information Section
                        _buildSectionHeader('Personal Information'),
                        const SizedBox(height: 16),

                        // Two-column layout for better space utilization
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildEnhancedDetailCard(
                                    'Email',
                                    member.email,
                                    Icons.email_outlined,
                                    Colors.blue,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Phone',
                                    member.phone,
                                    Icons.phone_outlined,
                                    Colors.green,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Gender',
                                    member.gender,
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
                                    'Marital Status',
                                    member.maritalStatus,
                                    Icons.favorite_outline,
                                    Colors.red,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Date of Birth',
                                    member.dateOfBirth ?? 'N/A',
                                    Icons.cake_outlined,
                                    Colors.orange,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEnhancedDetailCard(
                                    'Membership Date',
                                    member.membershipDate ?? 'N/A',
                                    Icons.date_range_outlined,
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
                          member.address,
                          Icons.location_on_outlined,
                          Colors.deepOrange,
                          fullWidth: true,
                        ),

                        const SizedBox(height: 24),

                        // Church Information Section
                        _buildSectionHeader('Church Information'),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildEnhancedDetailCard(
                                'Department',
                                member.department?.name ?? 'N/A',
                                Icons.account_tree_outlined,
                                Colors.indigo,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildEnhancedDetailCard(
                                'Level',
                                member.level?.name ?? 'N/A',
                                Icons.leaderboard_outlined,
                                Colors.cyan,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Baptism Information Section
                        _buildSectionHeader('Baptism Information'),
                        const SizedBox(height: 16),
                        _buildEnhancedDetailCard(
                          'Baptized',
                          member.baptismInformation?.baptized == true
                              ? 'Yes'
                              : 'No',
                          Icons.water_drop_outlined,
                          member.baptismInformation?.baptized == true
                              ? Colors.blue
                              : Colors.grey,
                          fullWidth: true,
                        ),

                        if (member.baptismInformation?.baptized == true) ...[
                          const SizedBox(height: 12),
                          _buildEnhancedDetailCard(
                            'Same Religion',
                            member.baptismInformation?.sameReligion == true
                                ? 'Yes'
                                : 'No',
                            Icons.church_outlined,
                            member.baptismInformation?.sameReligion == true
                                ? Colors.green
                                : Colors.grey,
                            fullWidth: true,
                          ),

                          if (member.baptismInformation?.sameReligion ==
                              true) ...[
                            const SizedBox(height: 12),
                            _buildEnhancedDetailCard(
                              'Baptism Cell',
                              member.baptismInformation?.baptismCell?.name ??
                                  'N/A',
                              Icons.groups_outlined,
                              Colors.purple,
                              fullWidth: true,
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            _buildEnhancedDetailCard(
                              'Other Church Name',
                              member.baptismInformation?.otherChurchName ??
                                  'N/A',
                              Icons.church_outlined,
                              Colors.orange,
                              fullWidth: true,
                            ),
                            const SizedBox(height: 12),
                            _buildEnhancedDetailCard(
                              'Other Church Address',
                              member.baptismInformation?.otherChurchAddress ??
                                  'N/A',
                              Icons.location_city_outlined,
                              Colors.brown,
                              fullWidth: true,
                            ),
                          ],
                        ],

                        const SizedBox(height: 24),
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
                                  Colors.blue.shade600,
                                  Colors.blue.shade800,
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
                                'Update Profile',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () async {
                                final updatedMember = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateMemberScreen(
                                      loggedInUser: widget.loggedInUser,
                                      member: member,
                                    ),
                                  ),
                                );
                                if (updatedMember != null &&
                                    updatedMember is Member) {
                                  setState(() {
                                    final index = _members.indexWhere(
                                      (m) =>
                                          m.memberId == updatedMember.memberId,
                                    );
                                    if (index != -1) {
                                      _members[index] = updatedMember;
                                    }

                                    final filteredIndex = _filteredMembers
                                        .indexWhere(
                                          (m) =>
                                              m.memberId ==
                                              updatedMember.memberId,
                                        );
                                    if (filteredIndex != -1) {
                                      _filteredMembers[filteredIndex] =
                                          updatedMember;
                                    }
                                  });

                                  await _fetchMemberStats();
                                  await _fetchMembers();
                                }
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

  // Helper method for default avatar
  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey.shade600),
    );
  }

  // Helper method for section headers
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

  // Enhanced detail card widget
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

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? Drawer(
              child: SideMenuWidget(
                selectedTitle: 'Members',
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
                  selectedTitle: 'Members',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildMemberScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberScreen() {
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
                      "Manage Members",
                      style: GoogleFonts.inter(
                        color: titlepageColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                          StatBox(
                            iconPath: 'assets/icons/tmember.svg',
                            label: 'Total Members',
                            count: _memberStats['total'].toString(),
                            backgroundColor: statboxColor,
                          ),
                          StatBox(
                            label: 'Total Active',
                            count: _memberStats['active'].toString(),
                            iconPath: 'assets/icons/member.svg',
                            backgroundColor: statboxColor,
                          ),
                          StatBox(
                            label: 'Total Inactive',
                            count: _memberStats['inactive'].toString(),
                            iconPath: 'assets/icons/inactive.svg',
                            backgroundColor: statboxColor,
                          ),
                          StatBox(
                            label: 'Total Transferred',
                            count: _memberStats['transferred'].toString(),
                            iconPath: 'assets/icons/tran.svg',
                            backgroundColor: statboxColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 460),
                        Text(
                          "Members List",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 280),
                        if (widget.loggedInUser.role == 'CellAdmin' ||
                            widget.loggedInUser.role == 'SuperAdmin') ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              final newMember = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMemberScreen(
                                    loggedInUser: widget.loggedInUser,
                                  ),
                                ),
                              );

                              if (newMember != null && newMember is Member) {
                                setState(() {
                                  _members.insert(0, newMember);
                                  _filteredMembers = _members;
                                  _currentPage = 0;
                                });

                                // Refresh stats
                                await _fetchMemberStats();
                              }
                            },
                            icon: SvgPicture.asset("assets/icons/member.svg"),
                            label: Text(
                              'Add Member',
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

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
                                          _dobFilterController,
                                          'Search DOB(MM/dd/yyyy)',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _phoneFilterController,
                                          'Search Phone',
                                        ),

                                        const SizedBox(width: 8),
                                        _buildGenderDropdown(),

                                        const SizedBox(width: 8),
                                        _buildMaritalDropdown(),

                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _emailFilterController,
                                          'Search Email',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusDropdown(),

                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _addressFilterController,
                                          'Search Address',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _membershipFilterController,
                                          'Search Membership Date',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildDepartmentDropdown(
                                          _selectedDepartment,
                                          (dept) {
                                            setState(() {
                                              _selectedDepartment = dept;
                                            });
                                            _onFilterChanged();
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _levelFilterController,
                                          'Search Level',
                                        ),

                                        const SizedBox(width: 8),
                                        _buildBaptismStatusDropdown(),
                                      ],
                                    ),
                                  ),

                                  Stack(
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 300,
                                        ),
                                        child: SizedBox(
                                          width: 2200,
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
                                                label: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.person,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Member',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Date of Birth',
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
                                                  'Marital Status',
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
                                                  'Membership Date',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Department',
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
                                                  'Baptized',
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
                                            rows: displayedMembers.isEmpty
                                                ? [
                                                    DataRow(
                                                      cells: List.generate(
                                                        13,
                                                        (_) => const DataCell(
                                                          SizedBox(),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                : displayedMembers
                                                      .map(_buildDataRow)
                                                      .toList(),
                                          ),
                                        ),
                                      ),
                                      if (displayedMembers.isEmpty)
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
                                                'No Members found',
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
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _previousPage,
                                          icon: const Icon(Icons.arrow_back),
                                          label: const Text('Previous'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple,
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
                                          onPressed: _nextPage,
                                          icon: const Icon(Icons.arrow_forward),
                                          label: const Text('Next'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple,
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
                                                  _fetchMembers();
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

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: Colors.transparent,
                      child: Center(
                        child: Text(
                          '© 2025 All rights reserved. Church CRM System',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
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
      width: 180, // Increased width for better usability
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
        initialValue: _statusFilter,
        onChanged: (value) {
          setState(() {
            _statusFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Status', 'Active', 'Inactive', 'Transferred'].map((
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
          return ['All Status', 'Active', 'Inactive', 'Transferred'].map((
            role,
          ) {
            return Text(
              role,
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

  Widget _buildGenderDropdown() {
    return SizedBox(
      width: 150,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _genderFilter,
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
          return ['All Gender', 'Male', 'Female'].map((role) {
            return Text(
              role,
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

  Widget _buildMaritalDropdown() {
    return SizedBox(
      width: 180,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _maritalFilter,
        onChanged: (value) {
          setState(() {
            _maritalFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Marital Status', 'Single', 'Married', 'Divorced'].map((
          maritalStatus,
        ) {
          return DropdownMenuItem(
            value: maritalStatus,
            child: Text(
              maritalStatus,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Marital Status', 'Single', 'Married', 'Divorced'].map((
            role,
          ) {
            return Text(
              role,
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

  Widget _buildDepartmentDropdown(
    Department? selectedDepartment,
    void Function(Department?) onChanged,
  ) {
    return SizedBox(
      width: 180,
      height: 40,
      child: DropdownButtonFormField<String>(
        value: selectedDepartment?.departmentId ?? 'all',
        onChanged: (String? selectedId) {
          if (selectedId == 'others') {
            setState(() {
              _selectedDepartment = Department(
                departmentId: 'others',
                name: 'Others',
              );
            });
            onChanged(_selectedDepartment);
          } else if (selectedId == 'none') {
            setState(() {
              _selectedDepartment = Department(
                departmentId: 'none',
                name: 'None',
              );
            });
            onChanged(_selectedDepartment);
          } else if (selectedId == 'all') {
            setState(() {
              _selectedDepartment = null;
            });
            onChanged(null);
          } else {
            final dept = _departments.firstWhere(
              (d) => d.departmentId == selectedId,
              orElse: () => _departments.first,
            );
            setState(() {
              _selectedDepartment = dept;
            });
            onChanged(dept);
          }
        },
        items: [
          DropdownMenuItem(
            value: 'all',
            child: Text(
              'All Departments',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: 'none',
            child: Text(
              'None',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ),
          ..._departments.map((department) {
            return DropdownMenuItem<String>(
              value: department.departmentId,
              child: Text(
                department.name,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            );
          }),
          DropdownMenuItem(
            value: 'others',
            child: Text(
              'Others',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          ),
        ],
        selectedItemBuilder: (context) {
          final labels = [
            'All Departments',
            'None',
            ..._departments.map((d) => d.name),
            'Others',
          ];
          return labels.map((label) {
            return Text(
              label,
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

        menuMaxHeight: 250,
      ),
    );
  }

  Widget _buildBaptismStatusDropdown() {
    return SizedBox(
      width: 200,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _baptismFilter,
        onChanged: (value) {
          setState(() {
            _baptismFilter = value!;
            _onFilterChanged();
          });
        },
        items: ['All Baptism Status', 'Baptized', 'Not Baptized'].map((
          baptism,
        ) {
          return DropdownMenuItem(
            value: baptism,
            child: Text(
              baptism,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Baptism Status', 'Baptized', 'Not Baptized'].map((
            baptism,
          ) {
            return Text(
              baptism,
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

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green.shade100;
      case 'Inactive':
        return Colors.red.shade100;
      case 'Transferred':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusDotColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.redAccent;
      case 'Transferred':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green.shade800;
      case 'Inactive':
        return Colors.red.shade500;
      case 'Transferred':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade600;
    }
  }
}
