import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<Map<String, dynamic>> items = [
    {"name": "Kedi", "icon": Icons.pets, "price": 10, "checked": false},
    {"name": "Köpek", "icon": Icons.pets, "price": 15, "checked": false},
    {"name": "Kuş", "icon": Icons.emoji_nature, "price": 5, "checked": false},
    {"name": "Kelebek", "icon": Icons.bug_report, "price": 20, "checked": false},
    {"name": "Orkide", "icon": Icons.local_florist, "price": 17, "checked": false},
    {"name": "Gül", "icon": Icons.local_florist, "price": 14, "checked": false},
    {"name": "Papatya", "icon": Icons.local_florist, "price": 21, "checked": false},
  ];

  int greenCoins = 0; // Kullanıcının başlangıç bakiyesi
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
  }

  Future<void> _fetchUserBalance() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          print("User document data: ${userDoc.data()}");
          dynamic greenCoinsData = userDoc['greenCoins'];
          print("GreenCoins data type: ${greenCoinsData.runtimeType}");
          setState(() {
            greenCoins = (greenCoinsData ?? 0).toInt();
          });
          print("GreenCoins: $greenCoins");
        } else {
          print("User document does not exist.");
        }
      } catch (e) {
        print("Error fetching user balance: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza'),
        backgroundColor: const Color(0xff156192),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(items[index]["icon"]),
                        Text(
                          items[index]["name"],
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "${items[index]["price"]}\$",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Checkbox(
                          value: items[index]["checked"],
                          onChanged: (bool? value) {
                            setState(() {
                              items[index]["checked"] = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _purchaseItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff156192),
            ),
            child: const Text('Satın Al',style: TextStyle(color: Color(0xffEFFFFF)),),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Bakiye: $greenCoins₺",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseItems() async {
    int totalCost = 0;
    List<String> purchasedItemNames = [];

    for (var item in items) {
      if (item["checked"]) {
        totalCost += item["price"] as int;
        purchasedItemNames.add(item["name"]);
      }
    }

    if (totalCost > greenCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeterli bakiyeniz yok.'),
        ),
      );
    } else {
      setState(() {
        greenCoins -= totalCost;
        for (var item in items) {
          if (item["checked"]) {
            item["checked"] = false; // Satın alınan öğeleri temizle
          }
        }
      });
      _updateUserBalanceAndItems(greenCoins, purchasedItemNames);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Satın alma başarılı.'),
        ),
      );
    }
  }

  Future<void> _updateUserBalanceAndItems(int newBalance, List<String> purchasedItems) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userDocRef);

        if (!userDoc.exists) {
          throw Exception("User does not exist!");
        }

        List<String> existingPurchasedItems = List.from(userDoc['purchasedItems'] ?? []);

        // Satın alınan öğeleri mevcut öğelere ekleyin
        existingPurchasedItems.addAll(purchasedItems);

        // Belgeyi güncelleyin
        transaction.update(userDocRef, {
          'greenCoins': newBalance,
          'purchasedItems': existingPurchasedItems,
        });
      });
    }
  }
}
