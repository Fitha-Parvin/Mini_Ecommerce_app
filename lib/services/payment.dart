import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static Future<void> makePayment(int amount, {required String method}) async {
    try {
      // Call your backend to get the PaymentIntent client secret
      final response = await http.post(
        Uri.parse('https://your-server.com/create-payment-intent'),
        body: {'amount': (amount * 100).toString(), 'currency': 'usd'},
      );

      final jsonResponse = jsonDecode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "E-commerce App",
        ),
      );

      // Display payment sheet
      await Stripe.instance.presentPaymentSheet();
      print("Payment successful!");
    } catch (e) {
      print("Payment failed: $e");
    }
  }
}
