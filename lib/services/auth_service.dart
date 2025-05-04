import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, {String? displayName}) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create a new user document in Firestore
      await _createUserInFirestore(userCredential.user!, displayName: displayName);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserInFirestore(User user, {String? displayName}) async {
    // Update display name if provided
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }
    
    // Create user model
    UserModel newUser = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: displayName ?? user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      favoriteProducts: [],
      recentlyViewedProducts: [],
      preferences: {
        'theme': 'light',
        'notifications': true,
      },
    );
    
    // Save to Firestore
    await _usersCollection.doc(user.uid).set(newUser.toMap());
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Attempt to sign in with Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify that we got a valid user
      if (userCredential.user == null) {
        throw Exception('Authentication failed');
      }
      
      // Check if user exists in Firestore
      final userDoc = await _usersCollection.doc(userCredential.user!.uid).get();
      
      // If user doesn't exist in Firestore, create them
      if (!userDoc.exists) {
        await _createUserInFirestore(userCredential.user!);
      } else {
        // Update last login time
        await _usersCollection.doc(userCredential.user!.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;
    
    DocumentSnapshot doc = await _usersCollection.doc(currentUser!.uid).get();
    
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    String? city,
    String? country,
    String? zipCode,
    Map<String, dynamic>? preferences,
  }) async {
    if (currentUser == null) return;
    
    Map<String, dynamic> updates = {};
    
    if (displayName != null) {
      updates['displayName'] = displayName;
      await currentUser!.updateDisplayName(displayName);
    }
    
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
      await currentUser!.updatePhotoURL(photoUrl);
    }
    
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (address != null) updates['address'] = address;
    if (city != null) updates['city'] = city;
    if (country != null) updates['country'] = country;
    if (zipCode != null) updates['zipCode'] = zipCode;
    if (preferences != null) updates['preferences'] = preferences;
    
    if (updates.isNotEmpty) {
      await _usersCollection.doc(currentUser!.uid).update(updates);
    }
  }

  // Add product to favorites
  Future<void> addToFavorites(String productId) async {
    if (currentUser == null) return;
    
    UserModel? user = await getUserData();
    if (user == null) return;
    
    UserModel updatedUser = user.addToFavorites(productId);
    await _usersCollection.doc(currentUser!.uid).update({
      'favoriteProducts': updatedUser.favoriteProducts,
    });
  }

  // Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    if (currentUser == null) return;
    
    UserModel? user = await getUserData();
    if (user == null) return;
    
    UserModel updatedUser = user.removeFromFavorites(productId);
    await _usersCollection.doc(currentUser!.uid).update({
      'favoriteProducts': updatedUser.favoriteProducts,
    });
  }

  // Add product to recently viewed
  Future<void> addToRecentlyViewed(String productId) async {
    if (currentUser == null) return;
    
    UserModel? user = await getUserData();
    if (user == null) return;
    
    UserModel updatedUser = user.addToRecentlyViewed(productId);
    await _usersCollection.doc(currentUser!.uid).update({
      'recentlyViewedProducts': updatedUser.recentlyViewedProducts,
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    if (currentUser == null) return;
    
    try {
      // Delete user data from Firestore
      await _usersCollection.doc(currentUser!.uid).delete();
      
      // Delete user from Firebase Auth
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('The email address is badly formatted.');
      case 'user-disabled':
        return Exception('This user has been disabled.');
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('The email address is already in use.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed.');
      case 'weak-password':
        return Exception('The password is too weak.');
      case 'requires-recent-login':
        return Exception('This operation requires recent authentication. Please log in again.');
      default:
        return Exception('An unknown error occurred: ${e.message}');
    }
  }
}
