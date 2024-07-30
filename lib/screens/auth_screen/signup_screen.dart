import 'package:country_code_picker/country_code_picker.dart'
    show CountryCodePicker;
import 'package:flutter/material.dart';
import 'package:g4_academie/constants.dart';
import 'package:g4_academie/screens/auth_screen/google_signup_screen.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/users.dart';

import '../../app_UI.dart';
import '../../services/verification.dart';
import '../../theme/theme.dart';
import '../../widgets/custom_scaffold.dart';

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
  AppUser? _appUser;

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

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
                      Text(
                        'Inscription',
                        style: TextStyle(
                          fontSize: height / 35,
                          //fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
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
                              tabs: const [
                                Text("Avec email"),
                                Text("Avec téléphone"),
                              ],
                              indicatorWeight: 5,
                              indicatorSize: TabBarIndicatorSize.tab,
                              padding: const EdgeInsets.only(bottom: 20),
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
                              controller: adresseController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre adresse';
                                } else if (!isValidAddress(
                                    adresseController.text)) {
                                  return 'Format requis : ville ou village/Quartier';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Adresse'),
                                hintText: 'Entrer votre adresse',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                helperText:
                                    "Format pour l'adresse : Ville ou Village/Quartier",
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: width,
                                height: subject != [] && subject!.length < 2
                                    ? 60
                                    : 100,
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
                                                addSubject(context);
                                              });
                                            },
                                            child: const Text(
                                                "Ajouter une matière"));
                                  },
                                ),
                              ),

                            const SizedBox(
                              height: 25.0,
                            ),

                            // email
                            _tabController.index == 0
                                ? TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Entrez votre email, s'il vous plaît";
                                      } else if (_tabController.index == 0 &&
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
                                                      1 &&
                                                  !isValidPhoneNumber(
                                                      phoneNumberController
                                                          .text)) {
                                                return "Entrez un numéro de téléphone valide";
                                              }
                                              else if(!isPhoneNumberVerified){
                                                return "Vérifiez votre numéro de téléphone";
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              suffixIcon: isPhoneNumberVerified
                                                  ? Icon(
                                                      Icons.check,
                                                      color: lightColorScheme
                                                          .primary,
                                                    )
                                                  : TextButton(
                                                      onPressed: () async {
                                                           if (isValidPhoneNumber(phoneNumberController.text)) {
                                                             uid = await AuthService().verifyPhoneNumber(context,_countriesNumber+phoneNumberController.text);
                                                             setState(() {
                                                               (uid ==null)? isPhoneNumberVerified =  false: isPhoneNumberVerified = true;
                                                             });
                                                           }
                                                      },
                                                      child: const Text(
                                                        "Vérifier",
                                                        style: TextStyle(
                                                            color: Colors.red),
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
                            // password
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              obscuringCharacter: '*',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veillez entrer un mot de passe';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
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
                              obscureText: true,
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
                          onPressed: () async{
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              showMessage(context, "Traitement des données");
                              setState(() {
                                isSignupWaiting = true;
                              });
                                _tabController.index == 0
                                    ? await signUpWithEmail(
                                        context,
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                        nomController.text,
                                        prenomController.text,
                                        adresseController.text,
                                        _selectedUserType!,
                                        subject: subject)
                                    : await signUpWithPhoneNumber(
                                        context,
                                        phoneNumberController.text.trim(),
                                        passwordController.text.trim(),
                                        nomController.text,
                                        prenomController.text,
                                        adresseController.text,
                                        _selectedUserType!,
                                        subject: subject);
                                setState((){});
                                if (_appUser != null) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>  AppUI(appUser: _appUser!,),
                                  ));
                                }else{
                                  setState(() {
                                    isSignupWaiting = false;
                                  });
                                }

                            } else if (!agreePersonalData) {
                              showMessage(context,
                                  "Veillez accepter la collecte de donnée personnelle");
                            }
                          },
                          child: isSignupWaiting? const CircularProgressIndicator(): const Text('S\'inscrire'),
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
                          if(uid!=null){
                            final isSignin = await AuthService().isGoogleUserExist(uid!);
                            if(isSignin){
                              user = await AuthService().getUserById(uid!);
                            }
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => isSignin? AppUI(appUser: user!): GoogleSignUp(uid:uid!),
                            ));
                          }else{
                            showMessage(context, "Une erreur s'est produite lors de l'authentification avec google");
                         setState(() {
                           isGoogleCliked = false;
                         });
                          }
                          },
                        child: Center(
                          child: isGoogleCliked? const CircularProgressIndicator(): Image.asset(
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


  void addSubject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
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
                ),
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
                          Navigator.of(context).pop();
                          setState(() {
                            subject?.add(subjectController.text);
                            subjectController.clear();
                          });
                        },
                        child: const Text("Ajouter"))
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final TextEditingController subjectController = TextEditingController();

  Future<void> signUpWithEmail(BuildContext context, String email, String password,
      String firstName, String lastName, String address, String userType,
      {List<String>? subject}) async {
    setState(() async {
      _appUser = await AuthService().registerWithEmail(
          context, email, password, firstName, lastName, address, userType, subject: subject);
    });
  }

  bool isPhoneNumberVerified = false;

  Future<void> signUpWithPhoneNumber(
      BuildContext context,
      String phone,
      String password,
      String firstName,
      String lastName,
      String address,
      String userType,
      {List<String>? subject}) async {
    setState(() async {
      _appUser = await AuthService().registerWithPhone(
          context,uid!, phone, password, firstName, lastName, address, userType, subject: subject);
    });
  }
}
