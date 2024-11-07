import 'package:country_code_picker/country_code_picker.dart'
    show CountryCodePicker;
import 'package:flutter/material.dart';
import 'package:g4_academie/constants.dart';
import 'package:g4_academie/screens/auth_screen/google_signup_screen.dart';
import 'package:g4_academie/screens/auth_screen/otp_screen.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/services/cache/cache_service.dart';
import 'package:g4_academie/users.dart';

import '../../app_UI.dart';
import '../../services/verification.dart';
import '../../theme/theme.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/marquee.dart';
import '../dashboard_screens/builder/add_cours_builder.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  late TabController _tabController;
  String _countriesNumber = "+229";
  List<String>? subject = [];
  String? serie;

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();

  //final TextEditingController adresseController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final TextEditingController quartierController = TextEditingController();
  bool isP1View = true;
  bool isP2View = true;
  //bool isPhoneVer = false;
  String? studentClass;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    villeController.dispose();
    quartierController.dispose();
  }

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
              height: 10,
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
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Débuter sur $appName',
                        style: TextStyle(
                          fontSize: height / 28,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),

                      StatefulBuilder(
                        builder: (context, setState) {
                          return const ZigZagMarquee(
                            text: 'INSCRIPTION',
                          );
                        },
                      ),

                      // full name
                      DefaultTabController(
                        length: 2,
                        initialIndex: 0,
                        animationDuration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              onTap: (value) => setState(() {}),
                              controller: _tabController,
                              tabs: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _tabController.index = 0;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                      elevation: 10,
                                      padding: const EdgeInsets.only(
                                          bottom: 0, top: 15)),
                                  child: Text("Avec téléphone",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: _tabController.index == 0
                                              ? FontWeight.w900
                                              : null,
                                          color: _tabController.index == 0
                                              ? lightColorScheme.primary
                                              : lightColorScheme.secondary)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _tabController.index = 1;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                      elevation: 10,
                                      padding: const EdgeInsets.only(
                                          bottom: 0, top: 15)),
                                  child: Text("Avec email",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: _tabController.index == 1
                                              ? FontWeight.w900
                                              : null,
                                          color: _tabController.index == 1
                                              ? lightColorScheme.primary
                                              : lightColorScheme.secondary)),
                                )
                              ],
                              //indicatorPadding: EdgeInsets.only(bottom: 0),
                              isScrollable: true,
                              indicatorWeight: 5,
                              indicatorSize: TabBarIndicatorSize.tab,
                              automaticIndicatorColorAdjustment: true,
                              padding: const EdgeInsets.only(bottom: 16),
                            ),
                            TextFormField(
                              controller: nomController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre nom';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Nom'),
                                hintText: 'Entrer votre nom',
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
                            const SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              controller: prenomController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre/vos prénom(s)';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Prénom(s)'),
                                hintText: 'Entrer votre/vos prénom(s)',
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

                            const SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              controller: villeController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre Ville ou village';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Ville ou village'),
                                hintText: 'Entrer votre ville ou village',
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

                            const SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              controller: quartierController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre quartier';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Quartier'),
                                hintText: 'Entrer votre quartier',
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
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              width: width,
                              padding: EdgeInsets.symmetric(
                                  vertical: height / 45,
                                  horizontal: width / 30),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black12)),
                              child: DropdownButton(
                                underline: const SizedBox.shrink(),
                                isDense: true,
                                isExpanded: true,
                                value: _selectedUserType,
                                alignment: Alignment.centerLeft,
                                hint: const Text(
                                  "Type d'utilisateur",
                                  style: TextStyle(
                                      // color: Colors.black26,
                                      ),
                                ),
                                items: usersType.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUserType = value!;
                                  });
                                },
                              ),
                            ),

                            if (_selectedUserType == usersType[1])
                              const SizedBox(
                                height: 25.0,
                              ),
                            if (_selectedUserType == usersType[1])
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.6),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    title: Text(matiere == null
                                        ? "Choisissez votre matière"
                                        : matiere!),
                                    onTap: () => setState(() {
                                      setState(() {
                                        _openSubjectsDialog(context);
                                      });
                                    }),
                                    trailing: const Icon(
                                        Icons.keyboard_arrow_down_outlined),
                                  )),
                            if (_selectedUserType == usersType[0])
                              const SizedBox(
                                height: 25,
                              ),
                            if (_selectedUserType == usersType[0])
                              DropdownButtonFormField<String>(
                                validator: (value) {
                                  if(value == null || studentClass == null){
                                    return "Choisir une classe";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Sélectionner votre classe',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                //hint: const Text("Sélectionner une classe"),
                                value: studentClass,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      studentClass = newValue;
                                      studentClassController.text = newValue;
                                    }
                                  });
                                },
                                items: classes.map((String className) {
                                  return DropdownMenuItem<String>(
                                    value: className,
                                    child: Text(className),
                                  );
                                }).toList(),
                              ),
                            if (_selectedUserType == usersType[0] &&
                                studentClass != null &&
                                classes.indexOf(studentClass!) >=
                                    classes.indexOf('2nd'))
                              const SizedBox(
                                height: 25.0,
                              ),
                            if (_selectedUserType == usersType[0] &&
                                studentClass != null &&
                                classes.indexOf(studentClass!) >=
                                    classes.indexOf('2nd'))
                              DropdownButtonFormField(
                                validator: (value) {
                                  if(value == null || serie == null){
                                    return "Choisir votre série";
                                  }
                                  return null;
                                },
                                value: serie,
                                decoration: InputDecoration(
                                  labelText: 'Sélectionner votre série',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                isExpanded: true,
                                items: series.map(
                                  (String serie) {
                                    return DropdownMenuItem(
                                      value: serie,
                                      child: Text(serie),
                                    );
                                  },
                                ).toList(),
                                onChanged: (value) {},
                              ),

                            const SizedBox(
                              height: 25.0,
                            ),
                            // email
                            _tabController.index == 1
                                ? TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Entrez votre email, s'il vous plaît";
                                      } else if (_tabController.index == 1 &&
                                          !isValidEmail(emailController.text)) {
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
                                            controller: phoneNumberController,
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Entrez votre numéro de téléphone, s'il vous plaît";
                                              } else if (_tabController.index ==
                                                      0 &&
                                                  !isValidPhoneNumber(
                                                      phoneNumberController
                                                          .text)) {
                                                return "Entrez un numéro de téléphone valide";
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
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
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'J\' la collecte de ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            'Données personnelles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData && _selectedUserType!=null) {
                              if (_selectedUserType == usersType[0]) {
                                studentClassController.text ='${studentClassController.text} ${serie!}';
                              }
                              showMessage(context, "Traitement des données");
                              setState(() {
                                isSignupWaiting = true;
                              });
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return OTPVerificationPage(
                                    emailOrPhone: _tabController.index == 1
                                        ? emailController.text.trim()
                                        : _countriesNumber +
                                            phoneNumberController.text.trim(),
                                    isPhoneUsed: _tabController.index == 0,
                                    haveAccount: false,
                                    signInData: AppUser(
                                        id: '',
                                        firstName: nomController.text.trim(),
                                        lastName: prenomController.text.trim(),
                                        address:
                                            '${villeController.text.trim()}/${quartierController.text.trim()}',
                                        userType: _selectedUserType!,
                                        emailOrPhone:
                                            emailController.text.trim(),
                                        password: '',
                                        studentClass:
                                            studentClassController.text.trim()),
                                  );
                                },
                              ));
                            } else if (!agreePersonalData) {
                              showMessage(context,
                                  "Veillez accepter la collecte de donnée personnelle");
                            }
                          },
                          child: isSignupWaiting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('S\'inscrire'),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up divider
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
                              'S\'inscrire avec',
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
                        height: 30.0,
                      ),
                      // sign up social media logo
                      GestureDetector(
                        onTap: () async {
                          AppUser? user;
                          setState(() {
                            isGoogleCliked = true;
                          });
                          uid = await AuthService().signInWithGoogle(context);
                          if (uid != null) {
                            final isSignin =
                                await AuthService().isGoogleUserExist(uid!);
                            if (isSignin) {
                              user = await AuthService().getUserById(uid!);
                            }
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => isSignin
                                  ? AppUI(appUser: user!)
                                  : GoogleSignUp(uid: uid!),
                            ));
                            SignUpDataManager()
                                .saveSignUpInfo(uid!, "canConnect");
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
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Avez-vous déjà un compte ?',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Se connecter',
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

  String? uid;
  String? _selectedUserType;
  List<String> usersType = ["Elève", "Enseignant", "Parent d'élève"];
  bool isSignupWaiting = false;
  bool isGoogleCliked = false;
  String? matiere;
  final TextEditingController studentClassController = TextEditingController();

  void _openSubjectsDialog(BuildContext context) async {
    final ans = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SubjectsDialog();
      },
    );
    setState(() {
      matiere = ans.toString();
      subject?.add(ans.toString());
      print("***************$subject***************");
    });
    print("mitiere_selectionné: ${ans.toString()}");
  }

