import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/model/sidemenu_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/baptismScreen.dart';
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
        page: FinanceScreen(loggedInUser: loggedInUser),
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
          await UserController().logout();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    ];

    //  Restrict "Levels" and "Users" for non-SuperAdmins
    if (loggedInUser.role != 'SuperAdmin') {
      return allItems
          .where((item) => item.title != 'Levels' && item.title != 'Users')
          .toList();
    }

    return allItems;
  }
}
