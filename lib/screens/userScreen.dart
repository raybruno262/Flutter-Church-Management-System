import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';

class UserScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const UserScreen({super.key, required this.loggedInUser});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      drawer: !isDesktop
          ? Container(
              width: 250,
              color: Theme.of(context).scaffoldBackgroundColor,
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
              Expanded(
                flex: 2,
                child: Container(
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
              ),
            Expanded(flex: 10, child: Center(child: Text("Users Page"))),
          ],
        ),
      ),
    );
  }
}