/*suffixIcon: TextButton(
                                                  onPressed: () async {
                                                    if (isValidPhoneNumber(
                                                            phoneNumberController
                                                                .text) &&
                                                        !isPhoneVer) {
                                                      print("Appuyé");
                                                      setState(() {
                                                        isPhoneVer = true;
                                                        print(
                                                            "Appuyé et changement d'état ? $isPhoneVer");
                                                      });
                                                      uid = await verifyPhoneNumber(
                                                          context,
                                                          _countriesNumber +
                                                              phoneNumberController
                                                                  .text);
                                                      Future.delayed(
                                                          const Duration(
                                                              seconds: 4));
                                                      setState(() {
                                                        (uid == null)
                                                            ? isPhoneNumberVerified =
                                                                false
                                                            : isPhoneNumberVerified =
                                                                true;
                                                      });
                                                      isPhoneVer = false;
                                                      print(
                                                          "Appuyé et rechangement d'état ? $isPhoneVer");
                                                    }
                                                  },
                                                  child: isPhoneNumberVerified
                                                      ? Icon(
                                                          Icons.check,
                                                          color:
                                                              lightColorScheme
                                                                  .primary,
                                                        )
                                                      : isPhoneVer
                                                          ? const Center(
                                                              child:
                                                                  CircularProgressIndicator())
                                                          : const Text(
                                                              "Vérifier",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            )),*/

