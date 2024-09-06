import 'package:art_app/view/home/widget/category_button/category_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:art_app/const/app_color.dart'; // Ensure this import is correct
import 'package:art_app/main_widgets/app_bar/main_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _user;
  bool _isLoading = true;

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
      backgroundColor: MainAppColors.mainAppBarBackButton, // Verify this is a color
      appBar: MainAppbar(

        title: 'Hoşgeldin, ${_user?.name}', isbackButton: false,
      ),
      body: _isLoading
          ? CircularProgressIndicator()
          : _user != null
          ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 28),
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Yeni Eserler Keşfet...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.pink),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Ne tür bir sanat eseri arıyorsun?",
                style: TextStyle(color: Colors.white, fontSize: 29),
              ),
              SizedBox(height: 30),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  scrollDirection: Axis.horizontal,

                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CategoryButton(
                          imageUrl:"https://images.saatchiart.com/saatchi/704660/art/6926703/5996049-AHRVPAKW-7.jpg",
                          labelText: "Doğa"),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CategoryButton(
                          labelText: "Antik",
                        imageUrl: "https://sothebys-com.brightspotcdn.com/16/16/9f6768884e9784a63b4fde461c3c/ancien-sculpture-006l19260-b45nz-a-unique556.jpg",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CategoryButton(
                        labelText: "Antik",
                        imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7e5p59XDQDukz6xCdt98BJpupknvzB2VA9g&s",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CategoryButton(
                        labelText: "String Art",
                        imageUrl: "https://yildirimbayazitortaokulu.meb.k12.tr/meb_iys_dosyalar/01/01/726048/resimler/2018_05/k_04082354_tarihi_olaylar_guzel-sanatlar-jpg_213473522_1436096070.jpg",
                      ),
                    ),
                  ]

                ),
              ),
              SizedBox(height: 30,),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Popüler Eserler",
                  style: TextStyle(color: Colors.white, fontSize: 29),
                ),
              ),
              SizedBox(height: 5,),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Bu alanda en çok oylanmış eserleri bulabilirsiniz..",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 17),
                ),
              ),
              SizedBox(height: 20,),
              Image.network(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqY94IOAxn0u1N-hzOpXIVveBCJytP_rpnPw&s"
              )


            ],
          ),
        ),
      )
          : Text('Kullanıcı Bulunamadı !'),
    );
  }
}
