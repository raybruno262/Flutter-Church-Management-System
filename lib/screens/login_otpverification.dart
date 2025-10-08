import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/model/user_model.dart';
import 'package:flutter_churchcrm_system/screens/dashboardScreen.dart';

import 'package:flutter_churchcrm_system/screens/login.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginOTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String? initialMessage;

  const LoginOTPVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    this.initialMessage,
  });

  @override
  State<LoginOTPVerificationScreen> createState() =>
      _LoginOTPVerificationScreenState();
}

class _LoginOTPVerificationScreenState
    extends State<LoginOTPVerificationScreen> {
  UserModel? loggedInUser;

  bool isSuccess = false;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? message;

  @override
  void initState() {
    super.initState();
    message = widget.initialMessage;
  }

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
                        Expanded(
                          flex: 6,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/crossback.png',
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
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.arrow_back, color: loginTextfieldColor),
            label: Text(
              'Back',
              style: GoogleFonts.poppins(
                color: loginTextfieldColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 1),
        SvgPicture.asset('assets/images/church.svg', height: 80),
        if (message != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSuccess ? Colors.green : Colors.red,
                width: 1.5,
              ),
            ),
            child: Text(
              message!,
              style: GoogleFonts.poppins(
                color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: message != null ? 3 : 10),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final boxWidth = isMobile || isTablet ? 40.0 : 50.0;
            final fontSize = isMobile
                ? 15.0
                : isTablet
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onTap: () async {
                  final clipboard = await Clipboard.getData('text/plain');
                  final text = clipboard?.text ?? '';
                  final digits = text.replaceAll(RegExp(r'\D'), '');

                  // Only apply if all 6 digits are copied
                  if (digits.length == 6) {
                    for (int i = 0; i < 6; i++) {
                      _controllers[i].text = digits[i];
                    }
                    _focusNodes[5].requestFocus();
                  }
                },
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                  }
                },
              ),
            );
          }),
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

            onPressed: () async {
              final otp = _controllers.map((c) => c.text).join();

              if (otp.length != 6) {
                setState(() {
                  message = 'Please enter the full 6-digit OTP code.';
                  isSuccess = false;
                });
                return;
              }

              setState(() {
                message = null;
                isSuccess = true;
              });

              try {
                final user = await UserController().login(
                  email: widget.email,
                  verifyCode: otp,
                  password: widget.password,
                );

                if (user == null) {
                  setState(() {
                    message = 'Login failed. Please try again.';
                    isSuccess = false;
                  });
                  return;
                }

                // Save user to local storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('loggedInUser', user.toJsonString());

                //  Navigate with user
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(loggedInUser: user),
                  ),
                );
              } catch (e) {
                final error = e.toString();

                setState(() {
                  isSuccess = false;

                  if (error.contains('Status 3000')) {
                    message =
                        'Invalid OTP or email. Please check and try again.';
                  } else if (error.contains('Status 4000')) {
                    message = 'Incorrect password. Please try again.';
                  } else if (error.contains('Status 9999')) {
                    message = 'Something went wrong. Please try again later.';
                  }
                });
              }
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
          onPressed: () async {
            final result = await UserController().sendLoginOtp(
              widget.email,
              widget.password,
            );

            switch (result) {
              case 'Status 1000':
                setState(() {
                  message = 'OTP sent successfully.';
                  isSuccess = true;
                });
                break;

              case 'Status 3000':
                setState(() {
                  message = 'No account found for this email.';
                  isSuccess = false;
                });
                break;

              case 'Status 4000':
                setState(() {
                  message = 'Incorrect password. Please try again.';
                  isSuccess = false;
                });
                break;

              case '6000':
                setState(() {
                  message =
                      'Your account or level is inactive. Contact the administrator.';
                  isSuccess = false;
                });
                break;

              case 'Status 2000':
                setState(() {
                  message = 'Failed to send OTP.';
                  isSuccess = false;
                });
                break;

              case 'Status 9999':
                setState(() {
                  message = 'Something went wrong. Please try again later.';
                  isSuccess = false;
                });
                break;
            }
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
