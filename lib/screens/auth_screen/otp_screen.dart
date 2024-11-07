import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/screens/auth_screen/signup_screen.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/add_cours_builder.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/services/verification.dart';

import '../../profil_class.dart';
import '../../services/cache/cache_service.dart';
import '../../services/profil_services.dart';
import '../../users.dart';

class OTPVerificationPage extends StatefulWidget {
  final String emailOrPhone;
  final bool isPhoneUsed;
  final AppUser? signInData;
  final bool haveAccount;

  const OTPVerificationPage({
    Key? key,
    this.haveAccount = true,
    required this.isPhoneUsed,
    this.signInData,
    required this.emailOrPhone,
  }) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isResendVisible = false;
  bool isButtonEnabled = false;
  String otpCode = '';
  bool isLoading = false;
  bool con = false;
  bool ins = false;
  int seconds = 60;
  Timer? _timer;
  bool isResent = false;

  void startTimer() {
    // Annuler le timer existant s'il y en a un
    _timer?.cancel();
    seconds = 60; // Réinitialiser le compteur à 60 secondes

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds = seconds - 1; // Diminue le compteur chaque seconde
        });
      } else {
        timer.cancel(); // Arrêter le timer lorsque le compteur atteint 0
        setState(() {
          isResendVisible = true; // Afficher le bouton de renvoi du code
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 300), // 5 minutes
    );
    _controller.forward();
    _controller.addListener(() {
      if (_controller.isCompleted) {
        setState(() {
          isResendVisible = true;
        });
      }
    });
    if (widget.isPhoneUsed) {
      print(
          "*************************declenchement de la verification************************");
      verifyPhoneNumber();
    } else {
      sendOtp();
    }
  }



  List<ProfilClass> profiles = [];

  void loadProfiles(AppUser appUser) async {
    profiles = await ProfilServices().fetchProfiles(appUser.id);
    setState(() {});
  }

  void createMainProfile(AppUser appUser) async {
    bool mainProfilExist = await ProfilServices().profilExist(appUser.id);
    if (!mainProfilExist) {
      ProfilServices().saveProfileToFirestore({
        'firstName': appUser.firstName,
        'lastName': appUser.lastName,
        'studentClass': appUser.studentClass ?? 'Particulière',
        'adresse': appUser.address,
      }, appUser.id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel(); // Arrête le timer lorsque l'écran est fermé
    super.dispose();
  }

  String verificationId = "";

  void verifyPhoneNumber() async {
    setState(() {
      isLoading = true;
    });
    //FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseAuth.instance.verifyPhoneNumber(
        verificationCompleted: (phoneAuthCredential) async {
          /* print(
              "*************************verification completed declenché************************");

          UserCredential userCredential =
              await auth.signInWithCredential(phoneAuthCredential);

          AppUser? appUser;

          if (userCredential.user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set(widget.signInData!.toMap());
            appUser = await AuthService().getUserById(userCredential.user!.uid);
            if (appUser != null) {
              loadProfiles(appUser);
              createMainProfile(appUser);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddCourseDialog(
                  profiles: profiles,
                  appUser: appUser!,
                ),
              ));
              SignUpDataManager()
                  .saveSignUpInfo(appUser.id, "canConnect");
            } else {
              setState(() {
                ins = true;
                con = false;
              });
              showMessage(context, "Aucun compte trouvé avec ${widget.emailOrPhone}.\nVeuillez vous inscrire.");
            }
          } else {
            showMessage(context, "Une erreur innatendue s'est produite");
          }

          //print("****************$token*************************");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vérification réussie !')),
          );

          showMessage(context, "Numéro de téléphone vérifié");*/
        },
        verificationFailed: (error) {
          print(
              "*************************Echec de la vérification : $error************************");
          showMessage(context,
              "Echec de l'envoi de l'OTP sur ${widget.emailOrPhone}: \n $error");
        },
        codeSent: (verificationID, forceResendingToken) {
          print("*************************Code envoyé************************");

          setState(() {
            verificationId = verificationID;
          });
          print("***********************Code envoyé*****************");
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print(
              "*************************codeAutoRetrivialTimeOut************************");
        },
        timeout: const Duration(seconds: 61),
        phoneNumber: widget.emailOrPhone);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> sendOtp() async {
    try {
      final HttpsCallable sendOtpCallable =
          FirebaseFunctions.instance.httpsCallable('sendOtp');
      await sendOtpCallable.call({
        'email': widget.isPhoneUsed ? null : widget.emailOrPhone,
        'phoneNumber': widget.isPhoneUsed ? widget.emailOrPhone : null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code OTP envoyé avec succès.')),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur lors de l\'envoi du code OTP : ${e.toString()}')),
      );
    }
  }

  Future<void> verifyOtp() async {
    print("otp! $otpCode");
    print("longueur: ${otpCode.length}");
    if (otpCode.trim().length >= 6) {
      print("code reçu! $otpCode");
      print("longueur: ${otpCode.length}");
      setState(() {
        isLoading = true;
      });
      try {
        if (!widget.isPhoneUsed) {
          final HttpsCallable verifyOtpCallable =
              FirebaseFunctions.instance.httpsCallable('verifyOtp');
          final result = await verifyOtpCallable.call({
            'email': widget.isPhoneUsed ? null : widget.emailOrPhone,
            'phoneNumber': widget.isPhoneUsed ? widget.emailOrPhone : null,
            'otp': otpCode.trim(),
          });
          final token = result.data['token'];
          final haveAcount = result.data['userExist'];
          print(
              "****************Le compte exist déjà??? $haveAcount************");
          UserCredential? userCredential =
              await FirebaseAuth.instance.signInWithCustomToken(token);
          AppUser? appUser;

          if (userCredential.user != null && widget.haveAccount == haveAcount) {
            if (!haveAcount) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .set(widget.signInData!.toMap());
            }
            appUser = await AuthService().getUserById(userCredential.user!.uid);
            if (appUser != null) {
              loadProfiles(appUser);
              createMainProfile(appUser);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddCourseDialog(
                  profiles: profiles,
                  appUser: appUser!,
                ),
              ));
              SignUpDataManager().saveSignUpInfo(appUser.id, "canConnect");
            } else {
              showMessage(context,
                  "Erreur lors de la récupération des informations de l'utilisateur.\nVeuillez reessayer!");
            }
          } else if (widget.haveAccount != haveAcount && widget.haveAccount) {
            setState(() {
              ins = true;
              con = false;
            });
            showMessage(context,
                "Nous n'avons trouvé aucun compte avec ${widget.emailOrPhone}.\nVeuillez-vous inscrire.");
          } else if (widget.haveAccount != haveAcount && !widget.haveAccount) {
            setState(() {
              ins = false;
              con = true;
            });
            showMessage(context,
                "Vous avez déjà un compte avec ${widget.emailOrPhone}.\nVeuillez-vous connecter.");
          } else {
            showMessage(context,
                "Une erreur inattendue s'est produite.\nVeuillez reessayer plus tard");
          }
          print("****************$token*************************");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vérification réussie !')),
          );
        } else {
          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: otpCode.trim(),
          );

          FirebaseAuth auth = FirebaseAuth.instance;
          UserCredential userCredential =
              await auth.signInWithCredential(phoneAuthCredential);

          AppUser? appUser;

          if (userCredential.user != null) {
            bool haveAcount =
                await AuthService().isGoogleUserExist(userCredential.user!.uid);

            if (widget.haveAccount == haveAcount) {
              if (!widget.haveAccount) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .set(widget.signInData!.toMap());
              }
              appUser =
                  await AuthService().getUserById(userCredential.user!.uid);
              if (appUser != null) {
                loadProfiles(appUser);
                createMainProfile(appUser);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddCourseDialog(
                    profiles: profiles,
                    appUser: appUser!,
                  ),
                ));
                SignUpDataManager().saveSignUpInfo(appUser.id, "canConnect");
              } else {
                setState(() {
                  ins = true;
                  con = false;
                });
                showMessage(context,
                    "Aucun compte trouvé avec ${widget.emailOrPhone}.\nVeuillez vous inscrire.");
              }
            } else if (haveAcount) {
              setState(() {
                ins = false;
                con = true;
              });
              showMessage(context,
                  "Vous avez déjà un compte sur le ${widget.emailOrPhone}.\nVeuillez-vous connecter");
            } else if (!haveAcount) {
              setState(() {
                ins = true;
                con = false;
              });
              showMessage(context,
                  "Aucun compte trouvé pour ${widget.emailOrPhone}.\nVeuillez-vous inscrire");
            }
          } else {
            showMessage(context, "Une erreur innatendue s'est produite");
          }

          //print("****************$token*************************");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vérification réussie !')),
          );

          showMessage(context, "Numéro de téléphone vérifié");
        }
        // Naviguer vers la page suivante ou connecter l'utilisateur avec le token
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
      setState(() {
        isLoading = false;
      });
    } else {
      showMessage(context, "Remplissage incomplet");
    }
  }

  /*void onOtpComplete(String otp) {
    setState(() {
      otpCode = otp;
      isButtonEnabled = otp.length == 6;
    });
  }*/

  void onResendOtp() {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => OTPVerificationPage(isPhoneUsed: widget.isPhoneUsed, emailOrPhone: widget.emailOrPhone,haveAccount: widget.haveAccount,signInData: widget.signInData),));
    /*setState(() {
      seconds = 60;
      _timer?.cancel();
      startTimer();
      isResent = true;
      otpCode = '';
      isResendVisible = false;
      _controller.reset();
      _controller.forward();
    });
    if (!widget.isPhoneUsed) {
      sendOtp();
    } else {
      verifyPhoneNumber();
    }
    setState(() {
      isResent = false;
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF512DA8),
                      )),
                  const Text(
                    'Vérification du code OTP',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Nous avons envoyé un code à ${widget.emailOrPhone}',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Flexible(
                child: OtpTextField(
                  numberOfFields: 6,
                  borderColor: const Color(0xFF512DA8),
                  focusedBorderColor: Colors.deepPurple,
                  showFieldAsBox: true,
                  borderWidth: 1.0,
                  //borderWidth: 20,
                  autoFocus: true,

                  filled: true,
                  onSubmit: (value) {
                    setState(() {
                      otpCode = value;
                    });
                    print("Value finale: $value");
                  },
                  //showFieldAsBox: true,
                  //onSubmit: onOtpComplete,
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  //fieldWidth: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    seconds>0? "Le code va s'expirer dans: ": 'Le code est expiré',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if(seconds>0)
                  Flexible(
                    child: Text(
                      '$seconds secondes',
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              /*AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                  );
                },
              ),*/
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Vérifier',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 15),
              if (isResendVisible)
              TextButton(
                onPressed: onResendOtp,
                child: isResent
                    ? const CircularProgressIndicator(
                        color: Colors.blue,
                      )
                    : const Text(
                        "Renvoyer le code",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (con)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ));
                      },
                      child: const Text("Connexion")),
                ),
              if (ins)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ));
                      },
                      child: const Text("Inscription")),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
