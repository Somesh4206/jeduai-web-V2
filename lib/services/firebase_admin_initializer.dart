import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Admin Initializer
/// Creates default admin account in Firestore on first run
class FirebaseAdminInitializer {
  static const String defaultAdminEmail = 'admin@vsb.edu';
  static const String defaultAdminPassword = 'admin123';
  static const String defaultAdminName = 'System Administrator';

  static Future<void> initializeDefaultAdmin() async {
    try {
      print('🔧 Checking for default admin account...');

      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if admin already exists in Firestore
      final adminQuery = await firestore
          .collection('admins')
          .where('email', isEqualTo: defaultAdminEmail)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        print('✅ Default admin already exists in Firestore');
        return;
      }

      print('📝 Creating default admin account...');

      // Try to create admin with Firebase Auth
      UserCredential? userCredential;
      try {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: defaultAdminEmail,
          password: defaultAdminPassword,
        );
        print('✅ Firebase Auth admin account created');
      } catch (authError) {
        // If account already exists in Auth but not in Firestore, sign in
        if (authError.toString().contains('email-already-in-use')) {
          print('⚠️ Admin email already in Firebase Auth, signing in...');
          try {
            userCredential = await auth.signInWithEmailAndPassword(
              email: defaultAdminEmail,
              password: defaultAdminPassword,
            );
            print('✅ Signed in to existing admin account');
          } catch (signInError) {
            print('❌ Could not sign in to existing admin: $signInError');
            return;
          }
        } else {
          print('❌ Firebase Auth error: $authError');
          return;
        }
      }

      // userCredential should not be null at this point
      User? user = userCredential?.user;
      if (user == null) {
        print('❌ Failed to get user from credential');
        return;
      }

      // Update display name
      await user.updateDisplayName(defaultAdminName);

      String uid = user.uid;

      // Create admin document in Firestore
      Map<String, dynamic> adminData = {
        'uid': uid,
        'name': defaultAdminName,
        'email': defaultAdminEmail,
        'role': 'admin',
        'permissions': ['all'],
        'managedDepartments': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isDefaultAdmin': true,
      };

      // Create in admins collection
      await firestore.collection('admins').doc(uid).set(adminData);
      print('✅ Admin document created in admins collection');

      // Also create in users collection for compatibility
      await firestore.collection('users').doc(uid).set(adminData);
      print('✅ Admin document created in users collection');

      // Sign out after creation
      await auth.signOut();

      print('🎉 Default admin account initialized successfully!');
      print('📧 Email: $defaultAdminEmail');
      print('🔑 Password: $defaultAdminPassword');
    } catch (e) {
      print('❌ Error initializing default admin: $e');
    }
  }
}
