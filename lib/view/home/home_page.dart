import 'package:art_app/view/home/widget/category_button/category_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:art_app/const/app_color.dart';
import 'package:art_app/main_widgets/app_bar/main_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user/user_model.dart';
import '../add_art_page/add_art_page.dart';
import '../add_art_page/model/art_model.dart';
import '../category/artwork_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _user;
  bool _isLoading = true;
  List<Map<String, String>> categories = [
    {
      "labelText": "Portre",
      "imageUrl": "https://t3.ftcdn.net/jpg/02/61/01/52/360_F_261015226_1GUKkNqHVWpRk6yWFmKKdSQHvzIKKbvq.jpg",
    },
    {
      "labelText": "Doğa",
      "imageUrl": "https://images.saatchiart.com/saatchi/704660/art/6926703/5996049-AHRVPAKW-7.jpg",
    },
    {
      "labelText": "Antik",
      "imageUrl": "https://sothebys-com.brightspotcdn.com/16/16/9f6768884e9784a63b4fde461c3c/ancien-sculpture-006l19260-b45nz-a-unique556.jpg",
    },
    {
      "labelText": "Soyut",
      "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7e5p59XDQDukz6xCdt98BJpupknvzB2VA9g&s",
    },
    {
      "labelText": "String Art",
      "imageUrl": "https://yildirimbayazitortaokulu.meb.k12.tr/meb_iys_dosyalar/01/01/726048/resimler/2018_05/k_04082354_tarihi_olaylar_guzel-sanatlar-jpg_213473522_1436096070.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          _user = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        print('User not found!');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainAppColors.mainAppBarBackButton,
      appBar: MainAppbar(
        title: 'Hoşgeldin, ${_user?.name ?? "Sanatçı"}',
        isbackButton: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user != null
          ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 28),
              // Search field
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Yeni Eserler Keşfet...',
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Colors.black.withOpacity(0.2),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(width: 2, color: Colors.pink.shade300),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Add Artwork Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddArtworkPage())
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.pink.shade300],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Kendi Eserini Ekle",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Category Title
              Text(
                "Ne tür bir sanat eseri arıyorsun?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Category Buttons
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CategoryButton(
                        imageUrl: categories[index]["imageUrl"]!,
                        labelText: categories[index]["labelText"]!,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 30),

              // Popular Artworks Section
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Popüler Eserler",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Bu alanda en çok oylanmış eserleri bulabilirsiniz..",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 16
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Popular Artworks Stream
              _buildPopularArtworksSection(),

              SizedBox(height: 30),
            ],
          ),
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Kullanıcı Bulunamadı!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _fetchUserData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
              ),
              child: Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularArtworksSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('artworks')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Henüz eser bulunmuyor',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Convert to list of ArtworkModel, passing both document data and ID
        final List<ArtworkModel> artworks = snapshot.data!.docs.map((doc) {
          return ArtworkModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id, // Pass the document ID as the second argument
          );
        }).toList();

        return Container(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              final artwork = artworks[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildPopularArtworkCard(artwork),
              );
            },
          ),
        );
      },
    );
  }
  Widget _buildPopularArtworkCard(ArtworkModel artwork) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtworkDetailPage(
              artwork: artwork,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                artwork.imageUrl,
                height: 160,
                width: 160,
                fit: BoxFit.cover,
              ),
            ),

            // Artwork Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    artwork.category,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}