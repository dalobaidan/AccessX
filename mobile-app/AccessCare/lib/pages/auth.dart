import 'package:firebase_auth/firebase_auth.dart';

//this class is for the firebase authentication and its not considered a widget for us
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Returns the currently signed-in Firebase user, or null if nobody is logged in. This is a synchronous getter — it reads whatever Firebase already knows from its local cache (no network call needed).
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Signs in with email/password via Firebase Authentication. this is async because it makes a network request to Firebase's servers.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Creates a new Firebase Auth user. Same pattern as signIn
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
