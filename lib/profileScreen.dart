import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _currentUser;
  bool _isLoading = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = _auth.currentUser!;
    DocumentSnapshot userSnapshot =
    await _firestore.collection('users').doc(_currentUser.uid).get();

    if (userSnapshot.exists) {
      setState(() {
        _nameController.text = userSnapshot['name'];
        _emailController.text = userSnapshot['email'];
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('users').doc(_currentUser.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil güncellendi.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil güncellenirken hata oluştu.'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Ayarları'),
        backgroundColor: Color(0xff156192),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'İsim'),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-posta'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xff156192),
              ),
            ),
            SizedBox(height: 20.0),
            TextButton(
              onPressed: () => signOut(context),
              child: Text('Çıkış Yap'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
