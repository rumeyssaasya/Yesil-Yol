import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  _GardenScreenState createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  List<String> purchasedItems = []; // Satın alınan öğelerin listesi
  String? selectedItem; // Seçilen öğe
  bool isLoading = true; // Yükleniyor durumunu kontrol etmek için
  List<_PlacedItem> placedItems = []; // Ekrana yerleştirilen öğelerin listesi

  @override
  void initState() {
    super.initState();
    _fetchPurchasedItems(); // Satın alınan öğeleri Firestore'dan al
  }

  Future<void> _fetchPurchasedItems() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No user is currently signed in.');
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          purchasedItems = List<String>.from(userDoc.get('purchasedItems') ?? []);
          placedItems = List<Map<String, dynamic>>.from(userDoc.get('placedItems') ?? [])
              .map((item) => _PlacedItem.fromMap(item))
              .toList();
          isLoading = false; // Yükleniyor durumu bitti
        });
      } else {
        print('User document does not exist.');
        setState(() {
          isLoading = false; // Yükleniyor durumu bitti
        });
      }
    } catch (e) {
      print('Error fetching purchased items: $e');
      setState(() {
        isLoading = false; // Yükleniyor durumu bitti
      });
    }
  }

  Future<void> _savePurchasedItemsToFirebase(List<String> items) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No user is currently signed in.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'purchasedItems': items}, SetOptions(merge: true));

      print('Purchased items saved to Firestore.');
    } catch (e) {
      print('Error saving purchased items to Firestore: $e');
    }
  }

  Future<void> _savePlacedItemsToFirebase(List<_PlacedItem> items) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No user is currently signed in.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'placedItems': items.map((item) => item.toMap()).toList()
      }, SetOptions(merge: true));

      print('Placed items saved to Firestore.');
    } catch (e) {
      print('Error saving placed items to Firestore: $e');
    }
  }

  Offset _generateRandomOffset() {
    final random = Random();
    final dx = random.nextDouble() * (MediaQuery.of(context).size.width - 100);
    final dy = random.nextDouble() * (MediaQuery.of(context).size.height - 200);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bahçem',
          style: TextStyle(color: Color(0xffEFFFFF)),
        ),
        backgroundColor: const Color(0xff156192),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Yükleniyor işareti
          : Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bahce.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  alignment: WrapAlignment.center,
                  children: purchasedItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedItem = item;
                        });
                      },
                      child: Chip(
                        label: Text(item),
                        backgroundColor: Colors.blueAccent,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          if (selectedItem != null)
            Positioned.fill(
              child: DragTarget<Map>(
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (data) {
                  setState(() {
                    placedItems.add(_PlacedItem(
                      item: data.data['item'],
                      position: data.data['position'],
                    ));
                    selectedItem = null;
                    _savePlacedItemsToFirebase(placedItems);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        final position = _generateRandomOffset();
                        placedItems.add(_PlacedItem(
                          item: selectedItem!,
                          position: position,
                        ));
                        selectedItem = null;
                        _savePlacedItemsToFirebase(placedItems);
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Draggable(
                          data: {'item': selectedItem, 'position': const Offset(0, 0)},
                          feedback: _buildImage(selectedItem),
                          childWhenDragging: Container(),
                          child: _buildImage(selectedItem),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ...placedItems.map((placedItem) {
            return Positioned(
              left: placedItem.position.dx,
              top: placedItem.position.dy,
              child: GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    placedItems.remove(placedItem);
                    _savePlacedItemsToFirebase(placedItems);
                  });
                },
                child: _buildImage(placedItem.item),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getImageForItem(String? item) {
    if (item == "Kuş") {
      return 'assets/images/bird.png';
    } else if (item == "Köpek") {
      return 'assets/images/dog.png';
    } else if (item == "Kedi") {
      return 'assets/images/cat.png';
    } else if (item == "Kelebek") {
      return 'assets/images/butterfly.png';
    } else if (item == "Papatya") {
      return 'assets/images/daisy.png';
    } else if (item == "Orkide") {
      return 'assets/images/orchid.png';
    } else if (item == "Gül") {
      return 'assets/images/rose.png';
    }
    return '';
  }

  Widget _buildImage(String? item) {
    return Image.asset(
      _getImageForItem(item),
      height: 100,
      width: 100,
      fit: BoxFit.contain,
    );
  }
}

class _PlacedItem {
  final String item;
  final Offset position;

  _PlacedItem({required this.item, required this.position});

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'x': position.dx,
      'y': position.dy,
    };
  }

  factory _PlacedItem.fromMap(Map<String, dynamic> map) {
    return _PlacedItem(
      item: map['item'] as String,
      position: Offset(map['x'] as double, map['y'] as double),
    );
  }
}
