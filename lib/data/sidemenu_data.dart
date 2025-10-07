import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/model/sidemenu_model.dart';
import 'package:flutter_churchcrm_system/screens/levelScreen.dart';
import 'package:flutter_churchcrm_system/screens/login.dart';
import 'package:flutter_churchcrm_system/screens/userScreen.dart';
import 'package:flutter_svg/svg.dart';

class SidemenuData {
  final sideMenu = <SideMenuModel>[
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/dashbo.svg', fit: BoxFit.cover),
      title: 'Dashboard',
      page: LevelScreen(),
    ),

    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/level.svg', fit: BoxFit.cover),
      title: 'Levels',
      page: LevelScreen(),
    ),

    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/user.svg', fit: BoxFit.cover),
      title: 'Users',
      page: UserScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/member.svg', fit: BoxFit.cover),
      title: 'Members',
      page: LevelScreen(),
    ),

    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/birthday.svg', fit: BoxFit.cover),
      title: 'Birthdays',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/visitor.svg', fit: BoxFit.cover),
      title: 'Visitors',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/attendance.svg', fit: BoxFit.cover),
      title: 'Attendance',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/baptism.svg', fit: BoxFit.cover),
      title: 'Baptism',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/finance.svg', fit: BoxFit.cover),
      title: 'Finance',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/report.svg', fit: BoxFit.cover),
      title: 'Reports',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/message.svg', fit: BoxFit.cover),
      title: 'Messages',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/backup.svg', fit: BoxFit.cover),
      title: 'Data Backup',
      page: LevelScreen(),
    ),
    SideMenuModel(
      icon: SvgPicture.asset('assets/icons/logout.svg', fit: BoxFit.cover),
      title: 'Logout',
      page: LoginScreen(),
    ),
  ];
}