/*const SizedBox(
                              height: 25.0,
                            ),
                            // password
                            TextFormField(
                              controller: passwordController,
                              obscureText: isP1View,
                              obscuringCharacter: '*',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veillez entrer un mot de passe';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isP1View = !isP1View;
                                      });
                                    },
                                    icon: Icon(isP1View
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                                label: const Text('Mot de passe'),
                                hintText: 'Entrez un mot de passe',
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
                            const SizedBox(
                              height: 25.0,
                            ),
                            // password
                            TextFormField(
                              controller: rePasswordController,
                              obscureText: isP2View,
                              obscuringCharacter: '*',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veillez retapper le mot de passe';
                                } else if (rePasswordController.text.trim() !=
                                    passwordController.text.trim()) {
                                  return 'Ratapez le même mot de passe';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isP2View = !isP2View;
                                      });
                                    },
                                    icon: Icon(isP2View
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                                label: const Text('Retappez le mot de passe'),
                                hintText: 'Retappez le mot de passe',
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
                            ),*/

/*void addSubject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(
                            matiere == null ? "Choisir une matière" : matiere!),
                        onTap: () => setState(() {
                          setState(() {
                            _openSubjectsDialog(context);
                          });
                        }),
                        trailing:
                            const Icon(Icons.keyboard_arrow_down_outlined),
                      )),
                  /*TextFormField(
                      controller: subjectController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veillez entrer une matière';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Matière'),
                        hintText: 'Entrez une matière',
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
                    ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Annuler")),
                      TextButton(
                          onPressed: () {
                            if (matiere != null) {
                              Navigator.of(context).pop();
                              setState(() {
                                subject?.add(matiere!);
                              });
                              matiere = null;
                            } else {
                              showMessage(context, "Choisissez une matière");
                            }
                          },
                          child: const Text("Ajouter"))
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }*/

