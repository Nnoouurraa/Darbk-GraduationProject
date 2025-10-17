import 'package:flutter/material.dart';
import 'package:darbk/screens/Login_P.dart';
import 'package:darbk/screens/Login_D.dart';

class DefineScreen extends StatelessWidget {
  const DefineScreen({super.key});

  void navigateWithAnimation(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd9d9d9),
      body: Stack(
        children: [
          // Background images
          Positioned(
            left: 195,
            width: 302,
            top: 571,
            height: 302,
            child: Image.asset('images/image1_555226.png'),
          ),
          Positioned(
            left: -204,
            width: 409.593,
            top: -182,
            height: 409.593,
            child: Image.asset('images/image2_555229.png'),
          ),
          Positioned(
            left: 8,
            width: 78,
            top: 764,
            height: 73,
            child: Image.asset('images/image3_555232.png'),
          ),
          Positioned(
            left: 307,
            width: 78,
            top: 83,
            height: 73,
            child: Image.asset('images/image4_555249.png'),
          ),
          Positioned(
            left: 124,
            width: 78.513,
            top: 218,
            height: 78.001,
            child: Image.asset('images/image5_555266.png', fit: BoxFit.cover),
          ),

          // D rbk logo
          const Positioned(
            left: 64,
            top: 224,
            child: Text(
              'D ',
              style: TextStyle(
                fontSize: 64,
                color: Color(0xff14abc2),
                fontFamily: 'Montserrat-Bold',
              ),
            ),
          ),
          const Positioned(
            left: 203,
            top: 224,
            child: Text(
              'rbk',
              style: TextStyle(
                fontSize: 64,
                color: Color(0xff14abc2),
                fontFamily: 'Montserrat-Bold',
              ),
            ),
          ),

          // "for best treatment"
          const Positioned(
            left: 90,
            top: 300,
            child: Text(
              'for best treatment',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins-SemiBold',
                color: Color(0xff6cebfa),
              ),
            ),
          ),

          // Buttons under "for best treatment"
          Positioned(
            left: 40,
            right: 40,
            top: 350,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => navigateWithAnimation(context, const LoginP()),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14abc2).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/image6_555291.png', height: 30),
                        const SizedBox(width: 12),
                        const Text(
                          'Patient',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins-SemiBold',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => navigateWithAnimation(context, const Login_D()),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14abc2).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/image7_555292.png', height: 30),
                        const SizedBox(width: 12),
                        const Text(
                          'Physiotherapist',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins-SemiBold',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
