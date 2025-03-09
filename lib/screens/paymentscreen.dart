import 'package:ecommerce_app/provider/cart.dart';
import 'package:ecommerce_app/services/payment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'Credit Card';

  // Function to handle payment with a confirmation dialog
  void handlePayment(double amount) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Payment"),
          content: Text("Do you want to pay ₹${amount.toStringAsFixed(2)} using $selectedPaymentMethod?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Pay Now"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        switch (selectedPaymentMethod) {
          case 'Credit Card':
            await PaymentService.makePayment(amount.toInt(), method: 'credit_card');
            break;
          case 'PayPal':
            await PaymentService.makePayment(amount.toInt(), method: 'paypal');
            break;
          case 'Google Pay':
            await PaymentService.makePayment(amount.toInt(), method: 'google_pay');
            break;
          default:
            throw "Invalid payment method";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful 🎉")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Failed ❌")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    double totalAmount = cartProvider.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stylish Payment Method Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 10),

                  // Payment Method Selection UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      paymentMethodCard("Credit Card", Icons.credit_card),
                      paymentMethodCard("PayPal", Icons.payment),
                      paymentMethodCard("Google Pay", Icons.account_balance_wallet),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Display Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Pay Now Button
            ElevatedButton(
              onPressed: () => handlePayment(totalAmount),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Proceed to Pay", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Payment Method Selection Card
  Widget paymentMethodCard(String method, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: selectedPaymentMethod == method ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepPurple, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: selectedPaymentMethod == method ? Colors.white : Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              method,
              style: TextStyle(
                color: selectedPaymentMethod == method ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
