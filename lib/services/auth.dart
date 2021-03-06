import 'package:firebase_auth/firebase_auth.dart';

import 'package:totfet/services/messaging.dart';
import 'package:totfet/models/Usuari.dart';
import 'package:totfet/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Creates a User instance based on the Firebase user
  Usuari _userFromFirebaseUser(User user) {
    return user != null ? Usuari(uid: user.uid) : null;
  }

  String get userId {
    return _auth.currentUser.uid;
  }

  String get userEmail {
    return _auth.currentUser.email;
  }

  // auth change user stream
  Stream<Usuari> get userStream {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in email psw
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Actualitzem el valor del token cada cop que entrem a la sessió.
      // Si el valor es el mateix no es fa res, perque es canvia per un
      // valor exactament igual.
      String token = await MessagingService().getToken();
      User user = result.user;
      await DatabaseService().actualitzarToken(user.uid, token);

      return {
        "response": _userFromFirebaseUser(user),
        "error": null,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {
          "response": null,
          "error": "No existeix cap usuari amb aquesta adreça electrònica.\n"
        };
      } else if (e.code == 'wrong-password') {
        return {
          "response": null,
          "error": "La contrasenya és incorrecta, torna a intentar-ho.\n"
        };
      } else if (e.code == 'invalid-email') {
        return {
          "response": null,
          "error": "L'adreça electrònica no té un format correcte.\n"
        };
      } else {
        return {
          "response": null,
          "error": "Hi ha hagut un error, torna a intentar-ho.\n" + e.toString()
        };
      }
    } catch (e) {
      print(e.toString());
      return {
        "response": null,
        "error": e.toString(),
      };
    }
  }

  // register email psw
  Future registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User user = result.user;

      // Database register
      Usuari defaultUser = Usuari.perDefecte(user.uid);
      defaultUser.nom = username;
      defaultUser.token = await MessagingService().getToken();
      await DatabaseService(uid: user.uid).updateUserData(defaultUser);
      return {
        "response": _userFromFirebaseUser(user),
        "error": null,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Contrasenya massa dèbil.');
        return {
          "response": null,
          "error": "Contrasenya massa dèbil. Prova amb una de més complicada.",
        };
      } else if (e.code == 'email-already-in-use') {
        print('Ja existeix una conta amb aquest correu electrònic');
        return {
          "response": null,
          "error": "Ja existeix una conta amb aquesta adreça.",
        };
      } else if (e.code == 'invalid-email') {
        print('Adreça de correu no vàlida');
        return {
          "response": null,
          "error": "Siusplau introdueix una adreça de correu vàlida.",
        };
      } else {
        return {
          "response": null,
          "error": "Hi ha hagut un error desconegut, torna a intentar-ho.\n" +
              e.toString()
        };
      }
    } catch (e) {
      print(e.toString());
      return {
        "response": null,
        "error": e.toString(),
      };
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "0";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("No s'ha trobat cap usuari amb aquesta adreça");
        return "No s'ha trobat cap usuari amb aquesta adreça. Pot ser que la conta s'hagi esborrat.";
      } else if (e.code == 'invalid-email') {
        print(
          "L'adreça electrònica no és correcta. Sembla que no té un format adient.",
        );
        return "L'adreça electrònica no és correcta. Sembla que no té un format adient.";
      } else {
        return e.toString();
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
