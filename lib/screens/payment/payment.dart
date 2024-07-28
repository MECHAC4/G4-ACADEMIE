//import 'package:flutter/material.dart';
//import 'package:g4_academie/screens/payment/until.dart';

/*class Payement extends StatelessWidget {
  final FedaPayService fedapayService = FedaPayService();

  Payement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Paiement'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // Step 1: Create a transaction
              final transaction = await fedapayService.createTransaction(10.0,
                  {"iso": "XOF"}, 'José ADJOVI', 'joseadjovi67@gmail.com');
              print('Transaction created: $transaction');
              // Step 2: Process the payment
              final payment =
                  await fedapayService.processPayment(transaction['id']);
              print('Payment processed: $payment');
            } catch (e) {
              print('***************Error:************ ${e}e}');
            }
          },
          child: const Text('Paiement'),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/widgets/custom_scaffold.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
//_PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final List<Map<String, String>> paymentHistory = [];

  void _addPaymentHistory() {
    if (_phoneController.text.isNotEmpty && _emailController.text.isNotEmpty) {
      setState(() {
        paymentHistory.add({
          'method': _selectedPaymentMethod ?? 'Unknown',
          'phone': _phoneController.text,
          'email': _emailController.text,
          'date': DateTime.now().toString(),
        });
        _phoneController.clear();
        _emailController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return CustomScaffold(
        child: Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(onPressed: (){}, child: Row(
            children: [
              const Text("Statut de paiement", style: TextStyle(color: Colors.white),),
              Icon(Icons.arrow_forward_ios,color: Colors.white,size: width/25,),
            ],
          )),
          TextButton(
                  onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return CustomScaffold(
                child: Expanded(
                  child: ListView.builder(
                    itemCount: paymentHistory.length,
                    itemBuilder: (context, index) {
                      final payment = paymentHistory[index];
                      return ListTile(
                        title:
                            Text('${payment['method']} - ${payment['phone']}'),
                        subtitle:
                            Text('${payment['email']} - ${payment['date']}'),
                      );
                    },
                  ),
                ),
              );
            },
          ));
                  },
                  child:  Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Historique de paiement",
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white,size: width/25,)
          ],
                  ),
                ),
        ],
      ),
      Text(
        'Page de Paiement',
        style: TextStyle(
            color: lightColorScheme.surface,
            fontWeight: FontWeight.w900,
            fontSize: width / 15),
      ),
      Padding(padding: EdgeInsets.only(top: width / 30)),
      Expanded(
          child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: width / 35, vertical: width / 35),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
          ),
        ),
        child: ListView(
          children: [
            const Text(
              'Choisissez votre méthode de paiement',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Table(
              children: [
                TableRow(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedPaymentMethod = 'MTN MoMo';
                      }),
                      child: Column(
                        children: [
                          Image.asset('lib/Assets/mtn_momo.jpg',
                              width: width / 8),
                          RadioListTile(
                            title: const Text("MTN MoMo"),
                            value: 'MTN MoMo',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedPaymentMethod = 'Moov Money';
                      }),
                      child: Column(
                        children: [
                          Image.asset('lib/Assets/moov_money.jpg',
                              width: width / 8),
                          RadioListTile(
                            title: const Text("Moov Money"),
                            value: 'Moov Money',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Adresse email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPaymentHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: lightColorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text('Valider le paiement'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ))
    ]));
  }
}
