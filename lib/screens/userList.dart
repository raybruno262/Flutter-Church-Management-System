// import 'package:flutter/material.dart';
// import 'package:flutter_churchcrm_system/controller/user_controller.dart';
// import 'package:flutter_churchcrm_system/model/user_model.dart';
// import 'package:flutter_churchcrm_system/screens/createUser.dart';
// import 'package:flutter_churchcrm_system/screens/updateUser.dart';

// class PaginatedUsersPage extends StatefulWidget {
//   @override
//   _PaginatedUsersPageState createState() => _PaginatedUsersPageState();
// }

// class _PaginatedUsersPageState extends State<PaginatedUsersPage> {
//   final UserController _controller = UserController();
//   final TextEditingController _searchController = TextEditingController();

//   int _currentPage = 0;
//   final int _pageSize = 5;
//   List<UserModel> _users = [];
//   List<UserModel> _filteredUsers = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//     _searchController.addListener(_applySearchFilter);
//   }

//   Future<void> _fetchUsers() async {
//     try {
//       final users = await _controller.getPaginatedUsers(
//         page: _currentPage,
//         size: _pageSize,
//       );
//       setState(() {
//         _users = users.reversed.toList(); // Show newest first
//         _filteredUsers = _users;
//       });
//     } catch (e) {
//       setState(() {
//         _users = [];
//         _filteredUsers = [];
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load users')));
//     }
//   }

//   void _applySearchFilter() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredUsers = _users.where((user) {
//         final fields = [
//           user.names,
//           user.email,
//           user.phone,
//           user.role,
//           user.password,
//           user.nationalId?.toString() ?? '',
//           user.userId ?? '',
//           user.isActive ? 'active' : 'inactive',
//           user.level?.name ?? '',
//         ];
//         return fields.any((field) => field.toLowerCase().contains(query));
//       }).toList();
//     });
//   }

//   void _nextPage() {
//     _currentPage++;
//     _fetchUsers();
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       _currentPage--;
//       _fetchUsers();
//     }
//   }

//   DataRow _buildDataRow(UserModel user) {
//     return DataRow(
//       cells: [
//         DataCell(
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundImage: user.profilePic != null
//                     ? MemoryImage(user.profilePic!)
//                     : null,
//                 child: user.profilePic == null ? Icon(Icons.person) : null,
//                 radius: 20,
//               ),
//               SizedBox(width: 8),
//               Text(user.names),
//             ],
//           ),
//         ),
//         DataCell(Text(user.email)),
//         DataCell(Text(user.phone)),
//         DataCell(Text(user.role)),
//         DataCell(Text(user.nationalId?.toString() ?? '—')),
//         DataCell(Text(user.isActive ? 'Active' : 'Inactive')),
//         DataCell(Text(user.level?.name ?? '—')),
//         DataCell(Text('Baptized')), // Replace with actual field
//         DataCell(
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.edit, color: Colors.blue),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => UpdateUserPage(user: user),
//                     ),
//                   ).then((updated) {
//                     if (updated == true) _fetchUsers(); // Refresh after update
//                   });
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.red),
//                 onPressed: () {
//                   // Optional: implement delete logic
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Church Members'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: ElevatedButton.icon(
//               onPressed: () async {
//                 final newUser = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CreateUserPage()),
//                 );

//                 if (newUser != null && newUser is UserModel) {
//                   setState(() {
//                     _users.insert(0, newUser); // Add to top
//                     _filteredUsers = _users;
//                     _currentPage = 0; // Reset to first page
//                   });
//                 }
//               },
//               icon: Icon(Icons.add),
//               label: Text('Add Member'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search members...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           _filteredUsers.isEmpty
//               ? Expanded(child: Center(child: Text('No users found')))
//               : Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       columnSpacing: 20,
//                       headingRowColor: MaterialStateProperty.all(
//                         Colors.grey.shade200,
//                       ),
//                       columns: [
//                         DataColumn(label: Text('Member')),
//                         DataColumn(label: Text('Email')),
//                         DataColumn(label: Text('Phone')),
//                         DataColumn(label: Text('Role')),
//                         DataColumn(label: Text('National ID')),
//                         DataColumn(label: Text('Status')),
//                         DataColumn(label: Text('Level')),
//                         DataColumn(label: Text('Baptism')),
//                         DataColumn(label: Text('Actions')),
//                       ],
//                       rows: _filteredUsers.map(_buildDataRow).toList(),
//                     ),
//                   ),
//                 ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _previousPage,
//                   child: Text('Previous'),
//                 ),
//                 SizedBox(width: 16),
//                 Text('Page ${_currentPage + 1}'),
//                 SizedBox(width: 16),
//                 ElevatedButton(onPressed: _nextPage, child: Text('Next')),
//               ],
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             '© 2025 All rights reserved. Church CRM System.',
//             style: TextStyle(color: Colors.grey),
//           ),
//           SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }
