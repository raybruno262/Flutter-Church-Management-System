import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/statBoxWidget.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';

import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_churchcrm_system/controller/member_controller.dart';
import 'package:flutter_churchcrm_system/model/member_model.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';

class UserScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const UserScreen({super.key, required this.loggedInUser});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String _statusFilter = 'All Status'; // Options: All, Active, Inactive
  final _nameFilterController = TextEditingController();
  final _usernameFilterController = TextEditingController();
  final _emailFilterController = TextEditingController();

  final _phoneFilterController = TextEditingController();

  final _nationalIdFilterController = TextEditingController();
  String _roleFilter =
      'All Roles'; //Options: SuperAdmin,RegionAdmin,ParishAdmin,ChapelAdmin,CellAdmin
  final _levelFilterController = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();

  final UserController _controller = UserController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 0;
  final int _pageSize = 5;
  List<UserModel> _users = [];
  // ignore: unused_field
  List<UserModel> _filteredUsers = [];

  bool _isLoading = true;
  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_applySearchFilter);
    _fetchUserStats();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);

    try {
      final loggedInUser = await _controller.loadUserFromStorage();

      if (loggedInUser == null || loggedInUser.userId == null) {
        setState(() {
          _users = [];
          _filteredUsers = [];
          _isLoading = false;
        });
        return;
      }

      final users = await _controller.getPaginatedUsers(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        _users = users.reversed.toList();
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _users = [];
        _filteredUsers = [];
        _isLoading = false;
      });
    }
  }

  void _applySearchFilter() {
    final nameQuery = _nameFilterController.text.toLowerCase();
    final usernameQuery = _usernameFilterController.text.toLowerCase();
    final emailQuery = _emailFilterController.text.toLowerCase();
    final phoneQuery = _phoneFilterController.text.toLowerCase();
    final nationalIdQuery = _nationalIdFilterController.text.toLowerCase();
    final levelQuery = _levelFilterController.text.toLowerCase();

    _filteredUsers = _users.where((user) {
      final matchesName = user.names.toLowerCase().contains(nameQuery);
      final matchesUserName = user.username.toLowerCase().contains(
        usernameQuery,
      );
      final matchesEmail = user.email.toLowerCase().contains(emailQuery);
      final matchesPhone = user.phone.toLowerCase().contains(phoneQuery);
      final matchesNationalId = user.phone.toLowerCase().contains(
        nationalIdQuery,
      );

      final matchesLevel =
          user.level.name?.toLowerCase().contains(levelQuery) ?? false;

      final status = (user.isActive) ? 'Active' : 'Inactive';
      final matchesStatus =
          _statusFilter == 'All Status' || status == _statusFilter;

      final matchesRole =
          _roleFilter == 'All Roles' || user.role == _roleFilter;

      return matchesName &&
          matchesUserName &&
          matchesEmail &&
          matchesPhone &&
          matchesNationalId &&
          matchesLevel &&
          matchesRole &&
          matchesStatus;
    }).toList();

    setState(() {});
  }

  void _nextPage() {
    _currentPage++;
    _fetchUsers();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _fetchUsers();
    }
  }

  // ignore: unused_field
  Map<String, int> _userStats = {'total': 0, 'active': 0, 'inactive': 0};

  Future<void> _fetchUserStats() async {
    try {
      final loggedInUser = await _controller.loadUserFromStorage();

      if (loggedInUser == null || loggedInUser.userId == null) {
        setState(() {
          _userStats = {'total': 0, 'active': 0, 'inactive': 0};
        });
        return;
      }

      final stats = await _controller.getUserStats(loggedInUser.userId!);

      final updatedStats = {
        'total': stats['total'] ?? 0,
        'active': stats['active'] ?? 0,
        'inactive': stats['inactive'] ?? 0,
      };

      setState(() {
        _userStats = updatedStats;
      });
    } catch (e) {
      setState(() {
        _userStats = {'total': 0, 'active': 0, 'inactive': 0};
      });
    }
  }

  DataRow _buildDataRow(UserModel user) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: MemoryImage(user.profilePic),
              ),
              const SizedBox(width: 8),
              Text(user.names, style: GoogleFonts.inter(fontSize: 13)),
            ],
          ),
        ),
        DataCell(Text(user.username, style: GoogleFonts.inter())),
        DataCell(Text(user.email, style: GoogleFonts.inter())),
        DataCell(Text(user.phone, style: GoogleFonts.inter())),
        DataCell(Text(user.nationalId.toString(), style: GoogleFonts.inter())),
        DataCell(Text(user.role, style: GoogleFonts.inter())),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (user.isActive)
                  ? Colors.green.shade100
                  : Colors.red.shade100,
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
                    color: (user.isActive) ? Colors.green : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  (user.isActive) ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (user.isActive)
                        ? Colors.green.shade800
                        : Colors.red.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),

        DataCell(Text(user.level.name ?? 'N/A', style: GoogleFonts.inter())),

        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.green),
                onPressed: () {
                  // TODO: Navigate to ViewProfilePage
                },
              ),

              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  // TODO: Navigate to UpdateMemberPage
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? Drawer(
              child: SideMenuWidget(
                selectedTitle: 'Users',
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
                  selectedTitle: 'Users',
                  loggedInUser: widget.loggedInUser,
                ),
              ),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildUserScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserScreen() {
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
                      "Manage Users",
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
                            iconPath: 'assets/icons/totaluser.svg',
                            label: 'Total users',
                            count: _userStats['total'].toString(),
                            backgroundColor: statboxColor,
                          ),
                          StatBox(
                            label: 'Total Active',
                            count: _userStats['active'].toString(),
                            iconPath: 'assets/icons/activeusers.svg',
                            backgroundColor: statboxColor,
                          ),
                          StatBox(
                            label: 'Total Inactive',
                            count: _userStats['inactive'].toString(),
                            iconPath: 'assets/icons/inactiveuser.svg',
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
                        SizedBox(width: 460),
                        Text(
                          "Users List",
                          style: GoogleFonts.inter(
                            color: titlepageColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 280),
                        // if (widget.loggedInUser.role == 'CellAdmin') ...[
                        //   ElevatedButton.icon(
                        //     onPressed: () async {
                        //       final newMember = await Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => AddUserScreen(
                        //             loggedInUser: widget.loggedInUser,
                        //           ),
                        //         ),
                        //       );

                        //       if (newMember != null && newMember is Member) {
                        //         setState(() {
                        //           _members.insert(0, newMember);
                        //           _filteredMembers = _members;
                        //           _currentPage = 0;
                        //         });
                        //       }
                        //     },
                        //     icon: SvgPicture.asset("assets/icons/member.svg"),
                        //     label: Text(
                        //       'Add Member',
                        //       style: GoogleFonts.inter(
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.deepPurple,
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 20,
                        //         vertical: 15,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  _isLoading
                      ? Container(
                          height: 300,

                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
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
                                          _usernameFilterController,
                                          'Search Username',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _emailFilterController,
                                          'Search Email',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _phoneFilterController,
                                          'Search Phone',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _nationalIdFilterController,
                                          'Search NationalID',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildRoleDropdown(),

                                        const SizedBox(width: 8),
                                        _buildStatusDropdown(),
                                        const SizedBox(width: 8),
                                        _buildFilterField(
                                          _levelFilterController,
                                          'Search Level Name',
                                        ),
                                      ],
                                    ),
                                  ),

                                  ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: 300),
                                    child: SizedBox(
                                      width: 1700,

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
                                                Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'User',
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
                                              'Username',
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
                                              'NationalID',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text(
                                                  'Role',
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
                                              'Status',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Level',
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

                                        rows: _filteredUsers.isEmpty
                                            ? [
                                                DataRow(
                                                  cells: List.generate(
                                                    9,
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
                                                                'No Users found',
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
                                            : _filteredUsers
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
                                          icon: Icon(Icons.arrow_back),
                                          label: Text('Previous'),
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
                                          icon: Icon(Icons.arrow_forward),
                                          label: Text('Next'),
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
      width: 222,
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
      width: 150,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _statusFilter,
        onChanged: (value) {
          setState(() {
            _statusFilter = value!;
            _applySearchFilter();
          });
        },
        items: ['All Status', 'Active', 'Inactive'].map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(
              status,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return ['All Status', 'Active', 'Inactive'].map((status) {
            return Text(
              status,
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

  Widget _buildRoleDropdown() {
    return SizedBox(
      width: 150,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: _roleFilter,
        onChanged: (value) {
          setState(() {
            _roleFilter = value!;
            _applySearchFilter();
          });
        },
        items:
            [
              'All Roles',
              'SuperAdmin',
              'RegionAdmin',
              'ParishAdmin',
              'ChapelAdmin',
              'CellAdmin',
            ].map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(
                  role,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                ),
              );
            }).toList(),
        selectedItemBuilder: (context) {
          return [
            'All Roles',
            'SuperAdmin',
            'RegionAdmin',
            'ParishAdmin',
            'ChapelAdmin',
            'CellAdmin',
          ].map((role) {
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
}
