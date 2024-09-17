import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/cours.dart';
import 'package:g4_academie/profil_class.dart';
import 'package:g4_academie/services/payment/payment_service.dart';
import 'package:g4_academie/services/verification.dart';

import '../../payment.dart';
import '../../users.dart';
import '../../widgets/custom_scaffold.dart';

class TeacherPaymentManager extends StatefulWidget {
  final AppUser appUser;

  const TeacherPaymentManager({super.key, required this.appUser});

  @override
  State<TeacherPaymentManager> createState() => _TeacherPaymentManagerState();
}

class _TeacherPaymentManagerState extends State<TeacherPaymentManager> {
  List<Payment> _successFullPayments = [];
  List<Payment> _requestPayments = [];

  Future<void> _loadFullPayments() async {
    _requestPayments =
        await PaymentService().getRequestPaymentsFromFirestore(_coursesPath);

    _successFullPayments =
        await PaymentService().getSuccessfulPaymentsFromFirestore(_coursesPath);
    //toBePaidCalculate(_courses);
  }

  final List<Cours> _courses = [];
  final List<String> _coursesPath = [];

  Future<void> getCoursesList() async {
    if (widget.appUser.userType == 'Parent d\'élève') {
      QuerySnapshot profilesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.appUser.id)
          .collection('profil')
          .get();
      final profilList = profilesSnapshot.docs;

      for (int i = 0; i < profilList.length; i++) {
        ProfilClass profil =
            ProfilClass.fromMap(profilList[i].data() as Map<String, dynamic>);
        QuerySnapshot coursesForProfilSnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(widget.appUser.id)
            .collection('profil')
            .doc(profil.id)
            .collection('courses')
            .where('state', whereIn: ['Traité', 'Actif']).get();
        final coursesProfilList = coursesForProfilSnapshot.docs;

        for (var element in coursesProfilList) {
          setState(() {
            _courses.add(Cours.fromMap(
                element.data() as Map<String, dynamic>, element.id));
            _coursesPath.add('${widget.appUser.id}/${profil.id}/${element.id}');
          });
        }
      }
    } else {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.appUser.id)
          .collection('profil')
          .doc(widget.appUser.id)
          .collection('courses')
          .where('state', whereIn: ['Traité', 'Actif']).get();
      final docList = snapshot.docs;
      for (var element in docList) {
        setState(() {
          _courses.add(Cours.fromMap(
              element.data() as Map<String, dynamic>, element.id));
          _coursesPath
              .add('${widget.appUser.id}/${widget.appUser.id}/${element.id}');
        });
      }
    }
    await _loadFullPayments();
    setState(() {
      toBePaidCalculate(_courses);
    });
  }

  void loadCourses() async {
    await getCoursesList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCourses();
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  int toBePaid = 0;

  void toBePaidCalculate(List<Cours> courses) {
    int p = 0;
    if (_requestPayments.isNotEmpty) {
      for (int i = 0; i < _requestPayments.length; i++) {
        p = p + _requestPayments[i].amount;
      }
    }
    setState(() {
      toBePaid = p;
    });
  }

  bool isFacturationExpanded = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return CustomScaffold(
      child: Column(
        children: [
          const Text(
            'Gestionnaire de paiement',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 30),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: width / 35, vertical: width / 35),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentOverview(),
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Détails des revenus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.grey[800],
                        ),
                      ),
                      children: [
                        FutureBuilder(
                          future: _loadFullPayments(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircularProgressIndicator(),
                              ));
                            } else {
                              return Column(
                                children: _buildRequestPayments(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Historique des transactions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.grey[800],
                        ),
                      ),
                      children: [
                        FutureBuilder(
                          future: _loadFullPayments(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircularProgressIndicator(),
                              ));
                            } else {
                              return Column(
                                children: _buildTransactionHistory(),
                              );
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aperçu des statistiques de paiement
  Widget _buildPaymentOverview() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatisticTile(
                    title: 'Votre solde',
                    value: '${toBePaid}FCFA',
                    color: toBePaid == 0 ? Colors.redAccent : Colors.green,
                    icon: Icons.assignment_late),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    decoration:
                        const BoxDecoration(border: Border(left: BorderSide())),
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              _scrollDown();
                            },
                            child: const Text('Historique de retrait')),
                        TextButton(
                            onPressed: () {
                              allPaymentInfoDialog(context, _requestPayments);
                            },
                            child: const Text(
                              'Demander un retrait',
                              style: TextStyle(),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher un tile statistique
  Widget _buildStatisticTile({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36.0),
        const SizedBox(height: 8.0),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: color,
          ),
        ),
      ],
    );
  }

  // Historique des transactions
  List<Widget> _buildTransactionHistory() {
    return _successFullPayments.isEmpty
        ? const [
            Center(
              child: Text(
                'Aucune transaction',
                textAlign: TextAlign.center,
              ),
            )
          ]
        : _successFullPayments.map(
            (e) {
              final transaction = e;
              return _buildTransactionItem(transaction);
            },
          ).toList();
  }

  List<Widget> _buildRequestPayments() {
    return _requestPayments.isEmpty
        ? const [
            Center(
              child: Text(
                'Aucune facturation',
                textAlign: TextAlign.center,
              ),
            )
          ]
        : _requestPayments.map(
            (e) {
              Payment transaction = e;
              print("Affichage de id: ${transaction.id}");
              return ListTile(
                leading: const Icon(
                  Icons.verified_user_sharp,
                  color: Colors.green,
                ),
                title: Text(
                  'Paiement de ${transaction.course} de ${transaction.monthOfTransaction})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Solde: ${transaction.amount}FCFA'),
                trailing: TextButton(
                    onPressed: () {
                      paymentInfoDialog(context, transaction);
                    },
                    child: const Text('Retirer')),
              );
            },
          ).toList();
  }

  Widget _buildTransactionItem(Payment transaction) {
    Color statusColor = Colors.green;
    DateTime dt = transaction.transactionDateTime;

    switch (transaction.state) {
      case 'Echec':
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: const Icon(
              Icons.cancel,
              color: Colors.red,
            ),
          ),
          title: Text(
            'Montant: ${transaction.amount}FCFA',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Date: ${dt.day}/${dt.month}/${dt.year}',
          ),
          trailing: const Text(
            'Rejeté',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        );
      case 'Attente':
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: const Icon(
              Icons.hourglass_bottom,
              color: Colors.orangeAccent,
            ),
          ),
          title: Text(
            'Montant: ${transaction.amount}FCFA',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Date: ${dt.day}/${dt.month}/${dt.year}',
          ),
          trailing: const Text(
            'En attente',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
        );
      case 'Reussite':
        ListTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(
              Icons.check_circle,
              color: statusColor,
            ),
          ),
          title: Text(
            'ID de la transaction: ${transaction.transactionId}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Date: ${dt.day}/${dt.month}/${dt.year}\nSolde: ${transaction.amount}FCFA',
          ),
          trailing: Text(
            'Payé',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        );
    }

    return const Center(
      child: Text("Une erreur s'est produite"),
    ); /*ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.2),
        child: Icon(
          Icons.check_circle,
          color: statusColor,
        ),
      ),
      title: Text(
        'ID de la transaction: ${transaction.transactionId}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Date: ${dt.day}/${dt.month}/${dt.year}\nSolde: ${transaction
            .amount}FCFA',
      ),
      trailing: Text(
        'Payé',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );*/
  }

