import 'package:flutter/material.dart';

class SideMenuModel {
  final Widget icon;
  final String title;
  final Widget page;

  const SideMenuModel({
    required this.icon,
    required this.title,
    required this.page,
  });
}
