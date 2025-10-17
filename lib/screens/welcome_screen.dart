import 'dart:async';
import 'package:darbk/screens/Define_screen.dart';
import 'package:flutter/material.dart';
// Ensure this file exists

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Delay 3 seconds then navigate with animation
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 800), // Animation duration
          pageBuilder: (context, animation, secondaryAnimation) => DefineScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition effect (you can change it)
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: 72,
              top: 311,
              child: Text(
                'D ',
                style: TextStyle(
                  fontSize: 64,
                  color: Color(0xff14abc2),
                  fontFamily: 'Montserrat-Bold',
                ),
              ),
            ),
            Positioned(
              left: 197,
              top: 311,
              child: Text(
                'rbk',
                style: TextStyle(
                  fontSize: 64,
                  color: Color(0xff14abc2),
                  fontFamily: 'Montserrat-Bold',
                ),
              ),
            ),
            Positioned(
              left: 195,
              top: 571,
              child: Image.asset(
                'images/image1_21778.png',
                width: 302,
                height: 302,
              ),
            ),
            Positioned(
              left: -204,
              top: -182,
              child: Image.asset(
                'images/image2_21779.png',
                width: 409.593,
                height: 409.593,
              ),
            ),
            Positioned(
              left: 8,
              top: 764,
              child: Image.asset(
                'images/image3_21782.png',
                width: 78,
                height: 73,
              ),
            ),
            Positioned(
              left: 307,
              top: 83,
              child: Image.asset(
                'images/image4_50788.png',
                width: 78,
                height: 73,
              ),
            ),
            Positioned(
              left: 120,
              top: 302,
              child: Image.asset(
                'images/image5_509126.png',
                width: 75,
                height: 74,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 99,
              top: 379,
              child: Text(
                'for best treatment ',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff6cebfa),
                  fontFamily: 'Montserrat-Bold',
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: Center(child: CircularProgressIndicator()), // Loading animation
            ),
          ],
        ),
      ),
    );
  }
}
