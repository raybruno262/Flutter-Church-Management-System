import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/sidemenu_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/baptismScreen.dart';
import 'package:flutter_churchcrm_system/screens/equipmentScreen.dart';
import 'package:flutter_churchcrm_system/screens/financeScreen.dart';
import 'package:flutter_churchcrm_system/screens/attendanceScreen.dart';
import 'package:flutter_churchcrm_system/screens/birthdayScreen.dart';
import 'package:flutter_churchcrm_system/screens/dashboardScreen.dart';
import 'package:flutter_churchcrm_system/screens/dataBackupScreen.dart';
import 'package:flutter_churchcrm_system/screens/levelScreen.dart';
import 'package:flutter_churchcrm_system/screens/login.dart';
import 'package:flutter_churchcrm_system/screens/memberScreen.dart';
import 'package:flutter_churchcrm_system/screens/messageScreen.dart';
import 'package:flutter_churchcrm_system/screens/reportScreen.dart';
import 'package:flutter_churchcrm_system/screens/settingsScreen.dart';
import 'package:flutter_churchcrm_system/screens/userScreen.dart';
import 'package:flutter_churchcrm_system/screens/visitorScreen.dart';
import 'package:flutter_svg/svg.dart';

class SidemenuData {
  final UserModel loggedInUser;

  SidemenuData({required this.loggedInUser});

  List<SideMenuModel> get sideMenu {
    final allItems = <SideMenuModel>[
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/dashbo.svg', fit: BoxFit.cover),
        title: 'Dashboard',
        page: DashboardScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/level.svg', fit: BoxFit.cover),
        title: 'Levels',
        page: LevelScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/user.svg', fit: BoxFit.cover),
        title: 'Users',
        page: UserScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/member.svg', fit: BoxFit.cover),
        title: 'Members',
        page: MemberScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/birthday.svg', fit: BoxFit.cover),
        title: 'Birthdays',
        page: BirthdayScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/visitor.svg', fit: BoxFit.cover),
        title: 'Visitors',
        page: VisitorScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset(
          'assets/icons/attendance.svg',
          fit: BoxFit.cover,
        ),
        title: 'Attendance',
        page: AttendanceScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/baptism.svg', fit: BoxFit.cover),
        title: 'Baptism',
        page: BaptismScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/finance.svg', fit: BoxFit.cover),
        title: 'Finance',
        page: FinanceScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/equipment.svg', fit: BoxFit.cover),
        title: 'Equipment',
        page: EquipmentScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/report.svg', fit: BoxFit.cover),
        title: 'Reports',
        page: ReportScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/message.svg', fit: BoxFit.cover),
        title: 'Messages',
        page: MessageScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/backup.svg', fit: BoxFit.cover),
        title: 'Data Backup',
        page: DataBackupScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/settings.svg', fit: BoxFit.cover),
        title: 'Settings',
        page: SettingsScreen(loggedInUser: loggedInUser),
      ),
      SideMenuModel(
        icon: SvgPicture.asset('assets/icons/logout.svg', fit: BoxFit.cover),
        title: 'Logout',
        onTap: (context) async {
          await _showLogoutConfirmationDialog(context);
        },
      ),
    ];

    // Restrict "Levels" and "Users" for non-SuperAdmins
    if (loggedInUser.role != 'SuperAdmin') {
      return allItems
          .where((item) => item.title != 'Levels' && item.title != 'Users')
          .toList();
    }

    return allItems;
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero, // Remove default padding
          child: Stack(
            children: [
              // Transparent background that closes the dialog when tapped
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  behavior: HitTestBehavior.translucent,
                ),
              ),
              // Your dialog content centered
              Center(child: _buildLogoutDialogContent(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutDialogContent(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 40,
                color: Colors.red.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              'Are you sure you want to logout from your account?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog first
                      await _performLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Yes, Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Perform logout
      await UserController().logout();

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Handle any errors
      if (context.mounted) {
        Navigator.of(context).pop(); // Remove loading indicator

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
