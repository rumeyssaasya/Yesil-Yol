import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class GardenScreen extends StatefulWidget {
  const GardenScreen({Key? key}) : super(key: key);

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
      // Dinamik olarak kullanıcı kimliğini al
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Kullanıcı oturumu yoksa, işlemi durdur
        print('No user is currently signed in.');
        return;
      }

      // Kullanıcının satın aldığı öğeleri Firestore'dan al
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Gerçek kullanıcı kimliği ile belgeyi alın
          .get();

      if (userDoc.exists) {
        setState(() {
          purchasedItems = List<String>.from(userDoc.get('purchasedItems') ?? []);
          placedItems = List<_PlacedItem>.from((userDoc.get('placedItems') ?? []).map((item) {
            return _PlacedItem(
              item: item['item'],
              position: Offset(item['x'] ?? 0.0, item['y'] ?? 0.0),
            );
          }));
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
          .set({'placedItems': items.map((item) => {
        'item': item.item,
        'x': item.position.dx,
        'y': item.position.dy,
      }).toList()}, SetOptions(merge: true));

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
        title: Text(
          'Bahçem',
          style: TextStyle(color: Color(0xffEFFFFF)),
        ),
        backgroundColor: Color(0xff156192),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Yükleniyor işareti
          : Stack(
        children: [
          // Arka plan resmini ekleyin
          Positioned.fill(
            child: Image.asset(
              'assets/images/bahce.png',
              fit: BoxFit.cover,
            ),
          ),
          // Diğer öğeler ve liste
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(), // Üstteki elemanları yukarı itmek için kullanılır
                  ],
                ),
              ),
              Container(
                color: Colors.grey[200], // Alt kısım için arka plan rengi
                padding: EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0, // Baloncuklar arasındaki yatay boşluk
                  runSpacing: 4.0, // Baloncuklar arasındaki dikey boşluk
                  alignment: WrapAlignment.center, // Baloncukları ortala
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
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          // Seçilen öğenin görüntüsünü göster
          if (selectedItem != null)
            Positioned.fill(
              child: DragTarget<Map>(
                onWillAccept: (data) => true,
                onAccept: (data) {
                  setState(() {
                    placedItems.add(_PlacedItem(
                      item: data['item'],
                      position: data['position'],
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
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Draggable(
                          data: {'item': selectedItem, 'position': Offset(0, 0)},
                          feedback: _buildImage(selectedItem),
                          childWhenDragging: Container(), // Sürüklenirken orijinal görünmesin
                          child: _buildImage(selectedItem),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Yerleştirilen öğeleri göster
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

  // İlgili öğe için resim URL'sini alın
  String _getImageForItem(String? item) {
    if (item == "Kuş") {
      return 'assets/images/bird.png'; // Kuş resmi URL'si
    } else if (item == "Köpek") {
      return 'assets/images/dog.png'; // Köpek resmi URL'si
    } else if (item == "Kedi") {
      return 'assets/images/cat.png'; // Kedi resmi URL'si
    } else if (item == "Kelebek") {
      return 'assets/images/butterfly.png'; // Kelebek resmi URL'si
    } else if (item == "Papatya") {
      return 'assets/images/daisy.png'; // Papatya resmi URL'si
    } else if (item == "Orkide") {
      return 'assets/images/orchid.png'; // Orkide resmi URL'si
    } else if (item == "Gül") {
      return 'assets/images/rose.png'; // Gül resmi URL'si
    }
    return ''; // Varsayılan olarak boş string döndürülebilir veya başka bir hata durumu ele alınabilir
  }

  // Görüntü widget'ı oluşturma
  Widget _buildImage(String? item) {
    return Image.asset(
      _getImageForItem(item),
      height: 100, // Resmin yüksekliği
      width: 100, // Resmin genişliği
      fit: BoxFit.contain,
    );
  }
}

class _PlacedItem {
  final String item;
  final Offset position;

  _PlacedItem({required this.item, required this.position});
}
