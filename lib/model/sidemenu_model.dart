import 'package:flutter/material.dart';

class SideMenuModel {
  final Widget icon;
  final String title;
  final Widget? page;
  final Future<void> Function(BuildContext context)? onTap;

  const SideMenuModel({
    required this.icon,
    required this.title,
    this.page,
    this.onTap,
  });
}
