import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/topHeaderWidget.dart';

import 'package:flutter_churchcrm_system/model/user_model.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';

import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';

import 'package:flutter_churchcrm_system/constants.dart';

class AddLevelScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const AddLevelScreen({super.key, required this.loggedInUser});

  @override
  State<AddLevelScreen> createState() => _AddLevelScreenState();
}

class _AddLevelScreenState extends State<AddLevelScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? Container(
              width: 250,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SideMenuWidget(
                selectedTitle: 'Levels',
                loggedInUser: widget.loggedInUser,
              ),
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
                  child: SideMenuWidget(
                    selectedTitle: 'Levels',
                    loggedInUser: widget.loggedInUser,
                  ),
                ),
              ),
            Expanded(flex: 10, child: _buildAddLevelScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildAddLevelScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const TopHeaderWidget(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              color: Colors.amberAccent,
              child: const Text('Add Level '),
            ),
          ),
        ),
      ],
    );
  }
}
