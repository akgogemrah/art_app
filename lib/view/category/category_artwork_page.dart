import 'package:flutter/material.dart';
import 'package:art_app/const/app_color.dart';
import 'package:art_app/main_widgets/app_bar/main_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../view/add_art_page/model/art_model.dart';
import '../category/artwork_detail_page.dart';

class CategoryArtworksPage extends StatefulWidget {
  final String categoryName;

  const CategoryArtworksPage({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryArtworksPage> createState() => _CategoryArtworksPageState();
}

class _CategoryArtworksPageState extends State<CategoryArtworksPage> {
  List<ArtworkModel> _artworks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryArtworks();
  }

  void _fetchCategoryArtworks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('category', isEqualTo: widget.categoryName)
          .orderBy('createdAt', descending: true)
          .get();

      final List<ArtworkModel> artworks = snapshot.docs.map((doc) {
        return ArtworkModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id, // Pass the document ID
        );
      }).toList();

      setState(() {
        _artworks = artworks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching artworks: $e');
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
        title: '${widget.categoryName} Eserleri',
        isbackButton: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _artworks.isEmpty
          ? _buildEmptyState()
          : _buildArtworkGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.art_track,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Bu kategoride henüz eser bulunmuyor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Diğer Kategorilere Bak',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: _artworks.length,
        itemBuilder: (context, index) {
          final artwork = _artworks[index];
          return _buildArtworkCard(artwork, index);
        },
      ),
    );
  }

  Widget _buildArtworkCard(ArtworkModel artwork, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to artwork detail page
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artwork Image
              AspectRatio(
                aspectRatio: (index % 2 == 0) ? 0.8 : 1.2, // Varying aspect ratios for visual interest
                child: Image.network(
                  artwork.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade800,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Artwork Title and User Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artwork.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(artwork.userEmail)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'Yükleniyor...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        }

                        String userName = 'Bilinmeyen Sanatçı';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final userData = snapshot.data!.data() as Map<String, dynamic>;
                          userName = userData['name'] ?? 'Bilinmeyen Sanatçı';
                        }

                        return Text(
                          userName,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}