import 'package:cloud_firestore/cloud_firestore.dart';

class ArtworkModel {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final int rating;
  final String userId;
  final String userEmail;
  final DateTime createdAt;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
  });

  factory ArtworkModel.fromJson(Map<String, dynamic> json, String docId) {
    return ArtworkModel(
      id: docId,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: json['rating'] ?? 0,
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': createdAt,
    };
  }
}