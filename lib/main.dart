import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffDAFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xff156192),
          title: const Center(
            child: Text(
              'Yeşil Yol',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0xffB5EFFF),
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 450, // Butonun genişliği
                height: 450,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  //borderRadius: BorderRadius.circular(100),
                  shape: BoxShape.circle,
                ),
                child:Center(
                  child: Text(
                    "Yeşil Yol'a Hoş Geldiniz!",
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade600,

                    ),textAlign: TextAlign.center,
                  ),
                ),
              ),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor:const Color(0xffDAfFFF),
                  side: const BorderSide(color: Color(0xffDAFFFF))
                ),
                child: const Text('Oturum açmak için tıklayınız.',style:
                TextStyle(color: Color(0xff156192),fontSize: 20),),
                onPressed: () {
                  Route loginekrani = MaterialPageRoute(builder: (context) =>const LoginScreen());
                  Navigator.push(context, loginekrani);
                },
              ),
            ],
          ),
        ),
      );

  }

}
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data() ?? {}; // Varsayılan değer boş bir map
    } catch (e) {
      print('Firestore Error: $e');
      return {}; // Hata durumunda boş bir map döner
    }
  }

  Future<void> updateGreenCoins(String userId, int coins) async {
    try {
      await _firestore.collection('users').doc(userId).update({'greenCoins': coins});
    } catch (e) {
      print('Firestore Error: $e');
    }
  }

  Future<void> updateCompletedTasks(String userId, Map<String, Timestamp> completedTasks) async {
    try {
      await _firestore.collection('users').doc(userId).update({'completedTasks': completedTasks});
    } catch (e) {
      print('Firestore Error: $e');
    }
  }
}
