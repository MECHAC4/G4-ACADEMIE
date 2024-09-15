import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/constants.dart';
import 'package:g4_academie/cours.dart';
import 'package:g4_academie/profil_class.dart';
import 'package:g4_academie/services/payment/payment_service.dart';
import 'package:g4_academie/services/verification.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';

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

  String? key;

  Future<void> _loadFullPayments() async {
    _requestPayments =
        await PaymentService().getRequestPaymentsFromFirestore(_coursesPath);

    _successFullPayments =
        await PaymentService().getSuccessfulPaymentsFromFirestore(_coursesPath);
    //toBePaidCalculate(_courses);
  }

  Future<void> getKey() async {
    DocumentSnapshot<Map<String, dynamic>> data =
        await FirebaseFirestore.instance.collection('key').doc('api_key').get();
    Map<String, dynamic>? doc = data.data();
    key = doc?['key'];
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
    getKey();
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
                                  child: CircularProgressIndicator());
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
                                  child: CircularProgressIndicator());
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
                            onPressed: () async {
                              await getKey();
                              if (key != null) {
                                if (toBePaid != 0) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return KKiaPay(
                                        countries: const ['BJ'],
                                        amount: toBePaid,
                                        callback: callback1,
                                        apikey: key!,
                                        sandbox: false,
                                        paymentMethods: const ['momo', 'card'],
                                        reason: '$appName paiement',
                                      );
                                    },
                                  ));
                                }
                              } else {
                                showMessage(
                                    context, 'Une erreur s\'est produite');
                              }
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
                    onPressed: () async {
                      if (key != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => KKiaPay(
                            amount: transaction.amount,
                            callback: (response, context) {
                              switch (response['status']) {
                                case PAYMENT_CANCELLED:
                                  setState(() {});
                                  break;

                                case PAYMENT_SUCCESS:
                                  allPaymentSuccessFunction();
                                  break;
                              }
                            },
                            apikey: key!,
                            sandbox: false,
                            paymentMethods: const ['momo', 'card'],
                            countries: const ['BJ'],
                            reason: '$appName paiement',
                          ),
                        ));
                      } else {
                        showMessage(context,
                            'Une erreur s\'est produite; Quittez et revenez sur la page');
                      }
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
  }
}
