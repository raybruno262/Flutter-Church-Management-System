import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      body: SafeArea(
        child: Center(
          child: Container(
            height: 473,
            width: 919,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: containerColor,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  //login data
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/church.png', height: 90),
                        SizedBox(height: 40),
                        Text(
                          'LOGIN ',
                          style: GoogleFonts.poppins(
                            fontSize: 23,
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            style: GoogleFonts.poppins(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              floatingLabelStyle: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,

                                fontSize: 19,
                              ),

                              labelStyle: GoogleFonts.poppins(
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: loginInputColor,
                              ),
                              filled: true,

                              fillColor: loginTextfieldColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            style: GoogleFonts.poppins(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              floatingLabelStyle: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,

                                fontSize: 19,
                              ),

                              labelStyle: GoogleFonts.poppins(
                                color: Colors.black,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: loginInputColor,
                              ),
                              filled: true,

                              fillColor: loginTextfieldColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  // Cross image
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
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
    );
  }
}
