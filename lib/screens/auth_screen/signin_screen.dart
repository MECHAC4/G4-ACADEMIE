import 'package:country_code_picker/country_code_picker.dart'
    show CountryCodePicker;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/constants.dart';
import 'package:g4_academie/screens/auth_screen/forget_passsword_screen.dart';
import 'package:g4_academie/screens/auth_screen/signup_screen.dart';

import '../../app_UI.dart';
import '../../services/auth_services.dart';
import '../../services/cache/cache_service.dart';
import '../../services/verification.dart';
import '../../theme/theme.dart';
import '../../users.dart';
import '../../widgets/custom_scaffold.dart';
import 'google_signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  bool isPhoneNumberVerified = false;
  String? uid;
  AppUser? _appUser;
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isPView = true;
  bool isPhoneVer = false;



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    emailController.dispose();
  }

  late TabController _tabController;
  String _countriesNumber = "+229";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 5,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  width / 20, height / 30, width / 20, height / 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue sur $appName',
                        style: TextStyle(
                          fontSize: height / 28,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: height / 35,
                          //fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      DefaultTabController(
                        length: 2,
                        animationDuration: const Duration(milliseconds: 300),
                        initialIndex: 0,
                        child: Column(
                          children: [
                            TabBar(
                              onTap: (value) => setState(() {}),
                              controller: _tabController,
                              tabs: const [
                                Text("Avec email"),
                                Text("Avec téléphone"),
                              ],
                              indicatorWeight: 5,
                              indicatorSize: TabBarIndicatorSize.tab,
                              padding: const EdgeInsets.only(bottom: 20),
                            ),
                            _tabController.index == 0
                                ? TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: emailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Entrez votre email, s'il vous plaît";
                                      } else if (!isValidEmail(
                                          emailController.text)) {
                                        return "Entrez une adresse email valide";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      label: const Text('Email'),
                                      hintText: "Entrez votre email",
                                      hintStyle: const TextStyle(
                                        color: Colors.black26,
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                : Table(
                                    children: [
                                      TableRow(
                                        children: [
                                          CountryCodePicker(
                                            //padding: const EdgeInsets.only(left: 5),
                                            alignLeft: true,
                                            onChanged: (value) {
                                              setState(() {
                                                _countriesNumber =
                                                    value.toString();
                                                debugPrint(
                                                    "**************$_countriesNumber************");
                                              });
                                              //print("***************$value**************");
                                            },
                                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                            initialSelection: 'BJ',

                                            favorite: const ['+229', 'BJ'],
                                            //countryFilter: const ['IT', 'FR'],
                                            // flag can be styled with BoxDecoration's `borderRadius` and `shape` fields
                                            flagDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                          ),
                                          TextFormField(
                                            onChanged: (value) {
                                              setState(() {
                                                isPhoneVer = false;
                                              });
                                            },
                                            controller: phoneNumberController,
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Entrez votre numéro de téléphone, s'il vous plaît";
                                              } else if (!isPhoneNumberVerified) {
                                                return "Vous devez vérifier ce numéro";
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              suffixIcon: TextButton(
                                                  onPressed: () async {
                                                    if (isValidPhoneNumber(
                                                        phoneNumberController
                                                            .text) && !isPhoneVer) {
                                                      setState(() {
                                                        isPhoneVer = true;
                                                      });
                                                      uid = await verifyPhoneNumber(
                                                          context,
                                                          _countriesNumber +
                                                              phoneNumberController
                                                                  .text);
                                                      /*uid = await AuthService()
                                                          .verifyPhoneNumber(
                                                              context,
                                                              _countriesNumber +
                                                                  phoneNumberController
                                                                      .text);*/
                                                      Future.delayed(const Duration(seconds: 4));
                                                      setState(() {
                                                        (uid == null)
                                                            ? isPhoneNumberVerified =
                                                                false
                                                            : isPhoneNumberVerified =
                                                                true;
                                                      });
                                                      isPhoneVer = false;
                                                    }
                                                  },
                                                  child: isPhoneNumberVerified
                                                      ? Icon(
                                                          Icons.check,
                                                          color:
                                                              lightColorScheme
                                                                  .primary,
                                                        )
                                                      :isPhoneVer?const Center(child: CircularProgressIndicator(),): const Text(
                                                          "Vérifier",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )),
                                              label: const Text('Téléphone'),
                                              hintText:
                                                  "Entrez votre numéro de téléphone",
                                              hintStyle: const TextStyle(
                                                color: Colors.black26,
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors
                                                      .black12, // Default border color
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors
                                                      .black12, // Default border color
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              controller: passwordController,
                              obscureText: isPView,
                              obscuringCharacter: '*',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Entrez votre mot de passe s'il vous plait";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                suffixIcon: IconButton(onPressed: (){
                                  setState(() {
                                    isPView = !isPView;
                                  });
                                }, icon: Icon(isPView? Icons.visibility: Icons.visibility_off)),
                                label: const Text('Mot de passe'),
                                hintText: 'Entrez votre mot de passe',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                        Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height / 35,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Se souvenir de moi',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const ForgetPasswordScreen(),
                            )),
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AppUI(),));
                            if (_formSignInKey.currentState!.validate() &&
                                rememberPassword) {
                              setState(() {
                                isSigninWaiting = true;
                              });
                              showMessage(context, "Traitement des données");
                              if (_tabController.index == 0) {
                                _appUser = await AuthService().signInWithEmail(
                                    context,
                                    emailController.text,
                                    passwordController.text);
                              } else {
                                _appUser = await AuthService().signInWithPhone(
                                    context,
                                    uid!,
                                    _countriesNumber +
                                        phoneNumberController.text,
                                    passwordController.text);
                              }
                              setState(() {});
                              if (_appUser != null) {
                                showMessage(context, "Connexion réussie");
                                SignUpDataManager().saveSignUpInfo(_appUser!.id, "canConnect");

                                /*Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AppUI(
                                    appUser: _appUser!,
                                  ),
                                ));*/
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                  builder: (context) => AppUI(
                                    appUser: _appUser!,
                                  ),
                                ), (route) => false,);
                              } else {
                                setState(() {
                                  isSigninWaiting = false;
                                });
                              }
                            } else if (!rememberPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Veuillez accepter le traitement des données personnelles')),
                              );
                            }
                          },
                          child: isSigninWaiting
                              ? const CircularProgressIndicator(color : Colors.white)
                              : const Text("Se connecter"),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Se connecter avec',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          AppUser? currentAppUser;
                          setState(() {
                            isGoogleCliked = true;
                          });
                          uid = await AuthService().signInWithGoogle(context);
                          if (uid != null) {
                            final isSignup =
                                await AuthService().isGoogleUserExist(uid!);
                            if (isSignup) {
                              currentAppUser =
                                  await AuthService().getUserById(uid!);
                            }
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                              builder: (context) {
                                if (isSignup) {
                                  SignUpDataManager().saveSignUpInfo(currentAppUser!.id, "canConnect");

                                  return AppUI(appUser: currentAppUser);
                                }
                                return GoogleSignUp(uid: uid!);
                              },
                            ),(route) => false,);/* Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                if (isSignup) {
                                  SignUpDataManager().saveSignUpInfo(currentAppUser!.id, "canConnect");

                                  return AppUI(appUser: currentAppUser);
                                }
                                return GoogleSignUp(uid: uid!);
                              },
                            ));*/
                          } else {
                            showMessage(context,
                                "Une erreur s'est produite lors de l'authentification avec google");
                            setState(() {
                              isGoogleCliked = false;
                            });
                          }
                        },
                        child: Center(
                          child: isGoogleCliked
                              ? const CircularProgressIndicator()
                              : Image.asset(
                                  "lib/Assets/google.png",
                                  width: MediaQuery.of(context).size.width / 15,
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'N\'avez-vous pas un compte? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'S\'inscrire',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSigninWaiting = false;
  bool isGoogleCliked = false;


final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> verifyPhoneNumber(BuildContext context, String phone) async {
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
        showMessage(context,
            "Un code de vérification est envoyé au $phone.\nIl sera expiré dans 60 secondes");
        showDialog(context: context, builder: (context) {
          final double width = MediaQuery
              .of(context)
              .size
              .width;
          final double height = MediaQuery
              .of(context)
              .size
              .height;
          final TextEditingController smsCodeController = TextEditingController();
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: width / 10, vertical: height / 15),
            content: SizedBox(
              height: height / 4,
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
                  TextButton(onPressed: () {
                    Navigator.of(context).pop();
                    verifyPhoneNumber(context, phone);
                  },
                      child: const Text(
                          "Renvoyez le code", style: TextStyle(color: Colors
                          .white))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(onPressed: () {
                        Navigator.of(context).pop();
                      }, child: const Text(
                        "Annuler", style: TextStyle(color: Colors.white),)),
                      ElevatedButton(
                        onPressed: () async {
                          PhoneAuthCredential credential = PhoneAuthProvider
                              .credential(
                            verificationId: verificationId,
                            smsCode: smsCodeController.text,
                          );
                          try {
                            await _auth.signInWithCredential(credential);
                            if (_auth.currentUser != null) {
                              Navigator.of(context).pop();
                              setState(() {
                                isPhoneNumberVerified = true;
                              });
                              showMessage(context, "Vérification réussie");
                            }
                          } catch (e) {
                            showMessage(context,
                                "Échec de la vérification : code invalide");
                          }
                        },
                        child: const Text(
                          "Vérifier", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },);
      },
      timeout: const Duration(seconds: 61),
      codeAutoRetrievalTimeout: (
          String verificationId) { // Code de vérification automatique expiré
        showMessage(context,
            "Le code de vérification est expiré.\nDemandez un nouveau");
      },
    );
    if(_auth.currentUser?.uid != null && _auth.currentUser!.uid.isNotEmpty) {
      setState(() {
        isPhoneNumberVerified = true;
      });
    }
    return _auth.currentUser?.uid;
  }

}
