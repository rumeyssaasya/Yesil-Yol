import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Timer kullanımı için gerekli

import 'mainScreen.dart';

class SignUpScreen extends StatefulWidget {
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = _isAnimating ? Colors.white : Color(0xffB5EFFF);
        _isAnimating = !_isAnimating;
      });
    });
  }

  Widget buildAnimatedContainer(String hintText, Function(String) onChanged, {bool obscureText = false}) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 1),
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
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
      backgroundColor: Color(0xffEFFFFF),
      appBar: AppBar(
        title: Text(
          'Hesap Oluştur',
          style: TextStyle(color: Color(0xffDAFFFF)),
        ),
        backgroundColor: Color(0xff156192),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildAnimatedContainer('Adınız', (value) => name = value),
              SizedBox(height: 10),
              buildAnimatedContainer('E-mail', (value) => email = value),
              SizedBox(height: 10),
              buildAnimatedContainer('Şifre', (value) => password = value, obscureText: true),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffB5EFFF),
                  side: BorderSide(color: Color(0xffB5EFFF)),
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

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                      }
                    } catch (error) {
                      Fluttertoast.showToast(msg: error.toString(), toastLength: Toast.LENGTH_LONG);
                    }
                  } else {
                    Fluttertoast.showToast(msg: 'Tüm alanları doldurun!', toastLength: Toast.LENGTH_LONG);
                  }
                },
                child: Text(
                  'Hesap Oluştur',
                  style: TextStyle(color: Color(0xff156192)),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentColor = _isAnimating ? Colors.white : Color(0xffB5EFFF);
        _isAnimating = !_isAnimating;
      });
    });
  }

  Widget buildAnimatedContainer(String hintText, Function(String) onChanged, {bool obscureText = false}) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      decoration: BoxDecoration(
        color: _currentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8),
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
      backgroundColor: Color(0xffEFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xff156192),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildAnimatedContainer('E-mail', (value) => email = value),
              SizedBox(height: 10),
              buildAnimatedContainer('Şifre', (value) => password = value, obscureText: true),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffB5EFFF),
                  side: BorderSide(color: Color(0xffB5EFFF)),
                ),
                onPressed: () {
                  if (email.isNotEmpty && password.isNotEmpty) {
                    _auth.signInWithEmailAndPassword(email: email, password: password)
                        .then((UserCredential userCredential) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    }).catchError((error) {
                      Fluttertoast.showToast(msg: error.toString(), toastLength: Toast.LENGTH_LONG);
                    });
                  } else {
                    Fluttertoast.showToast(msg: 'Email ve şifre alanları boş olamaz!', toastLength: Toast.LENGTH_LONG);
                  }
                },
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(color: Color(0xff156192)),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                child: Text(
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
