import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g4_academie/services/verification.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

import '../users.dart';
import 'encrypt_service.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryptionService = EncryptionService();

  // Enregistrement par email
  Future<AppUser?> registerWithEmail(
      BuildContext context,
      String email,
      String password,
      String firstName,
      String lastName,
      String address,
      String userType, {
        List<String>? subject,
      }) async {
    try {
      debugPrint("************************sign in...*************************");

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String encryptedPassword = _encryptionService.encryptPassword(password);

      // Stockage des informations dans Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'userType': userType,
        'emailOrPhone': email,
        'password': encryptedPassword,
        'subject': subject,
      });

      return AppUser(
        id: userCredential.user?.uid ?? '',
        firstName: firstName,
        lastName: lastName,
        address: address,
        userType: userType,
        emailOrPhone: email,
        password: encryptedPassword,
        subject: subject,
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showMessage(context, "Mot de passe trop faible.\nCombinez des chiffres, des majuscules et des caractères spéciaux");
        return null;
      } else if (e.code == 'email-already-in-use') {
        showMessage(context, "Vous avez déjà un compte avec cet email.\nConnectez-vous !");
        return null;
      }
      showMessage(context, "Une erreur s'est produite : ${e.toString()}");
      return null;
    } catch (e) {
      debugPrint(e as String?);
      showMessage(context, "Une erreur s'est produite: ${e.toString()}");
      return null;
    }
  }


  Future<String?> verifyPhoneNumber(BuildContext context,String phone)async{

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
         await _auth.signInWithCredential(credential);
        showMessage(context, "Numéro de téléphone vérifié");
        },
      verificationFailed: (FirebaseAuthException e) {
        showMessage(context, "Echec de la vérification");
      },
      codeSent: (String verificationId, int? resendToken) {
        showMessage(context, "Un code de vérification est envoyé au $phone.\nIl sera expiré dans 60 secondes");
        showDialog(context: context, builder: (context) {
          final double width = MediaQuery.of(context).size.width;
          final double height = MediaQuery.of(context).size.height;
          final TextEditingController smsCodeController = TextEditingController();
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: width/10, vertical: height/15),
            content: SizedBox(
              height: height/4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: smsCodeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veillez entrer le code de vérification envoyé sur $phone';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('Code de vérification'),
                      hintText: 'Entrez le code de vérification',
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12, // Default border color
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12, // Default border color
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  TextButton(onPressed: (){
                    Navigator.of(context).pop();
                    verifyPhoneNumber(context, phone);
                  }, child: const Text("Renvoyez le code", style: TextStyle(color: Colors.white))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Annuler", style: TextStyle(color: Colors.white),)),
                      ElevatedButton(
                        onPressed: () async {
                          PhoneAuthCredential credential = PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: smsCodeController.text,
                          );
                          try {
                            await _auth.signInWithCredential(credential);
                            if (_auth.currentUser != null) {
                              Navigator.of(context).pop();
                              showMessage(context, "Vérification réussie");
                            }
                          } catch (e) {
                            showMessage(context, "Échec de la vérification : code invalide");
                          }
                        },
                        child: const Text("Vérifier", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },);
      },
      timeout : const Duration(seconds: 61),
      codeAutoRetrievalTimeout: (String verificationId) {// Code de vérification automatique expiré
      showMessage(context, "Le code de vérification est expiré.\nDemandez un nouveau");
        },
    );
    return _auth.currentUser?.uid;
  }









  // Enregistrement par numéro de téléphone
  Future<AppUser?> registerWithPhone(
      BuildContext context,
      String uid,
      String phone,
      String password,
      String firstName,
      String lastName,
      String address,
      String userType, {
        List<String>? subject,
      }) async {
    try {
      String encryptedPassword = _encryptionService.encryptPassword(password);

      // Stockage des informations dans Firestore
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'userType': userType,
        'emailOrPhone': phone,
        'password': encryptedPassword,
        'subject': subject,
      });
      return AppUser(
        id : uid,
        firstName: firstName,
        lastName: lastName,
        address: address,
        userType: userType,
        emailOrPhone: phone,
        password: encryptedPassword,
        subject: subject,
      );
    } catch (e) {
      print(e.toString());
      showMessage(context, "Erreur lors de l'enregistrement des données : ${e.toString()}");
    }
    return null;
  }

  Future<bool> isGoogleUserExist(String uid)async{
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }


  Future<AppUser?> getUserById(String uid) async {
    try {
      // Récupération des données de l'utilisateur depuis Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Conversion des données en une instance de AppUser
        return AppUser.fromMap(userDoc.data() as Map<String, dynamic>, uid);
      } else {
        // Si le document n'existe pas, retourner null
        return null;
      }
    } catch (e) {
      // Gestion des erreurs
      print('Erreur lors de la récupération de l\'utilisateur : $e');
      return null;
    }
  }








  // Connexion par email
  Future<AppUser?> signInWithEmail(
      BuildContext context,
      String email,
      String password,
      ) async {
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        return getUserById(_auth.currentUser!.uid);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          debugPrint('Aucun utilisateur trouvé pour cet e-mail.');
          showMessage(context,"Aucun utilisateur trouvé pour cet e-mail.\nInscrivez-vous.\n${e.toString()}");
          return null;
        } else if (e.code == 'wrong-password') {
          debugPrint('Mot de passe erroné fourni pour cet utilisateur.');
          showMessage(context,"Mot de passe incorrect : ${e.toString()}");
          return null;
        } else {
          showMessage(context, "Mot de passe incorrect : ${e.toString()}");
          debugPrint('Problème : *******************$e');
          return null;
        }
      }
  }

  // Connexion par numéro de téléphone
  Future<AppUser?> signInWithPhone(
      BuildContext context,
      String uid,
      String phone,
      String password,
      ) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final docData = doc.data() as Map<String, dynamic>;
      AppUser? appUser = AppUser.fromMap(doc.data() as Map<String, dynamic>, uid);

      // Décryptage du mot de passe stocké
      String decryptedPassword = _encryptionService.decryptPassword(docData["password"]);

      // Vérification du mot de passe
      if (decryptedPassword == password) {
        return appUser;
      } else {
        showMessage(context, "Mot de passe incorrect");
        return null;
      }
    } else {
      showMessage(context, "Compte non existant : veillez vous inscrire");
      return null;
    }
  }




  // Authentification par Google
  Future<String?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user!.uid;
    } catch (e) {
      print(e.toString());
      showMessage(context, "Une erreur s'est produite: ${e.toString()}");
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

}
