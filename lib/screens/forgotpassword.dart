import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/screens/forgot_otpverification.dart';
import 'package:flutter_churchcrm_system/screens/login.dart';

import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;
  final String newPassword;
  final String? initialMessage;

  const ForgotPasswordScreen({
    super.key,
    required this.email,
    required this.newPassword,
    this.initialMessage,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? message;
  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    passwordController.text = widget.newPassword;
    message = widget.initialMessage;
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
                  ? Center(child: _buildForgotForm())
                  : Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: _buildForgotForm(),
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

  Widget _buildForgotForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset('assets/images/church.png', height: 90),
        const SizedBox(height: 10),
        if (message != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey, width: 1.2),
            ),
            child: Text(
              message!,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 10),
        Text(
          'Forgot Password',
          style: GoogleFonts.poppins(
            fontSize: 23,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          child: TextField(
            controller: emailController,
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Email',
              floatingLabelStyle: GoogleFonts.poppins(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
              labelStyle: GoogleFonts.poppins(color: Colors.black),
              prefixIcon: Icon(Icons.email, color: loginInputColor),
              filled: true,
              fillColor: loginTextfieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
          child: TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'New Password',
              floatingLabelStyle: GoogleFonts.poppins(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
              labelStyle: GoogleFonts.poppins(color: Colors.black),
              prefixIcon: Icon(Icons.lock, color: loginInputColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: loginInputColor,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              filled: true,
              fillColor: loginTextfieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
            onPressed: () async {
              final email = emailController.text.trim();
              final newPassword = passwordController.text.trim();

              if (email.isEmpty || newPassword.isEmpty) {
                setState(
                  () => message = 'Please fill in both email and new password.',
                );
                return;
              }

              final result = await UserController().sendPasswordResetOtp(email);

              if (result['message'] == 'Status 1000') {
                setState(() => message = null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotOTPVerificationScreen(
                      email: email,
                      newPassword: newPassword,
                    ),
                  ),
                );
              } else {
                setState(() => message = result['message']);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'Back to Login',
              style: GoogleFonts.poppins(
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
