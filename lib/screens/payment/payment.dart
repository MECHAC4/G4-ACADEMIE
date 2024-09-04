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
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return CustomScaffold(
        child: Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  const Text(
                    "Statut de paiement",
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: width / 25,
                  ),
                ],
              )),
          TextButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Historique de paiement",
                  style: TextStyle(color: Colors.white),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: width / 25,
                )
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
              padding: EdgeInsets.symmetric(
                  horizontal: width / 35, vertical: width / 35),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: const Center(child: Text("Loading..."))))
    ]));
  }
}
