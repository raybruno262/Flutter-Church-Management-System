import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final EdgeInsets? mobileMargin = isMobile
        ? (isPortrait
              ? const EdgeInsets.symmetric(horizontal: 23, vertical: 134)
              : const EdgeInsets.symmetric(horizontal: 80, vertical: 10))
        : null;

    return Scaffold(
      backgroundColor: backgroundcolor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              height: 473,
              width: isTablet
                  ? 750
                  : isMobile
                  ? MediaQuery.of(context).size.width * 0.9
                  : 919,
              margin: isMobile
                  ? mobileMargin
                  : const EdgeInsets.symmetric(horizontal: 23, vertical: 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: containerColor,
              ),
              child: isMobile
                  ? Center(child: _buildOTPForm(context))
                  : Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: _buildOTPForm(context),
                          ),
                        ),
                        if (!isMobile)
                          Expanded(
                            flex: 6,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              child: Image.asset(
                                'assets/images/crossback.jpg',
                                fit: BoxFit.cover,
                                height: 919,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: loginTextfieldColor),
            label: Text(
              'Back',
              style: GoogleFonts.poppins(
                color: loginTextfieldColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 1),
        Image.asset('assets/images/church.png', height: 80),
        const SizedBox(height: 26),
        Text(
          'OTP Verification',
          style: GoogleFonts.poppins(
            fontSize: 23,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Enter the 6-digit code sent to your email',
          style: GoogleFonts.poppins(fontSize: 14, color: titleColor),
        ),
        const SizedBox(height: 25),

        // OTP Fields
        Padding(
          padding: EdgeInsets.only(
            right: Responsive.isMobile(context) || Responsive.isTablet(context)
                ? 10
                : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final boxWidth = Responsive.isMobile(context)
                  ? 40.0
                  : Responsive.isTablet(context)
                  ? 40.0
                  : 50.0;

              final fontSize = Responsive.isMobile(context)
                  ? 15.0
                  : Responsive.isTablet(context)
                  ? 17.0
                  : 20.0;

              return Container(
                width: boxWidth,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: loginTextfieldColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) {
                      FocusScope.of(
                        context,
                      ).requestFocus(_focusNodes[index + 1]);
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(
                        context,
                      ).requestFocus(_focusNodes[index - 1]);
                    }
                  },
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 30),
        SizedBox(
          width: 116,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: Verify OTP logic
            },
            child: Text(
              'Verify',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // TODO: Resend OTP logic
          },
          child: Text(
            'Resend OTP',
            style: GoogleFonts.poppins(
              color: titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
