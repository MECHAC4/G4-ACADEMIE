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

class PaymentManagerScreen extends StatefulWidget {
  final AppUser appUser;

  const PaymentManagerScreen({super.key, required this.appUser});

  @override
  State<PaymentManagerScreen> createState() => _PaymentManagerScreenState();
}

class _PaymentManagerScreenState extends State<PaymentManagerScreen> {


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
        ProfilClass.fromMap(profilList[i].data() as Map<String, dynamic>, profilList[i].id);
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
                element.data() as Map<String, dynamic>, element.id, element.reference.path));
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
              element.data() as Map<String, dynamic>, element.id, element.reference.path));
          _coursesPath
              .add('${widget.appUser.id}/${widget.appUser.id}/${element.id}');
        });
      }
    }
    await _loadFullPayments();

      toBePaidCalculate(_courses);

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
    final width = MediaQuery
        .of(context)
        .size
        .width;
    return CustomScaffold(
      child: Column(
        children: [
          const Text(
            'Gestionnaire de paiement',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          Padding(
            padding:
            EdgeInsets.only(top: MediaQuery
                .of(context)
                .size
                .height / 30),
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
                    ExpansionTile(initiallyExpanded: true,title: Text(
                      'Détails de la facturation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.grey[800],
                      ),
                    ),children: [
                      FutureBuilder(future: _loadFullPayments(), builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child:  Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }else{
                          return Column(
                            children: _buildRequestPayments(),
                          );
                        }
                      },),
                    ],),

                    ExpansionTile(initiallyExpanded: true,title:Text(
                      'Historique des transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.grey[800],
                      ),
                    ), children: [
                      FutureBuilder(future: _loadFullPayments(), builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child:  Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(),
                          ));
                        }else{
                          return Column(
                            children: _buildTransactionHistory(),
                          );
                        }
                      },)
                    ],)



                    // Statistiques de Paiementconst SizedBox(height: 24.0),

                   // Historique des transactions
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
                    title: 'Montant à payer',
                    value: '${toBePaid}FCFA',
                    color: toBePaid != 0 ? Colors.redAccent : Colors.green,
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
                            child: const Text('Historique de paiement')),
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
                              'Procéder au payement',
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
    return _successFullPayments.isEmpty? const[
     Center(
      child: Text(
        'Aucune transaction',
        textAlign: TextAlign.center,
      ),
    )
    ]: _successFullPayments.map((e) {
      final transaction = e;
      return _buildTransactionItem(transaction);
    },).toList();

  }

  List<Widget> _buildRequestPayments() {
     return _requestPayments.isEmpty? const [Center(
       child: Text(
         'Aucune facturation',
         textAlign: TextAlign.center,
       ),
     )]: _requestPayments.map(
       (e) {
         Payment transaction = e;
         return ListTile(
           leading: const Icon(
             Icons.close,
             color: Colors.red,
           ),
           title: Text(
             'Paiement de ${transaction.course} de ${transaction
                 .monthOfTransaction} de (${transaction.fullName})',
             style: const TextStyle(fontWeight: FontWeight.w600),
           ),
           subtitle: Text('Solde: ${transaction.amount}FCFA'),
           trailing: TextButton(
               onPressed: () async {
                 if (key != null) {
                   Navigator.of(context).push(MaterialPageRoute(
                     builder: (context) =>
                         KKiaPay(
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
                   showMessage(context, 'Une erreur s\'est produite; Quittez et revenez sur la page');
                 }
               },
               child: const Text('Payer')),
         );
       },
     ).toList();
    /*return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_requestPayments.isEmpty)
          const Center(
            child: Text(
              'Aucune facturation',
              textAlign: TextAlign.center,
            ),
          ),
        if (_requestPayments.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            itemCount: _requestPayments.length,
            itemBuilder: (context, index) {
              Payment transaction = _requestPayments[index];
              return ListTile(
                leading: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                title: Text(
                  'Paiement de ${transaction.course} de ${transaction
                      .monthOfTransaction} de (${transaction.fullName})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Solde: ${transaction.amount}'),
                trailing: TextButton(
                    onPressed: () async {
                      if (key != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              KKiaPay(
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
                        showMessage(context, 'Une erreur s\'est produite; Quittez et revenez sur la page');
                      }
                    },
                    child: const Text('Payer')),
              );
            },
          ),
      ],
    );*/
  }

  //List<Map<String, dynamic>> paymentAndCourse = [];

  // Item de transaction unique
  Widget _buildTransactionItem(Payment transaction) {
    Color statusColor = Colors.green;
    DateTime dt = transaction.transactionDateTime;

    return ListTile(
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
    );
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

