import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';

import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';
import 'package:flutter_churchcrm_system/constants.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';

import 'package:google_fonts/google_fonts.dart';

class AddLevelScreen extends StatefulWidget {
  const AddLevelScreen({super.key});

  @override
  State<AddLevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<AddLevelScreen> {
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? Container(
              width: 250,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const SideMenuWidget(selectedIndex: 1),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: borderColor, width: 2),
                    ),
                  ),
                  child: const SideMenuWidget(selectedIndex: 1),
                ),
              ),
            Expanded(flex: 10, child: _buildAddLevelScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildAddLevelScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const TopHeaderWidget(),

            Center(
              child: Text(
                "Add Levels",
                style: GoogleFonts.inter(
                  color: titlepageColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
