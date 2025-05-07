import 'package:flutter/material.dart';
import 'package:art_app/const/app_color.dart';
import 'package:art_app/main_widgets/app_bar/main_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user/user_model.dart';
import '../../service/image_recognazitioon/imaga_service.dart';
import '../add_art_page/model/art_model.dart';

class ArtworkDetailPage extends StatefulWidget {
  final ArtworkModel artwork;

  const ArtworkDetailPage({
    Key? key,
    required this.artwork,
  }) : super(key: key);

  @override
  State<ArtworkDetailPage> createState() => _ArtworkDetailPageState();
}

class _ArtworkDetailPageState extends State<ArtworkDetailPage> {
  UserModel? _artist;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _currentUserId;
  bool _processingFavorite = false;
  int _favoriteCount = 0;

  // Imagga ile ilgili değişkenler
  String _artworkDescription = "";
  bool _analyzingImage = false;
  List<String> _artworkTags = [];
  Map<String, dynamic> _artworkColors = {};

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchArtistData();
    _fetchFavoriteCount();
    _checkForExistingAnalysis(); // Önce mevcut analizi kontrol et
  }

  // Firestore'da mevcut analiz var mı kontrol et
  void _checkForExistingAnalysis() async {
    try {
      DocumentSnapshot artworkDoc = await FirebaseFirestore.instance
          .collection('artworks')
          .doc(widget.artwork.id)
          .get();

      if (artworkDoc.exists) {
        Map<String, dynamic> data = artworkDoc.data() as Map<String, dynamic>;

        if (data.containsKey('aiDescription') &&
            data['aiDescription'] != null) {
          // Mevcut analiz var, verileri yükle
          setState(() {
            _artworkDescription = data['aiDescription'];
            _artworkTags = List<String>.from(data['aiTags'] ?? []);

            // Renk verisi varsa onu da yükle
            if (data.containsKey('aiColors')) {
              _artworkColors = data['aiColors'];
            }
          });
        } else {
          // Analiz yok, yeni analiz başlat
          _analyzeArtworkImage();
        }
      } else {
        // Eser dokümanı yok, analiz başlat
        _analyzeArtworkImage();
      }
    } catch (e) {
      print('Analiz kontrolü hatası: $e');
      _analyzeArtworkImage(); // Hata durumunda analiz başlat
    }
  }

  // Imagga API ile resmi analiz et
  void _analyzeArtworkImage() async {
    if (widget.artwork.imageUrl.isEmpty) return;

    setState(() {
      _analyzingImage = true;
    });

    try {
      // Etiketleri al
      final tagsResult = await ImaggaService.getTags(widget.artwork.imageUrl);
      print('Tags API sonucu: ${tagsResult.containsKey('error') ? tagsResult['error'] : 'başarılı'}');

      // Renkleri al
      final colorsResult = await ImaggaService.getColors(widget.artwork.imageUrl);
      print('Colors API sonucu: ${colorsResult.containsKey('error') ? colorsResult['error'] : 'başarılı'}');

      // Etiketleri kaydet
      if (tagsResult.containsKey('result') &&
          tagsResult['result'].containsKey('tags') &&
          tagsResult['result']['tags'].isNotEmpty) {
        List<String> tags = [];
        for (var tag in tagsResult['result']['tags']) {
          if (tag['confidence'] > 30) { // Sadece güven skoru yüksek etiketleri al
            tags.add(tag['tag']['en']);
          }
        }

        setState(() {
          _artworkTags = tags;
        });
      }

      // Renkleri kaydet
      if (colorsResult.containsKey('result') &&
          colorsResult['result'].containsKey('colors')) {
        setState(() {
          _artworkColors = colorsResult['result']['colors'];
        });
      }

      // Açıklama oluştur
      final description = ImaggaService.generateDescription(tagsResult, colorsResult);

      // Firestore'da eserin dokümanına açıklamayı kaydet
      await FirebaseFirestore.instance
          .collection('artworks')
          .doc(widget.artwork.id)
          .update({
        'aiDescription': description,
        'aiTags': _artworkTags,
        'aiColors': _artworkColors,
        'analyzedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _artworkDescription = description;
        _analyzingImage = false;
      });
    } catch (e) {
      print('Resim analiz hatası: $e');
      setState(() {
        _artworkDescription = "Bu eser için otomatik analiz yapılırken bir hata oluştu.";
        _analyzingImage = false;
      });
    }
  }
  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _checkIfFavorite();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchArtistData() async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.artwork.userEmail)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          _artist = UserModel.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        print('Artist not found!');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching artist: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchFavoriteCount() async {
    try {
      DocumentSnapshot artworkDoc = await FirebaseFirestore.instance
          .collection('artworks')
          .doc(widget.artwork.id)
          .get();

      if (artworkDoc.exists) {
        Map<String, dynamic> data = artworkDoc.data() as Map<String, dynamic>;
        int favCount = data['favoriteCount'] ?? 0;

        setState(() {
          _favoriteCount = favCount;
        });
      } else {
        // Artwork document doesn't exist or doesn't have favoriteCount field
        setState(() {
          _favoriteCount = 0;
        });
      }
    } catch (e) {
      print('Error fetching favorite count: $e');
      setState(() {
        _favoriteCount = 0;
      });
    }
  }

  void _checkIfFavorite() async {
    if (_currentUserId == null) return;

    try {
      // Check if the artwork is in favorites collection
      var favoriteDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_currentUserId)
          .collection('userFavorites')
          .doc(widget.artwork.id)
          .get();

      setState(() {
        _isFavorite = favoriteDoc.exists;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  void _toggleFavorite() async {
    if (_currentUserId == null || _processingFavorite) return;

    setState(() {
      _processingFavorite = true;
    });

    try {
      // Reference to the favorites collection
      final userFavoritesRef = FirebaseFirestore.instance
          .collection('favorites')
          .doc(_currentUserId)
          .collection('userFavorites')
          .doc(widget.artwork.id);

      // Reference to the artwork document
      final artworkRef = FirebaseFirestore.instance
          .collection('artworks')
          .doc(widget.artwork.id);

      // Get current artwork data to check if favoriteCount exists
      DocumentSnapshot artworkDoc = await artworkRef.get();

      if (_isFavorite) {
        // Remove from favorites
        await userFavoritesRef.delete();

        // Decrease favorite count in artwork document
        if (artworkDoc.exists) {
          // Use transaction to safely update counter
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot freshSnapshot = await transaction.get(artworkRef);
            Map<String, dynamic> data = freshSnapshot.data() as Map<
                String,
                dynamic>;

            int currentCount = data['favoriteCount'] ??
                1; // Default to 1 if not set
            int newCount = currentCount > 0
                ? currentCount - 1
                : 0; // Prevent negative counts

            transaction.update(artworkRef, {'favoriteCount': newCount});

            // Update UI counter
            setState(() {
              _favoriteCount = newCount;
            });
          });
        }
      } else {
        // Add to favorites
        await userFavoritesRef.set({
          'artworkId': widget.artwork.id,
          'title': widget.artwork.title,
          'imageUrl': widget.artwork.imageUrl,
          'category': widget.artwork.category,
          'artistId': widget.artwork.userId,
          'artistEmail': widget.artwork.userEmail,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Increase favorite count in artwork document
        if (artworkDoc.exists) {
          // Use transaction to safely update counter
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot freshSnapshot = await transaction.get(artworkRef);
            if (freshSnapshot.exists) {
              Map<String, dynamic> data = freshSnapshot.data() as Map<
                  String,
                  dynamic>;
              int currentCount = data['favoriteCount'] ?? 0;
              int newCount = currentCount + 1;

              transaction.update(artworkRef, {'favoriteCount': newCount});

              // Update UI counter
              setState(() {
                _favoriteCount = newCount;
              });
            } else {
              // If artwork document doesn't exist yet, create it
              transaction.set(artworkRef, {
                'favoriteCount': 1,
                // You might want to add other basic artwork info here
                'id': widget.artwork.id,
                'title': widget.artwork.title,
                'category': widget.artwork.category,
              });

              // Update UI counter
              setState(() {
                _favoriteCount = 1;
              });
            }
          });
        } else {
          // If artwork document doesn't exist, create it
          await artworkRef.set({
            'favoriteCount': 1,
            // You might want to add other basic artwork info here
            'id': widget.artwork.id,
            'title': widget.artwork.title,
            'category': widget.artwork.category,
          });

          // Update UI counter
          setState(() {
            _favoriteCount = 1;
          });
        }
      }

      setState(() {
        _isFavorite = !_isFavorite;
        _processingFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'Favorilere eklendi'
              : 'Favorilerden çıkarıldı'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.pink.shade400,
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem sırasında bir hata oluştu'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red.shade400,
        ),
      );
      setState(() {
        _processingFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainAppColors.mainAppBarBackButton,
      extendBodyBehindAppBar: true,
      appBar: MainAppbar(
        title: widget.artwork.title,
        isbackButton: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image at the top
            Stack(
              children: [
                // Artwork image
                Container(
                  width: double.infinity,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.6,
                  child: Image.network(
                    widget.artwork.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay for readability
                Container(
                  width: double.infinity,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: [0.7, 1.0],
                    ),
                  ),
                ),
                // Title and category at the bottom of the image
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.artwork.category,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.artwork.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Artist information section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artist info row
                  Row(
                    children: [
                      // Artist avatar - using initials since there's no profile picture in the model
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.pink.shade400,
                        child: Text(
                          _artist?.name != null && _artist!.name.isNotEmpty
                              ? _artist!.name.substring(0, 1).toUpperCase()
                              : "?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Artist name and date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _artist?.name ?? "Bilinmeyen Sanatçı",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Favorite counter with heart icon
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.pink.shade400,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.pink.shade400,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$_favoriteCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Favorite button
                      IconButton(
                        onPressed: _currentUserId != null
                            ? _toggleFavorite
                            : null,
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                          size: 28,
                        ),
                      ),
                      // Share button
                      IconButton(
                        onPressed: () {
                          // Share functionality would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Paylaşım özelliği yakında!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Artwork description section - Imagga ile güncellendi
                  Row(
                    children: [
                      Text(
                        "Eser Açıklaması",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_analyzingImage)
                        SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.pink.shade400,
                            )
                        ),
                      if (!_analyzingImage && _artworkTags.isNotEmpty)
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.pink.shade400,
                          size: 16,
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _analyzingImage
                        ? "Eser yapay zeka tarafından analiz ediliyor..."
                        : (_artworkDescription.isNotEmpty
                        ? _artworkDescription
                        : "Bu ${widget.artwork
                        .category} eseri, sanatçı ${_artist?.name ??
                        'Bilinmeyen Sanatçı'} tarafından yaratılmıştır. Eser, sanat koleksiyonunuza değer katacak nitelikte bir çalışmadır."),
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  // Etiketler bölümü
                  if (_artworkTags.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      "Yapay Zeka Etiketleri",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _artworkTags.take(10).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Renk analizi bölümü
                  if (_artworkColors.isNotEmpty &&
                      _artworkColors.containsKey('foreground_colors') &&
                      _artworkColors['foreground_colors'].isNotEmpty) ...[
                    Text(
                      "Renk Analizi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _artworkColors['foreground_colors'].length,
                        itemBuilder: (context, index) {
                          final color = _artworkColors['foreground_colors'][index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _hexToColor(color['html_code']),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${(color['percent'] as num).toStringAsFixed(
                                      0)}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                  ],

                  SizedBox(height: 24),

                  // Technical details section
                  Text(
                    "Teknik Detaylar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Details in a stylish container
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow("Kategori", widget.artwork.category),
                        Divider(color: Colors.grey.shade800, height: 24),
                        _buildDetailRow("Sanatçı ID", widget.artwork.userId),
                        Divider(color: Colors.grey.shade800, height: 24),
                        _buildDetailRow("Eser ID", widget.artwork.id),
                        Divider(color: Colors.grey.shade800, height: 24),
                        _buildDetailRow(
                            "Favori Sayısı", _favoriteCount.toString()),
                        if (_artworkTags.isNotEmpty) ...[
                          Divider(color: Colors.grey.shade800, height: 24),
                          _buildDetailRow("AI Etiket Sayısı",
                              _artworkTags.length.toString()),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Contact artist button
                  ElevatedButton(
                    onPressed: () {
                      // Contact functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Sanatçı ile iletişim kurma özelliği yakında!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.pink.shade400, width: 2),
                      ),
                    ),
                    child: Text(
                      "Sanatçı ile İletişime Geç",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Purchase button
                  ElevatedButton(
                    onPressed: () {
                      // Purchase functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Satın alma özelliği yakında!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.pink.shade700,
                    ),
                    child: Text(
                      "Bu Eseri Satın Al",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Benzer eserler bölümü - Imagga analizi ile geliştirilmiş
                  Text(
                    "Benzer Eserler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Benzer eserler listesi - gelecekte AI etiketlerine göre öneri yapılabilir
                  _artworkTags.isNotEmpty
                      ? Container()
                      : Text(
                    "Henüz benzer eser bulunamadı. Daha fazla içerik için kategorileri keşfedin.",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
// Hex renk kodunu Color nesnesine dönüştüren yardımcı metod
Color _hexToColor(String hexCode) {
  hexCode = hexCode.replaceAll('#', '');
  if (hexCode.length == 6) {
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  return Colors.grey;
}