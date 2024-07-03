import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Timer kullanımı için gerekli

import 'mainScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String name = '';
  String email = '';
  String password = '';

  // Animasyon için gerekli durum değişkenleri
  Color _currentColor = Colors.white;
  bool _isAnimating = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer'ı dispose ederek durdur
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = _isAnimating ? Colors.white : const Color(0xffB5EFFF);
        _isAnimating = !_isAnimating;
      });
    });
  }

  Widget buildAnimatedContainer(String hintText, Function(String) onChanged, {bool obscureText = false}) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            decoration: InputDecoration(hintText: hintText, border: InputBorder.none),
            onChanged: (value) => setState(() => onChanged(value.trim())),
            obscureText: obscureText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFFFFF),
      appBar: AppBar(
        title: const Text(
          'Hesap Oluştur',
          style: TextStyle(color: Color(0xffDAFFFF)),
        ),
        backgroundColor: const Color(0xff156192),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                child: Image.asset('assets/logo.png'), // Logo'nun yolu, dosyanızın doğru yolu olduğundan emin olun
              ),
              const SizedBox(height: 20),
              buildAnimatedContainer('Adınız', (value) => name = value),
              const SizedBox(height: 10),
              buildAnimatedContainer('E-mail', (value) => email = value),
              const SizedBox(height: 10),
              buildAnimatedContainer('Şifre', (value) => password = value, obscureText: true),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffB5EFFF),
                  side: const BorderSide(color: Color(0xffB5EFFF)),
                ),
                onPressed: () async {
                  if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                    try {
                      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      User? user = userCredential.user;

                      if (user != null) {
                        await _firestore.collection('users').doc(user.uid).set({
                          'name': name,
                          'email': user.email,
                          'greenCoins': 10, // Başlangıç yeşil para sayısı
                          'purchasedItems': [],   // Başlangıçta boş eşya listesi
                        });

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                      }
                    } catch (error) {
                      Fluttertoast.showToast(msg: error.toString(), toastLength: Toast.LENGTH_LONG);
                    }
                  } else {
                    Fluttertoast.showToast(msg: 'Tüm alanları doldurun!', toastLength: Toast.LENGTH_LONG);
                  }
                },
                child: const Text(
                  'Hesap Oluştur',
                  style: TextStyle(color: Color(0xff156192)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(color: Color(0xff156192)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';

  // Animasyon için gerekli durum değişkenleri
  Color _currentColor = Colors.white;
  bool _isAnimating = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer'ı dispose ederek durdur
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = _isAnimating ? Colors.white : const Color(0xffB5EFFF);
        _isAnimating = !_isAnimating;
      });
    });
  }

  Widget buildAnimatedContainer(String hintText, Function(String) onChanged, {bool obscureText = false}) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        color: _currentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        decoration: InputDecoration(hintText: hintText, border: InputBorder.none),
        onChanged: (value) => setState(() => onChanged(value.trim())),
        obscureText: obscureText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xff156192),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 500,
                child: Image.asset('assets/images/happy-earth-day.jpg'), // Logo'nun yolu, dosyanızın doğru yolu olduğundan emin olun
              ),
              const SizedBox(height: 20),
              buildAnimatedContainer('E-mail', (value) => email = value),
              const SizedBox(height: 10),
              buildAnimatedContainer('Şifre', (value) => password = value, obscureText: true),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffB5EFFF),
                  side: const BorderSide(color: Color(0xffB5EFFF)),
                ),
                onPressed: () {
                  if (email.isNotEmpty && password.isNotEmpty) {
                    _auth.signInWithEmailAndPassword(email: email, password: password)
                        .then((UserCredential userCredential) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    }).catchError((error) {
                      Fluttertoast.showToast(msg: error.toString(), toastLength: Toast.LENGTH_LONG);
                    });
                  } else {
                    Fluttertoast.showToast(msg: 'Email ve şifre alanları boş olamaz!', toastLength: Toast.LENGTH_LONG);
                  }
                },
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(color: Color(0xff156192)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
                child: const Text(
                  'Hesap Oluştur',
                  style: TextStyle(color: Color(0xff156192)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
