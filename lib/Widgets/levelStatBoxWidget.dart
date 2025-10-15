import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelStatBox extends StatelessWidget {
  final String label;
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final String iconPath;
  final Color backgroundColor;

  const LevelStatBox({
    super.key,
    required this.label,
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.iconPath,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 52, height: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStat('Total', totalCount, Colors.white),
                const SizedBox(height: 4),
                _buildStat('Active', activeCount, Colors.greenAccent),
                const SizedBox(height: 4),
                _buildStat('Inactive', inactiveCount, Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, int count, Color color) {
    return Row(
      children: [
        Text(
          '$title:',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.9),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
