import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/createUser.dart';

class PaginatedUsersPage extends StatefulWidget {
  @override
  _PaginatedUsersPageState createState() => _PaginatedUsersPageState();
}

class _PaginatedUsersPageState extends State<PaginatedUsersPage> {
  final UserController _controller = UserController();
  int _currentPage = 0;
  final int _pageSize = 5;
  bool _isLoading = false;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _controller.getPaginatedUsers(
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _users = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users')));
    }
  }

  void _nextPage() {
    if (_users.length == _pageSize) {
      setState(() => _currentPage++);
      _fetchUsers();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _fetchUsers();
    }
  }

  DataRow _buildDataRow(UserModel user) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundImage: user.profilePic != null
                    ? MemoryImage(user.profilePic!)
                    : null,
                child: user.profilePic == null ? Icon(Icons.person) : null,
                radius: 20,
              ),
              SizedBox(width: 8),
              Text(user.names),
            ],
          ),
        ),
        DataCell(Text(user.email)),
        DataCell(Text(user.phone)),
        DataCell(Text(user.role)),
        DataCell(Text(user.nationalId?.toString() ?? '—')),
        DataCell(Text(user.isActive ? 'Active' : 'Inactive')),
        DataCell(Text(user.level?.name ?? '—')),
        DataCell(Text(user.userId ?? '—')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Church Members')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(child: Text('No users found'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey.shade200,
                      ),
                      columns: [
                        DataColumn(label: Text('Member')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('National ID')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Level')),
                        DataColumn(label: Text('User ID')),
                      ],
                      rows: _users.map(_buildDataRow).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousPage,
                        child: Text('Previous'),
                      ),
                      SizedBox(width: 16),
                      Text('Page ${_currentPage + 1}'),
                      SizedBox(width: 16),
                      ElevatedButton(onPressed: _nextPage, child: Text('Next')),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '© 2025 All rights reserved. Church CRM System.',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 12),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateUserPage()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add User',
      ),
    );
  }
}
