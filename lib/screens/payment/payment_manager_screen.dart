import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:g4_academie/screens/payment/form.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';

import '../../widgets/custom_scaffold.dart';

class PaymentManagerScreen extends StatefulWidget {
  const PaymentManagerScreen({super.key});

  @override
  State<PaymentManagerScreen> createState() => _PaymentManagerScreenState();
}

class _PaymentManagerScreenState extends State<PaymentManagerScreen> {
  // Exemples de données (à remplacer par des données dynamiques)
  final List<Map<String, dynamic>> transactions = [
    {'id': 'TXN001', 'Solde': 100, 'date': '2024-09-01', 'status': 'Payé'},
    {
      'id': 'TXN002',
      'Solde': 150,
      'date': '2024-09-02',
      'status': 'En attente'
    },
    {'id': 'TXN003', 'Solde': 200, 'date': '2024-09-03', 'status': 'Echoué'},
  ];

  String? key;


  Future<void> getKey() async {
    DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('key')
        .doc('api_key')
        .get();
    Map<String, dynamic>? doc = data.data();
    key = doc?['key'];
  }

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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques de Paiement
                    _buildPaymentOverview(),
                    const SizedBox(height: 24.0),

                    // Liste des transactions récentes
                    _buildRecentTransactions(),
                    const SizedBox(height: 24.0),

                    // Historique des transactions
                    _buildTransactionHistory(),
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
            //Text("Doit \n\n\npayer"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatisticTile(
                    title: 'Montant à payer',
                    value: '10000FCFA',
                    color: Colors.redAccent,
                    icon: Icons.assignment_late),
                TextButton(
                    onPressed: () async{
                      await getKey();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return KKiaPay(
                            amount: 1,
                            callback: (p0, p1) {
                              print('---${p0.toString()} *****${p1.toString()}');
                            },
                            apikey: key!,
                            sandbox: false,
                            paymentMethods: const ['momo', 'card'],
                          );
                        },
                      ));
                    },
                    child: const Text(
                      'Procéder au payement',
                      style: TextStyle(),
                    )),
              ],
            ),
            //const Text('\n'),
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticTile(
                  title: 'Total payé',
                  value: '\$450',
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
                _buildStatisticTile(
                  title: 'En attente',
                  value: '\$150',
                  color: Colors.orange,
                  icon: Icons.hourglass_empty,
                ),
                _buildStatisticTile(
                  title: 'Echoué',
                  value: '\$200',
                  color: Colors.red,
                  icon: Icons.cancel_outlined,
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

  // Transactions récentes
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Récents Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionItem(transaction);
          },
        ),
      ],
    );
  }

  // Historique des transactions
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionItem(transaction);
          },
        ),
      ],
    );
  }

  // Item de transaction unique
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    Color statusColor;
    switch (transaction['status']) {
      case 'Payé':
        statusColor = Colors.green;
        break;
      case 'En attente':
        statusColor = Colors.orange;
        break;
      case 'Echoué':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.2),
        child: Icon(
          transaction['status'] == 'Payé'
              ? Icons.check_circle
              : (transaction['status'] == 'En attente'
                  ? Icons.hourglass_empty
                  : Icons.cancel),
          color: statusColor,
        ),
      ),
      title: Text(
        'Transaction ID: ${transaction['id']}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Date: ${transaction['date']}\nSolde: \$${transaction['Solde']}',
      ),
      trailing: Text(
        transaction['status'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }
}
