import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class TopHeaderWidget extends StatefulWidget {
  const TopHeaderWidget({super.key});

  @override
  State<TopHeaderWidget> createState() => _TopHeaderWidgetState();
}

class _TopHeaderWidgetState extends State<TopHeaderWidget> {
  final List<Map<String, String>> languages = [
    {'label': 'EN', 'code': 'en', 'flag': 'assets/icons/US.svg'},
    {'label': 'FR', 'code': 'fr', 'flag': 'assets/icons/fr.svg'},
    {'label': 'RW', 'code': 'rw', 'flag': 'assets/icons/rw.svg'},
  ];

  String selectedLanguageCode = 'en';

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MM/dd/yyyy').format(DateTime.now());

    return Container(
      color: backgroundcolor,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Welcome SuperAdmin",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/calendar.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 3),
              Text(
                today,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(width: 24),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguageCode,
                  dropdownColor: backgroundcolor,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                  items: languages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang['code'],
                      child: Row(
                        children: [
                          ClipOval(
                            child: SvgPicture.asset(
                              lang['flag']!,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(lang['label']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguageCode = value!;
                      // TODO: Apply localization logic here
                    });
                  },
                ),
              ),
              const SizedBox(width: 24),
              const CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage('assets/images/crossback.png'),
              ),
              const SizedBox(width: 3),
              Text(
                'Bruno Ray',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
