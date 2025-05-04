import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String>? favoriteProducts;
  final List<String>? recentlyViewedProducts;
  final Map<String, dynamic>? preferences;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.address,
    this.city,
    this.country,
    this.zipCode,
    required this.createdAt,
    this.lastLoginAt,
    this.favoriteProducts,
    this.recentlyViewedProducts,
    this.preferences,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'country': country,
      'zipCode': zipCode,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'favoriteProducts': favoriteProducts,
      'recentlyViewedProducts': recentlyViewedProducts,
      'preferences': preferences,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      city: map['city'],
      country: map['country'],
      zipCode: map['zipCode'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.parse(map['lastLoginAt']) 
          : null,
      favoriteProducts: map['favoriteProducts'] != null 
          ? List<String>.from(map['favoriteProducts']) 
          : null,
      recentlyViewedProducts: map['recentlyViewedProducts'] != null 
          ? List<String>.from(map['recentlyViewedProducts']) 
          : null,
      preferences: map['preferences'],
      isActive: map['isActive'] ?? true,
    );
  }

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    String? city,
    String? country,
    String? zipCode,
    DateTime? lastLoginAt,
    List<String>? favoriteProducts,
    List<String>? recentlyViewedProducts,
    Map<String, dynamic>? preferences,
    bool? isActive,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      recentlyViewedProducts: recentlyViewedProducts ?? this.recentlyViewedProducts,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
    );
  }

  // Add a product to favorites
  UserModel addToFavorites(String productId) {
    List<String> updatedFavorites = List<String>.from(favoriteProducts ?? []);
    if (!updatedFavorites.contains(productId)) {
      updatedFavorites.add(productId);
    }
    return copyWith(favoriteProducts: updatedFavorites);
  }

  // Remove a product from favorites
  UserModel removeFromFavorites(String productId) {
    List<String> updatedFavorites = List<String>.from(favoriteProducts ?? []);
    updatedFavorites.remove(productId);
    return copyWith(favoriteProducts: updatedFavorites);
  }

  // Add a product to recently viewed
  UserModel addToRecentlyViewed(String productId) {
    List<String> updatedRecent = List<String>.from(recentlyViewedProducts ?? []);
    // Remove if already exists to avoid duplicates
    updatedRecent.remove(productId);
    // Add to the beginning of the list
    updatedRecent.insert(0, productId);
    // Keep only the last 10 items
    if (updatedRecent.length > 10) {
      updatedRecent = updatedRecent.sublist(0, 10);
    }
    return copyWith(recentlyViewedProducts: updatedRecent);
  }

}