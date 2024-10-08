import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text;
import 'package:g4_academie/theme/theme.dart';

bool isValidEmail(String email) {
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegExp.hasMatch(email);
}


bool isValidPhoneNumber(String phoneNumber) {
  final RegExp phoneRegExp = RegExp(
    r'^\d{8,14}$',
  );
  return phoneRegExp.hasMatch(phoneNumber);
}

bool isValidAddress(String address) {
  final RegExp addressRegExp = RegExp(
    r'^[a-zA-Z]+,[a-zA-Z]+$',
  );
  return addressRegExp.hasMatch(address);
}


void showMessage(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
      content: Text(message),
       showCloseIcon: true,
       closeIconColor: lightColorScheme.surface,
    ),
  );
}

