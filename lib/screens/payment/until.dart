import 'dart:convert';
import 'package:http/http.dart' as http;

class FedaPayService {
  final String publicKey = 'pk_live_jdEJfljCDsBUoYFLU_xwtXQl';
  final String secretKey = 'sk_live_zBeqoVOX4VCLspERnZ-WadaY';
  final String baseUrl = 'https://sandbox-api.fedapay.com/v1';//'https://sandbox-api.fedapay.com/v1'; // Change to 'https://api.fedapay.com/v1' for production

  Future<Map<String, dynamic>> createTransaction(double amount, Map<String,String> currency, String customerName, String customerEmail) async {
    final url = '$baseUrl/transactions';
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "description" : "Transaction for john.doe@example.com",
      "amount" : 200,
      "currency" : {"iso" : "XOF"},
      "customer" : {
        "firstname" : "José",
        "lastname" : "ADJOVI",
        "email" : "josesecurise@gmail.com",
        "phone_number" : {
          "number" : "+22953225324",
          "country" : "bj"
        }
      }
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 201) {
      return json.decode(response.body)['data'];
    } else {
      print("***************${response.headers}");
      throw Exception('Failed to create transaction: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> processPayment(String transactionId) async {
    final url = '$baseUrl/transactions/$transactionId/charge';
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };

    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to process payment: ${response.body}');
    }
  }
}
