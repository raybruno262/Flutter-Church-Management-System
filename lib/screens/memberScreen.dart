import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';

import 'package:flutter_churchcrm_system/controller/user_controller.dart';
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
  String _statusFilter = 'All'; // Options: All, Active, Inactive, Transferred
  final _nameFilterController = TextEditingController();
  final _phoneFilterController = TextEditingController();
  final _emailFilterController = TextEditingController();
  final _genderFilterController = TextEditingController();
  final _maritalFilterController = TextEditingController();
  final _addressFilterController = TextEditingController();
  final _dobFilterController = TextEditingController();
  final _membershipFilterController = TextEditingController();
  final _departmentFilterController = TextEditingController();
  final _levelFilterController = TextEditingController();
  final _parentFilterController = TextEditingController();
  final _baptizedFilterController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  final MemberController _controller = MemberController();
  final TextEditingController _searchController = TextEditingController();
  final UserController _usercontroller = UserController();
  int _currentPage = 0;
  final int _pageSize = 5;
  List<Member> _members = [];
  List<Member> _filteredMembers = [];

  bool _isLoading = true;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _nameFilterController.dispose();
    _phoneFilterController.dispose();
    _emailFilterController.dispose();
    _genderFilterController.dispose();
    _maritalFilterController.dispose();
    _addressFilterController.dispose();
    _dobFilterController.dispose();
    _membershipFilterController.dispose();
    _departmentFilterController.dispose();
    _levelFilterController.dispose();
    _parentFilterController.dispose();
    _baptizedFilterController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _searchController.addListener(_applySearchFilter);
    _fetchMemberStats();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);

    try {
      final loggedInUser = await _usercontroller.loadUserFromStorage();

      if (loggedInUser == null || loggedInUser.userId == null) {
        setState(() {
          _members = [];
          _filteredMembers = [];
          _isLoading = false;
        });
        return;
      }

      final members = await _controller.getScopedPaginatedMembers(
        userId: loggedInUser.userId!,
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        _members = members.reversed.toList();
        _filteredMembers = _members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _members = [];
        _filteredMembers = [];
        _isLoading = false;
      });
    }
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();
    final phoneQuery = _phoneFilterController.text.toLowerCase();
    final emailQuery = _emailFilterController.text.toLowerCase();
    final genderQuery = _genderFilterController.text.toLowerCase();
    final maritalQuery = _maritalFilterController.text.toLowerCase();
    final addressQuery = _addressFilterController.text.toLowerCase();
    final dobQuery = _dobFilterController.text;
    final membershipQuery = _membershipFilterController.text;
    final deptQuery = _departmentFilterController.text.toLowerCase();
    final levelQuery = _levelFilterController.text.toLowerCase();
    final parentQuery = _parentFilterController.text.toLowerCase();
    final baptizedQuery = _baptizedFilterController.text.toLowerCase();

    _filteredMembers = _members.where((member) {
      final matchesName = member.names.toLowerCase().contains(nameQuery);
      final matchesPhone = member.phone.toLowerCase().contains(phoneQuery);
      final matchesEmail = member.email.toLowerCase().contains(emailQuery);
      final matchesGender = member.gender.toLowerCase().contains(genderQuery);
      final matchesMarital = member.maritalStatus.toLowerCase().contains(
        maritalQuery,
      );
      final matchesAddress = member.address.toLowerCase().contains(
        addressQuery,
      );
      final matchesDOB = dobQuery.isEmpty || member.dateOfBirth == dobQuery;
      final matchesMembership =
          membershipQuery.isEmpty || member.membershipDate == membershipQuery;

      final matchesDept =
          member.department?.name.toLowerCase().contains(deptQuery) ?? false;
      final matchesLevel =
          member.level?.name?.toLowerCase().contains(levelQuery) ?? false;
      final matchesParent = parentQuery.isEmpty
          ? true
          : member.level?.parent?.name?.toLowerCase().contains(parentQuery) ??
                false;

      final baptized = member.baptismInformation?.baptized == true
          ? 'true'
          : 'false';

      final matchesBaptized = baptized.contains(baptizedQuery);

      final matchesStatus =
          _statusFilter == 'All' || member.status == _statusFilter;

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
          matchesParent &&
          matchesBaptized &&
          matchesStatus;
    }).toList();

    setState(() {});
  }

  void _nextPage() {
    _currentPage++;
    _fetchMembers();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _fetchMembers();
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
              if (widget.loggedInUser.role == 'CellAdmin') ...[
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
                        if (widget.loggedInUser.role == 'CellAdmin')
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
                        if (widget.loggedInUser.role == 'CellAdmin') ...[
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

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Member added successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
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
                                          'Search DOB (MM/dd/yyyy)',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _phoneFilterController,
                                          'Search Phone',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _emailFilterController,
                                          'Search Email',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _genderFilterController,
                                          'Search Gender',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _maritalFilterController,
                                          'Search Marital Status',
                                        ),
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
                                        _buildFilterField(
                                          _departmentFilterController,
                                          'Search Department',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _levelFilterController,
                                          'Search Level',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _parentFilterController,
                                          'Search Parent Level',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _baptizedFilterController,
                                          'Baptized (true/false)',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusDropdown(),
                                      ],
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 300,
                                    ),
                                    child: SizedBox(
                                      width: 2000,
                                      child: DataTable(
                                        horizontalMargin: 12,
                                        dataRowMaxHeight: 56,
                                        headingRowHeight: 48,
                                        dividerThickness: 1,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                              Colors.deepPurple,
                                            ),
                                        dataRowColor: WidgetStateProperty.all(
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
                                                    fontWeight: FontWeight.w600,
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
                                        rows: _filteredMembers.isEmpty
                                            ? [
                                                DataRow(
                                                  cells: List.generate(
                                                    13,
                                                    (index) => index == 0
                                                        ? DataCell(
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        40,
                                                                  ),
                                                              child: Text(
                                                                'No members found',
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const DataCell(
                                                            SizedBox(),
                                                          ),
                                                  ),
                                                ),
                                              ]
                                            : _filteredMembers
                                                  .map(_buildDataRow)
                                                  .toList(),
                                      ),
                                    ),
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
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
      width: 147,
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: (_) => _applySearchFilter(),
        style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
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
      width: 130,
      height: 40,
      child: DropdownButtonFormField<String>(
        value: _statusFilter,
        onChanged: (value) {
          setState(() {
            _statusFilter = value!;
            _applySearchFilter();
          });
        },
        items: ['All', 'Active', 'Inactive', 'Transferred'].map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(
              status,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
          );
        }).toList(),
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
