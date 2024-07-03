import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _currentUser;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
        const SnackBar(
          content: Text('Profil güncellendi.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
        MaterialPageRoute(builder: (context) => const MyApp()),
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
        title: const Text('Profil Ayarları'),
        backgroundColor: const Color(0xff156192),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'İsim'),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xff156192),
              ),
              child: const Text('Kaydet'),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () => signOut(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
