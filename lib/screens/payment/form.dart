import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';

import '../../theme/theme.dart';
import '../../widgets/custom_scaffold.dart';

class PaymentForm extends StatefulWidget {
  final int solde;

  const PaymentForm({super.key, required this.solde});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  String? _selectedPaymentMethod;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final List<Map<String, String>> paymentHistory = [];
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
  void initState() {
    // TODO: implement initState
    super.initState();
    //getKey();
  }

  void _addPaymentHistory() async {
    await getKey();
    if (_phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        key != null) {
      setState(() {
        paymentHistory.add({
          'method': _selectedPaymentMethod ?? 'Unknown',
          'phone': _phoneController.text,
          'email': _emailController.text,
          'date': DateTime.now().toString(),
        });
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return KKiaPay(
              amount: widget.solde,
              callback: (p0, p1) {
                print('---${p0.toString()} *****${p1.toString()}');
              },
              apikey: key!,
              sandbox: false,
              email: _emailController.text,
              phone: '229${_phoneController.text}',
              paymentMethods: const ['momo'],
            );
          },
        ));
        _phoneController.clear();
        _emailController.clear();
      });
    } else {
      print('---------------- $key');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return CustomScaffold(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  )),
              const Text(
                'Formulaire de payement',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
          const Text('\n'),
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
                  //const SizedBox(height: 20),

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
            ),
          ),
        ],
      ),
    );
  }
}
