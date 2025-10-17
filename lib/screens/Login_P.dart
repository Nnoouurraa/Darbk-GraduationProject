import 'package:darbk/screens/p.homePage.dart';
import 'package:flutter/material.dart';
import 'package:darbk/screens/SignUp_P.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginP extends StatefulWidget {
  const LoginP({super.key});

  @override
  State<LoginP> createState() => _LoginPState();
}

class _LoginPState extends State<LoginP> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data()?['role'] != 'patient') {
        await FirebaseAuth.instance.signOut(); // Logout for safety
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access denied. Not a patient account.')),
        );
        return;
      }

      navigateWithAnimation(context, const HomeP());

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  InputDecoration _textFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xffb9b9b9),
        fontSize: 14,
        fontFamily: 'Poppins-Regular',
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xffc4c4c4), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xff14abc2), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: -201.094,
              width: 426.189,
              top: 669.906,
              height: 426.189,
              child: Image.asset('images/image1_645.png'),
            ),
            Positioned(
              left: 121,
              width: 134,
              bottom: 16,
              height: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff262626),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              left: -13,
              width: 78,
              top: 651,
              height: 73,
              child: Image.asset('images/image2_668.png'),
            ),
            Positioned(
              left: 351,
              width: 78,
              top: 0,
              height: 73,
              child: Image.asset('images/image3_685.png'),
            ),
            Positioned(
              left: 20,
              width: 334,
              top: 237,
              height: 352,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    width: 334,
                    top: 0,
                    height: 352,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3f000000),
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 60,
                    width: 200,
                    top: 34,
                    child: Text(
                      'Welcome to best treatment !',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 22,
                        color: Color(0xffc4c4c4),
                        fontFamily: 'Poppins-SemiBold',
                      ),
                    ),
                  ),
                  Positioned(
                    left: 13.678,
                    width: 297.645,
                    top: 111,
                    height: 45,
                    child: TextField(
                      controller: emailController,
                      decoration: _textFieldDecoration('Email Address'),
                    ),
                  ),
                  Positioned(
                    left: 13.678,
                    width: 297.645,
                    top: 175,
                    height: 45,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _textFieldDecoration('Password'),
                    ),
                  ),
                  Positioned(
                    left: 18.402,
                    width: 275.967,
                    top: 312,
                    child: GestureDetector(
                      onTap: () => navigateWithAnimation(context, const SignupP()),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Don’t have an account yet? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xffc4c4c4),
                            fontFamily: 'Poppins-SemiBold',
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign up now',
                              style: TextStyle(
                                color: Color(0xFF6cebfa),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 34,
              width: 297,
              top: 474,
              height: 43,
              child: GestureDetector(
                onTap: _login,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff14abc2),
                    border: Border.all(color: Color(0xff14abc2), width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        color: Color(0xffffffff),
                        fontFamily: 'Poppins-Regular',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 128,
              width: 85.558,
              top: 119,
              height: 85,
              child: Image.asset('images/image4_510137.png', fit: BoxFit.cover),
            ),
            const Positioned(
              left: 207,
              top: 126,
              child: Text(
                'rbk',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 64,
                  color: Color(0xff14abc2),
                  fontFamily: 'Montserrat-Bold',
                ),
              ),
            ),
            const Positioned(
              left: 69,
              top: 126,
              child: Text(
                'D ',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 64,
                  color: Color(0xff14abc2),
                  fontFamily: 'Montserrat-Bold',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
