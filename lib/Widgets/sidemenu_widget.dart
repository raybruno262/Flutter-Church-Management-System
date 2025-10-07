import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/data/sidemenu_data.dart';

import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenuWidget extends StatefulWidget {
  final int selectedIndex;
  const SideMenuWidget({super.key, required this.selectedIndex});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  @override
  Widget build(BuildContext context) {
    final data = SidemenuData();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/images/church.svg', height: 68),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: data.sideMenu.length,
              itemBuilder: (context, index) => buildMenuEntry(data, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(SidemenuData data, int index) {
    var selectedIndex = widget.selectedIndex;
    final isSelected = selectedIndex == index;
    final title = data.sideMenu[index].title;
    final isLogout = title == 'Logout';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),

      height: 34,
      width: 133,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        color: isLogout
            ? logoutColor
            : isSelected
            ? sideBarBoxColor
            : Colors.transparent,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => data.sideMenu[index].page),
          );
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 10.0),
              child: SizedBox(
                height: 16,
                width: 16,

                child: data.sideMenu[index].icon,
              ),
            ),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isLogout ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: isLogout
                      ? FontWeight.w600
                      : isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
