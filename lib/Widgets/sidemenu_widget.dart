import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/data/sidemenu_data.dart';
import 'package:flutter_churchcrm_system/model/sidemenu_model.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenuWidget extends StatefulWidget {
  final String selectedTitle;
  final UserModel loggedInUser;

  const SideMenuWidget({
    super.key,
    required this.selectedTitle,
    required this.loggedInUser,
  });

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  late int _selectedIndex;
  late List<SideMenuModel> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = SidemenuData(loggedInUser: widget.loggedInUser).sideMenu;
    _selectedIndex = _menuItems.indexWhere(
      (item) => item.title == widget.selectedTitle,
    );

    // Fallback if title not found
    if (_selectedIndex == -1) _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/images/church.svg', height: 68),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) => _buildMenuEntry(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuEntry(int index) {
    final item = _menuItems[index];
    final isSelected = _selectedIndex == index;
    final isLogout = item.title == 'Logout';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 34,
      width: 133,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isLogout
            ? logoutColor
            : isSelected
            ? sideBarBoxColor
            : Colors.transparent,
      ),
      child: InkWell(
        onTap: () async {
          if (!isLogout) {
            setState(() => _selectedIndex = index);
          }

          if (item.onTap != null) {
            await item.onTap!(context);
          } else if (item.page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item.page!),
            );
          }
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(height: 18, width: 18, child: item.icon),
            ),
            Expanded(
              child: Text(
                item.title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isLogout ? Colors.red : Colors.white,
                  fontSize: 15,
                  fontWeight: isSelected || isLogout
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
