// add_artwork_page.dart - Bottom Sheet ile Resim Seçme Özelliği Eklenmiş Hali

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:art_app/const/app_color.dart';
import 'package:art_app/main_widgets/app_bar/main_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Resim sıkıştırma için eklenmeli

class AddArtworkPage extends StatefulWidget {
  const AddArtworkPage({Key? key}) : super(key: key);

  @override
  State<AddArtworkPage> createState() => _AddArtworkPageState();
}

class _AddArtworkPageState extends State<AddArtworkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Doğa';
  File? _imageFile;
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  final List<String> _categories = ['Doğa', 'Antik', 'Modern', 'String Art', 'Portre', 'Soyut'];

  @override
  void initState() {
    super.initState();
    // Firebase bağlantısını kontrol et
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      // Firebase Storage bağlantısını kontrol et
      print("Firebase Storage bağlantısı kontrol ediliyor...");

      // Firebase yapılandırmasını kontrol et
      final app = Firebase.app();
      print("Firebase App: ${app.name}");
      print("Firebase Project ID: ${app.options.projectId}");
      print("Firebase Storage Bucket: ${app.options.storageBucket}");

      // Kullanıcı oturum durumunu kontrol et
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("UYARI: Kullanıcı oturum açmamış!");
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lütfen önce oturum açın'),
              backgroundColor: Colors.red,
            ),
          );
        });
      } else {
        print("Oturum açmış kullanıcı: ${user.email}");
      }
    } catch (e) {
      print("Firebase kontrolü hatası: $e");
    }
  }

  // Bottom Sheet'i göster
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImagePickerBottomSheet(),
    );
  }

  // Bottom Sheet widget'ı
  Widget _buildImagePickerBottomSheet() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          // Üst çizgi indikatörü
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Fotoğraf Ekle",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Kamera seçeneği
              _buildPickerOption(
                icon: Icons.camera_alt_rounded,
                title: "Kamera",
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _pickImageFromSource(ImageSource.camera),
              ),
              // Galeri seçeneği
              _buildPickerOption(
                icon: Icons.photo_library_rounded,
                title: "Galeri",
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.pink.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _pickImageFromSource(ImageSource.gallery),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Picker seçenek widget'ı
  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Kaynak seçimine göre resim al
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      Navigator.pop(context); // Bottom Sheet'i kapat

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File selectedImage = File(pickedFile.path);
        final int fileSize = await selectedImage.length();
        print("Seçilen resim: ${pickedFile.path}");
        print("Resim boyutu: ${(fileSize / 1024).toStringAsFixed(2)} KB");

        if (fileSize > 5 * 1024 * 1024) {
          print("Dosya çok büyük, sıkıştırılacak");

          // Büyük dosyaları sıkıştır
          final File? compressedFile = await _compressImage(selectedImage);

          setState(() {
            _imageFile = compressedFile ?? selectedImage;
          });
        } else {
          setState(() {
            _imageFile = selectedImage;
          });
        }
      }
    } catch (e) {
      print("Resim seçme hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçilirken bir hata oluştu: $e')),
      );
    }
  }

  // Resim seçme işlemini başlat (artık bottom sheet gösterecek)
  Future<void> _pickImage() async {
    _showImagePickerBottomSheet();
  }

  Future<File?> _compressImage(File file) async {
    try {
      final String dir = path.dirname(file.path);
      final String fileName = path.basenameWithoutExtension(file.path);
      final String ext = path.extension(file.path);
      final String targetPath = '$dir/${fileName}_compressed$ext';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (result != null) {
        final int originalSize = await file.length();
        final int compressedSize = await result.length();

        print("Orijinal boyut: ${(originalSize / 1024).toStringAsFixed(2)} KB");
        print("Sıkıştırılmış boyut: ${(compressedSize / 1024).toStringAsFixed(2)} KB");
        print("Sıkıştırma oranı: ${((1 - compressedSize / originalSize) * 100).toStringAsFixed(1)}%");

        return File(result.path);
      }
      return null;
    } catch (e) {
      print("Resim sıkıştırma hatası: $e");
      return null;
    }
  }

  Future<void> _testUpload() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen önce bir resim seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      // 1. Kullanıcı kontrolü
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Kullanıcı oturum açmamış");
      }

      // Basit test metni yükleme
      print("1. Metin dosyası yükleme testi yapılıyor...");

      final testBytes = Uint8List.fromList('Test içerik'.codeUnits);
      final testRef = FirebaseStorage.instance
          .ref()
          .child('test')
          .child('test_${DateTime.now().millisecondsSinceEpoch}.txt');

      await testRef.putData(testBytes);
      print("Test dosyası yüklendi");

      // Asıl resim yükleme
      print("2. Resim yükleme testi yapılıyor...");

      final String fileName = 'test_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('test_images')
          .child(fileName);

      // Yükleme işlemi
      final UploadTask uploadTask = ref.putFile(
        _imageFile!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // İlerlemeyi izle
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Yükleme ilerlemesi: ${(progress * 100).toStringAsFixed(1)}%');

        setState(() {
          _uploadProgress = progress;
        });
      });

      // Yükleme tamamlanana kadar bekle - önerilen yaklaşım
      final snapshot = await uploadTask.whenComplete(() => null);

      // URL al - önerilen yaklaşım
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Resim yüklendi: $downloadUrl");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test yüklemesi başarılı!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Test yükleme hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test yüklemesi başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadArtwork() async {
    // Form ve resim kontrolü
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir resim seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      // 1. Kullanıcı kontrolü
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Kullanıcı oturum açmamış");
      }

      // 2. Benzersiz dosya adı oluşturma
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String uniqueFileName = 'artwork_${currentUser.uid}_$timestamp.jpg';

      print("Eser yükleme başlıyor...");
      print("Dosya: ${_imageFile!.path}");
      print("Firebase bucket: ${FirebaseStorage.instance.bucket}");

      // 3. Doğrudan dosyayı kök dizine yüklemeyi deneyelim
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child(uniqueFileName);

      // Tam referans yolunu yazdır
      print("Kullanılan referans yolu: ${ref.fullPath}");

      // 4. Dosya yükleme
      final UploadTask uploadTask = ref.putFile(
        _imageFile!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // 5. İlerlemeyi izle
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Yükleme ilerlemesi: ${(progress * 100).toStringAsFixed(1)}%');
        setState(() {
          _uploadProgress = progress;
        });
      });

      // 6. Yükleme tamamlanmasını bekle
      final snapshot = await uploadTask.whenComplete(() => null);

      // 7. URL al
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ Eser yükleme başarılı!");
      print("İndirme URL: $downloadUrl");

      // 8. Firestore'a kaydet
      await FirebaseFirestore.instance.collection('artworks').add({
        'title': _titleController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': downloadUrl,
        'fileName': uniqueFileName,
        'userId': currentUser.uid,
        'userEmail': currentUser.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 9. Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eseriniz başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );

      // 10. Geri dön
      Navigator.of(context).pop();
    } catch (e) {
      print("❌ Eser yükleme hatası: $e");

      // Firebase hatası detaylarını yazdır
      if (e is FirebaseException) {
        print("Firebase hata kodu: ${e.code}");
        print("Firebase hata mesajı: ${e.message}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yükleme başarısız: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainAppColors.mainAppBarBackButton,
      appBar: MainAppbar(
        title: 'Eser Ekle',
        isbackButton: true,
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _buildFormView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          SizedBox(height: 20),
          Text(
            'Yükleniyor... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Geliştirilmiş Resim seçme alanı
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: _imageFile != null
                      ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Değiştir butonu
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Değiştir',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade800,
                          Colors.grey.shade900,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade700,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Fotoğraf Ekleyin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Resim seçmek için dokunun',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Test yükleme butonu

              SizedBox(height: 25),

              // Eser adı alanı
              Text(
                'Eser Adı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Eserinizin adını girin',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen eser adı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),

              // Kategori seçimi
              Text(
                'Kategori',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade800,
                    style: TextStyle(color: Colors.white),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),

              // Yükleme butonu
              GestureDetector(
                onTap: _uploadArtwork,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade600, Colors.pink.shade400],
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
                  child: Center(
                    child: Text(
                      "Eseri Yükle",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}