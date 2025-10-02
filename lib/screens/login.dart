import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/screens/forgotpassword.dart';
import 'package:flutter_churchcrm_system/screens/login_otpverification.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? message;

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
                  ? Center(child: _buildLoginForm())
                  : Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: _buildLoginForm(),
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

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Image.asset('assets/images/church.png', height: 90),
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

        SizedBox(height: message != null ? 4 : 20),
        Text(
          'LOGIN',
          style: GoogleFonts.poppins(
            fontSize: 23,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: GoogleFonts.poppins(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              TextField(
                controller: emailController,
                style: GoogleFonts.poppins(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: Icon(Icons.email, color: loginInputColor),
                  filled: true,
                  fillColor: loginTextfieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: GoogleFonts.poppins(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.poppins(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: Icon(Icons.lock, color: loginInputColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
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
            ],
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: SizedBox(
              width: 150, //
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(
                        email: '',
                        newPassword: '',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    color: titleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),
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
              final password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                setState(() => message = 'Status 3000');
                return;
              }

              final result = await UserController().sendLoginOtp(
                email,
                password,
              );

              if (result['message'] == 'Status 1000') {
                setState(() => message = null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginOTPVerificationScreen(
                      email: email,
                      password: password,
                    ),
                  ),
                );
              } else {
                setState(() => message = result['message']);
              }
            },
            child: Text(
              'Login',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
