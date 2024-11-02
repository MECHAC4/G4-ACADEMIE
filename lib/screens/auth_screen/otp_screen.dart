import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:g4_academie/app_UI.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/services/verification.dart';

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

class _OTPVerificationPageState extends State<OTPVerificationPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isResendVisible = false;
  bool isButtonEnabled = false;
  String otpCode = '';

  @override
  void initState() {
    super.initState();
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
    if(widget.isPhoneUsed){
      print("*************************declenchement de la verification************************");
      verifyPhoneNumber();
    }else {
      sendOtp();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String verificationId = "";
  void verifyPhoneNumber() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseAuth.instance.verifyPhoneNumber(verificationCompleted: (phoneAuthCredential) async {

      print("*************************verification completed declenché************************");

      UserCredential userCredential = await auth.signInWithCredential(phoneAuthCredential);

      AppUser? appUser;

      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
            widget.signInData!.toMap()
          /*{
               'firstName': "José",
               'lastName':'ADJOVI',
               'userType': "Parent d'élève",
               'emailOrPhone': 'joseadjovi67@gmail.com',
               'password':'aa',
               'studentClass':'TLE',
               "address":"AB/ZOU"
             }*/
        );
        appUser = await AuthService().getUserById(userCredential.user!.uid);
        if (appUser != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppUI(appUser: appUser!, index: 0,),));
        }else{
          showMessage(context, "Utilisateur non récupéré");
        }
      }else{
        showMessage(context, "Erreur d'existence d'un utilisateur");
      }

      //print("****************$token*************************");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vérification réussie !')),
      );



      showMessage(context, "Numéro de téléphone vérifié");
    }, verificationFailed: (error) {
      print("*************************Echec de la vérification : $error************************");
      showMessage(context, "Echec de l'envoi de l'OTP sur ${widget.emailOrPhone}: \n $error");
    }, codeSent: (verificationID, forceResendingToken) {
      print("*************************Code envoyé************************");

      setState(() {
        verificationId = verificationID;
      });
      print("***********************Code envoyé*****************");
    }, codeAutoRetrievalTimeout: (verificationId) {
      print("*************************codeAutoRetrivialTimeOut************************");

    },timeout: const Duration(seconds:61), phoneNumber: widget.emailOrPhone);
  }



  Future<void> sendOtp() async {
    try {
      final HttpsCallable sendOtpCallable = FirebaseFunctions.instance.httpsCallable('sendOtp');
      await sendOtpCallable.call({
        'email': widget.isPhoneUsed? null:widget.emailOrPhone,
        'phoneNumber': widget.isPhoneUsed? widget.emailOrPhone:null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code OTP envoyé avec succès.')),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du code OTP : ${e.toString()}')),
      );
    }
  }

  Future<void> verifyOtp() async {
    try {
      if (!widget.isPhoneUsed) {
        final HttpsCallable verifyOtpCallable = FirebaseFunctions.instance.httpsCallable('verifyOtp');
        final result = await verifyOtpCallable.call({
          'email': widget.isPhoneUsed? null:widget.emailOrPhone,
          'phoneNumber': widget.isPhoneUsed? widget.emailOrPhone:null,
          'otp': otpCode,
        });
        final token = result.data['token'];
        UserCredential? userCredential = await FirebaseAuth.instance.signInWithCustomToken(token);
        AppUser? appUser;

         if (userCredential.user != null) {
           await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
             widget.signInData!.toMap()
             /*{
               'firstName': "José",
               'lastName':'ADJOVI',
               'userType': "Parent d'élève",
               'emailOrPhone': 'joseadjovi67@gmail.com',
               'password':'aa',
               'studentClass':'TLE',
               "address":"AB/ZOU"
             }*/
           );
           appUser = await AuthService().getUserById(userCredential.user!.uid);
           if (appUser != null) {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppUI(appUser: appUser!, index: 0,),));
           }else{
             showMessage(context, "Utilisateur non récupéré");
           }
         }else{
           showMessage(context, "Erreur d'existence d'un utilisateur");
         }

        print("****************$token*************************");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vérification réussie !')),
        );
      }else{
        //PhoneAuthCredential credential =
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otpCode,
        );
      }
      // Naviguer vers la page suivante ou connecter l'utilisateur avec le token
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  void onOtpComplete(String otp) {
    setState(() {
      otpCode = otp;
      isButtonEnabled = otp.length == 6;
    });
  }

  void onResendOtp() {
    setState(() {
      isResendVisible = false;
      _controller.reset();
      _controller.forward();
    });
    if (!widget.isPhoneUsed) {
      sendOtp();
    }else{
      verifyPhoneNumber();
    }
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
              const Text(
                'Vérification du code OTP',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                  //numberOfFields: 6,
                  //borderColor: const Color(0xFF512DA8),
                  //focusedBorderColor: Colors.deepPurple,
                  filled: true,
                  //showFieldAsBox: true,
                  onSubmit: onOtpComplete,
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  //fieldWidth: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.grey[300],
                    color: Colors.deepPurple,
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isButtonEnabled ? verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: const Text(
                  'Vérifier',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              //if (isResendVisible)
                TextButton(
                  onPressed: onResendOtp,
                  child: const Text(
                    "Renvoyer le code",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
