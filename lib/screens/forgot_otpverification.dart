import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/utils/responsive.dart';
import 'package:flutter_churchcrm_system/controller/user_controller.dart';
import 'package:flutter_churchcrm_system/screens/forgotpassword.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotOTPVerificationScreen extends StatefulWidget {
  final String email;
  final String newPassword;
  final String? initialMessage;

  const ForgotOTPVerificationScreen({
    super.key,
    required this.email,
    required this.newPassword,
    this.initialMessage,
  });

  @override
  State<ForgotOTPVerificationScreen> createState() =>
      _ForgotOTPVerificationScreenState();
}

class _ForgotOTPVerificationScreenState
    extends State<ForgotOTPVerificationScreen> {
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
          ),
        ),
        const SizedBox(height: 1),
        Image.asset('assets/images/church.png', height: 80),
        if (message != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
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
                setState(() => message = 'Please enter all 6 digits.');
                return;
              }

              final result = await UserController().resetPassword(
                email: widget.email,
                verificationCode: otp,
                newPassword: widget.newPassword,
              );

              if (result['message'] == 'Status 1000') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(
                      email: '',
                      newPassword: '',
                      initialMessage: 'Status 1000',
                    ),
                  ),
                  (route) => false,
                );
              } else {
                setState(() => message = result['message']);
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
            final result = await UserController().sendPasswordResetOtp(
              widget.email,
            );

            setState(() => message = result['message']);
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
