import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../model/user_model.dart';

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
  UserModel? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('loggedInUser');
    if (jsonString != null) {
      final user = UserModel.fromJsonString(jsonString);
      if (mounted) {
        setState(() {
          _loggedInUser = user;
        });
      }
    }
  }

  String formatRole(String? role) {
    if (role == null || role.isEmpty) return 'User';

    // Insert space before each capital letter (except the first)
    return role.replaceAllMapped(
      RegExp(r'(?<!^)([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
  }

  // User Profile Dialog Method
  void _showUserProfileDialog() {
    if (_loggedInUser == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: SingleChildScrollView(
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              color: backgroundcolor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with profile image
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.purple.shade700],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Large Profile Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child:
                              _loggedInUser!.profilePic != null &&
                                  _loggedInUser!.profilePic.isNotEmpty
                              ? Image.memory(
                                  _loggedInUser!.profilePic,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildDefaultAvatar(100),
                                )
                              : _buildDefaultAvatar(100),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name with beautiful typography
                      Text(
                        _loggedInUser!.names,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(_loggedInUser!.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formatRole(_loggedInUser!.role),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Personal Information Section
                      _buildSectionHeader('Personal Information'),
                      const SizedBox(height: 16),

                      // Two-column layout for better space utilization
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildEnhancedDetailCard(
                                  'Username',
                                  _loggedInUser!.username,
                                  Icons.person_outline,
                                  Colors.blue,
                                ),
                                const SizedBox(height: 12),
                                _buildEnhancedDetailCard(
                                  'Email',
                                  _loggedInUser!.email,
                                  Icons.email_outlined,
                                  Colors.green,
                                ),

                                const SizedBox(height: 12),
                                _buildEnhancedDetailCard(
                                  'Level Name',
                                  _loggedInUser!.level.name ?? 'N/A',
                                  Icons.leaderboard_outlined,
                                  Colors.indigo,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                _buildEnhancedDetailCard(
                                  'National ID',
                                  _loggedInUser!.nationalId?.toString() ??
                                      'N/A',
                                  Icons.badge_outlined,
                                  Colors.orange,
                                ),

                                const SizedBox(height: 12),
                                _buildEnhancedDetailCard(
                                  'Phone',
                                  _loggedInUser!.phone,
                                  Icons.phone_outlined,
                                  Colors.purple,
                                ),
                                const SizedBox(height: 12),
                                _buildEnhancedDetailCard(
                                  'Level Address',
                                  _loggedInUser!.level.address ?? 'N/A',
                                  Icons.map,
                                  Colors.indigo,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Account Information Section
                      _buildSectionHeader('Account Information'),
                      const SizedBox(height: 16),
                      _buildEnhancedDetailCard(
                        'Account Status',
                        _loggedInUser!.isActive == true ? 'Active' : 'Inactive',
                        _loggedInUser!.isActive == true
                            ? Icons.check_circle_outline
                            : Icons.remove_circle_outline,
                        _loggedInUser!.isActive == true
                            ? Colors.green
                            : Colors.red,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),

                // Actions section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for default avatar
  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey.shade600),
    );
  }

  // Helper method for section headers
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 2,
          width: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade800,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.grey.shade300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced detail card widget
  Widget _buildEnhancedDetailCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get role color
  Color _getRoleColor(String role) {
    switch (role) {
      case 'SuperAdmin':
        return Colors.red.shade600;
      case 'RegionAdmin':
        return Colors.orange.shade600;
      case 'ParishAdmin':
        return Colors.amber.shade600;
      case 'ChapelAdmin':
        return Colors.blue.shade600;
      case 'CellAdmin':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

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
            "Welcome ${formatRole(_loggedInUser?.role)}",
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
              // Make the avatar and username clickable
              GestureDetector(
                onTap: _showUserProfileDialog,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          (_loggedInUser?.profilePic != null &&
                              _loggedInUser!.profilePic.isNotEmpty)
                          ? MemoryImage(_loggedInUser!.profilePic)
                          : null,
                      backgroundColor: Colors.white,
                      child:
                          (_loggedInUser?.profilePic == null ||
                              _loggedInUser!.profilePic.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _loggedInUser?.username ?? 'Guest',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