/*
  void callback1(response, context) {
    switch (response['status']) {
      case PAYMENT_CANCELLED:
        setState(() {});
        break;

      case PAYMENT_SUCCESS:
        allPaymentSuccessFunction();
        break;
    }
  }

  void allPaymentSuccessFunction() {
    for (int i = 0; i < _requestPayments.length; i++) {
      Payment payment = _requestPayments[i];
      paymentSuccessFunction(payment);
    }
  }

  void paymentSuccessFunction(Payment payment) {
    PaymentService().saveSuccessfulPaymentToFirestore(
        payment: payment, coursePath: payment.coursePath);
  }*/

  void paymentInfoDialog(BuildContext context, Payment transaction) {
    String paymentMethod = 'MTN_MOMO';
    TextEditingController phoneNumberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
                child: Column(
                  children: [
                    const Text(
                      "Formulaire de demande de retrait",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline),
                    ),
                    DropdownButton<String>(
                      items: [
                        DropdownMenuItem(
                          value: 'MTN_MOMO',
                          child: const Text('MTN_MOMO'),
                          onTap: () {
                            paymentMethod = 'MTN_MOMO';
                          },
                        ),
                        DropdownMenuItem(
                          value: 'MOOV_MONEY',
                          child: const Text('MOOV_MONEY'),
                          onTap: () {
                            paymentMethod = 'MOOV_MONEY';
                          },
                        ),
                        DropdownMenuItem(
                          value: 'CELTIS_CASH',
                          child: const Text('CELTIS_CASH'),
                          onTap: () {
                            paymentMethod = 'CELTIS_CASH';
                          },
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                      value: paymentMethod,
                    ),
                    TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          label: const Text('Numéro de téléphone'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler')),
                        TextButton(
                            onPressed: () {
                              if (phoneNumberController.text.isNotEmpty) {
                                PaymentService().saveRequestForPayment(
                                    transaction,
                                    paymentMethod,
                                    phoneNumberController.text);
                                Navigator.of(context).pop();
                                showMessage(context,
                                    'Demande de retrait soumis avec succès');
                              } else {
                                showMessage(context,
                                    'Entrez votre numéro de téléphone');
                              }
                            },
                            child: const Text(
                              'Demander un retrait',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void allPaymentInfoDialog(BuildContext context, List<Payment> transactions) {
    String paymentMethod = 'MTN_MOMO';
    TextEditingController phoneNumberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
                child: Column(
                  children: [
                    const Text(
                      "Formulaire de demande de retrait",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline),
                    ),
                    DropdownButton<String>(
                      items: [
                        DropdownMenuItem(
                          value: 'MTN_MOMO',
                          child: const Text('MTN_MOMO'),
                          onTap: () {
                            paymentMethod = 'MTN_MOMO';
                          },
                        ),
                        DropdownMenuItem(
                          value: 'MOOV_MONEY',
                          child: const Text('MOOV_MONEY'),
                          onTap: () {
                            paymentMethod = 'MOOV_MONEY';
                          },
                        ),
                        DropdownMenuItem(
                          value: 'CELTIS_CASH',
                          child: const Text('CELTIS_CASH'),
                          onTap: () {
                            paymentMethod = 'CELTIS_CASH';
                          },
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                      value: paymentMethod,
                    ),
                    TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          label: const Text('Numéro de téléphone'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler')),
                        TextButton(
                            onPressed: () {
                              if (phoneNumberController.text.isNotEmpty) {
                                for (int i = 0; i < transactions.length; i++) {
                                  Payment transaction = transactions[i];
                                  PaymentService().saveRequestForPayment(
                                      transaction,
                                      paymentMethod,
                                      phoneNumberController.text);
                                }
                                Navigator.of(context).pop();
                                showMessage(context,
                                    'Demande de retrait soumis avec succès');
                              } else {
                                showMessage(context,
                                    'Entrez votre numéro de téléphone');
                              }
                            },
                            child: const Text(
                              'Demander un retrait',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
