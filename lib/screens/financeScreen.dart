import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/Widgets/sidemenu_widget.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';

class FinanceScreen extends StatefulWidget {
  final UserModel loggedInUser;
  const FinanceScreen({super.key, required this.loggedInUser});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
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
                selectedTitle: 'Finance',

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
                child: SizedBox(
                  child: SideMenuWidget(
                    selectedTitle: 'Finance',
                    loggedInUser: widget.loggedInUser,
                  ),
                ),
              ),
            Expanded(
              flex: 10,
              child: Container(child: Center(child: Text("Finance Page"))),
            ),
          ],
        ),
      ),
    );
  }
}
