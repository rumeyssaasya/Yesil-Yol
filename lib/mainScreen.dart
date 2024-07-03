import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yesil_yol_projem/profileScreen.dart';
import 'package:yesil_yol_projem/storeScreen.dart';
import 'package:yesil_yol_projem/gardenScreen.dart'; // GardenScreen'ün tanımlandığı dosya
import 'task_page.dart'; // TaskPage sınıfının tanımlandığı dosya

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;
  int greenCoins = 10;
  List<String> flowers = [];
  List<bool> isOpen = [false, false, false, false, false, false, false];
  Map<String, Timestamp> completedTasks = {}; // Görevlerin tamamlanma zamanlarını saklar

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUserData();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getUserData() async {
    try {
      final userDoc = await _firestore.collection('users').doc(loggedInUser.uid).get();
      setState(() {
        greenCoins = userDoc.data()?['greenCoins'] ?? 0;
        flowers = List<String>.from(userDoc.data()?['flowers'] ?? []);
        // Ensure completedTasks is correctly processed as Map<String, Timestamp>
        Map<String, Timestamp> tasks = {};
        if (userDoc.data()?['completedTasks'] != null) {
          userDoc.data()?['completedTasks'].forEach((key, value) {
            tasks[key] = value as Timestamp;
          });
        }
        completedTasks = tasks;
      });
    } catch (e) {
      print(e);
    }
  }

  void navigateToPage(
      BuildContext context,
      String pageName,
      List<String> tasks,
      User loggedInUser,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPage(
          pageName: pageName,
          tasks: tasks,
          onTaskComplete: _updateGreenCoins,
          completedTasks: completedTasks,
          onTaskChecked: (String task, Timestamp completeDate) {
            _updateTaskCompletion(task, completeDate);
          },
          loggedInUser: loggedInUser,
        ),
      ),
    );
  }

  void _updateGreenCoins(int coins) async {
    setState(() {
      greenCoins += coins;
    });
    await _firestore.collection('users').doc(loggedInUser.uid).update({'greenCoins': greenCoins});
  }

  void _updateTaskCompletion(String task, Timestamp completeDate) async {
    setState(() {
      completedTasks[task] = Timestamp.now();
    });
    await _firestore.collection('users').doc(loggedInUser.uid).update({'completedTasks': completedTasks});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xffB5EFFF),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Colors.teal.shade600,
                ),
                Text(
                  '$greenCoins',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal.shade600,
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Görevler',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xff156192),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: 7, // Toplam 7 görev için
                itemBuilder: (context, index) {
                  String buttonText = "";
                  List<String> tasks = [];

                  switch (index) {
                    case 0:
                      buttonText = "Atık Yönetimi ve geri dönüşüm";
                      tasks = ["Plastik geri dönüşüm", "Kağıt geri dönüşüm", "Cam geri dönüşüm", "Organik atık yönetimi", "Elektronik atık yönetimi"];
                      break;
                    case 1:
                      buttonText = "Enerji Tasarrufu";
                      tasks = ["Işıkları kapat", "Enerji tasarruflu ampul kullan", "Fişleri çek", "Çamaşırları soğuk suda yıka", "Kısa duş al"];
                      break;
                    case 2:
                      buttonText = "Su Tasarrufu";
                      tasks = ["Muslukları kapat", "Düşük akışlı musluklar kullan", "Bulaşık makinesini doldur", "Kısa duş al", "Bahçe sulamayı azalt"];
                      break;
                    case 3:
                      buttonText = "Alışveriş Tüketim Alışkanlığı";
                      tasks = ["İhtiyaç dışı alışveriş yapma", "Yerli ürün al", "Organik ürün tercih et", "İkinci el al", "Plastik kullanımını azalt"];
                      break;
                    case 4:
                      buttonText = "Doğa Ve Bitki Koruma";
                      tasks = ["Ağaç dik", "Doğal parklara git", "Çöp toplama etkinliğine katıl", "Kompost yap", "Bitkileri koru"];
                      break;
                    case 5:
                      buttonText = "Ulaşım Ve Karbon Ayak İzi";
                      tasks = ["Toplu taşıma kullan", "Yürüyüş yap", "Bisiklete bin", "Araç paylaşımı yap", "Araba kullanma"];
                      break;
                    case 6:
                      buttonText = "Sağlıklı Yaşam Ve Kişisel Bakım";
                      tasks = ["Sağlıklı beslen", "Düzenli egzersiz yap", "Stresten kaçın", "Doğal ürünler kullan", "Uyku düzenine dikkat"];
                      break;
                  }

                  // Rastgele konum belirlemek için random değerler kullan
                  double top = Random().nextDouble() * 150; // 0 ile 200 arasında rastgele yükseklik
                  double left = Random().nextDouble() * 150; // 0 ile 200 arasında rastgele yatay konum

                  return TextButton(
                    onPressed: () {
                      navigateToPage(context, buttonText, tasks, loggedInUser);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      width: 150,
                      height: 150,
                      transform: Matrix4.translationValues(top, 0.0, 0.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.shade600,
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooterButton(context),
    );
  }

  Widget _buildFooterButton(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomButton(context, Icons.refresh, "Yenile", () {
            // Sayfayı yenilemek için mevcut kullanıcı verilerini yeniden al
            getUserData();
          }),

          _buildBottomButton(context, Icons.store, "Mağaza", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StoreScreen()),
            );
          }),

          _buildBottomButton(context, Icons.yard_rounded, "Bahçem", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GardenScreen()),
            );
          }),

          _buildBottomButton(context, Icons.account_box, "Profilim", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileSettingsScreen()),
            );
          }),

        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.teal.shade600,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.teal.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