//final TextEditingController subjectController = TextEditingController();
/*await signUpWithEmail(
                                      context,
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                      nomController.text,
                                      prenomController.text,
                                      '${villeController.text.trim()}/${quartierController.text.trim()}',
                                      //adresseController.text,
                                      _selectedUserType!,
                                      subject: subject,
                                      studentClass: studentClassController.text,
                                    )
                                  : await signUpWithPhoneNumber(
                                      context,
                                      phoneNumberController.text.trim(),
                                      passwordController.text.trim(),
                                      nomController.text,
                                      prenomController.text,
                                      '${villeController.text.trim()}/${quartierController.text.trim()}',
                                      _selectedUserType!,
                                      subject: subject,
                                      studentClass: studentClassController.text,
                                    );
                              setState(() {});
                              setState(() {});
                              setState(() {});
                              setState(() {});
                              if (_appUser != null) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => AppUI(
                                      appUser: _appUser!,
                                    ),
                                  ),
                                  (route) => false,
                                ); /*Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AppUI(
                                    appUser: _appUser!,
                                  ),
                                ));*/
                                SignUpDataManager()
                                    .saveSignUpInfo(_appUser!.id, "canConnect");
                              } else {
                                setState(() {
                                  isSignupWaiting = false;
                                });
                              }*/

/*Future<void> signUpWithEmail(
      BuildContext context,
      String email,
      String password,
      String firstName,
      String lastName,
      String address,
      String userType,
      {List<String>? subject,
      String? studentClass}) async {
    _appUser = await AuthService().registerWithEmail(
        context, email, password, firstName, lastName, address, userType,
        subject: subject, studentClass: studentClass);
    setState(() {
      _appUser = _appUser;
    });
  }*/

//bool isPhoneNumberVerified = false;

/*Future<void> signUpWithPhoneNumber(
      BuildContext context,
      String phone,
      String password,
      String firstName,
      String lastName,
      String address,
      String userType,
      {List<String>? subject,
      String? studentClass}) async {
    _appUser = await AuthService().registerWithPhone(
        context, uid!, phone, password, firstName, lastName, address, userType,
        subject: subject, studentClass: studentClass);
    setState(() {
      _appUser = _appUser;
    });
  }*/
/*TextFormField(
                                controller: studentClassController,
                                validator: (value) {
                                  if (_selectedUserType == usersType[0] &&
                                      (value == null || value.isEmpty)) {
                                    return 'Entrez votre classe';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label: const Text('Classe'),
                                  hintText: 'Entrer votre classe',
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
                              ),*/
/*Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                width: width,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: GridView.builder(
                                  itemCount: subject!.length < 4
                                      ? subject!.length + 1
                                      : subject!.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 4,
                                          crossAxisCount: 2),
                                  itemBuilder: (context, index) {
                                    return index + 1 != subject!.length + 1
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${subject![index]}  ",
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  size: height / 45,
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    subject?.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        : TextButton(
                                            onPressed: () {
                                              setState(() {
                                                //addSubject(context);
                                              });
                                            },
                                            child: ListTile(
                                              title: Text(matiere == null
                                                  ? "Choisir une matière"
                                                  : matiere!, ),
                                              onTap: () => setState(() {
                                                setState(() {
                                                  _openSubjectsDialog(context);
                                                });
                                              }),
                                              trailing: const Icon(Icons
                                                  .keyboard_arrow_down_outlined),
                                            ),
                                          );
                                  },
                                ),
                              ),*/

//final FirebaseAuth _auth = FirebaseAuth.instance;

/*Future<String?> verifyPhoneNumber(BuildContext context, String phone) async {
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
        showDialog(
          context: context,
          builder: (context) {
            final double width = MediaQuery.of(context).size.width;
            final double height = MediaQuery.of(context).size.height;
            final TextEditingController smsCodeController =
                TextEditingController();
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
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          verifyPhoneNumber(context, phone);
                        },
                        child: const Text("Renvoyez le code",
                            style: TextStyle(color: Colors.white))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Annuler",
                              style: TextStyle(color: Colors.white),
                            )),
                        ElevatedButton(
                          onPressed: () async {
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
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
                            "Vérifier",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      timeout: const Duration(seconds: 61),
      codeAutoRetrievalTimeout: (String verificationId) {
        // Code de vérification automatique expiré
        showMessage(context,
            "Le code de vérification est expiré.\nDemandez un nouveau");
      },
    );
    if (_auth.currentUser?.uid != null && _auth.currentUser!.uid.isNotEmpty) {
      setState(() {
        isPhoneNumberVerified = true;
      });
    }
    return _auth.currentUser?.uid;
  }*/
}
