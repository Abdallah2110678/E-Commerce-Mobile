import 'dart:convert';
import 'package:http/http.dart' as http;

class PayPalService {
  final String clientId =
      "AX_iKrdA5OeQSM5XwJBJfdaPFTL3c_oASY8qQj5LEOX8-qLG5uHvvxZvCVC5LPIwKFKpEy-92HzQAVrG";
  final String secret =
      "EGuUPPdRj6FEsx5_YzHMKYlrvI6TUa6Fy3eT38MstK7zhr-GBSZE-la2leQNukyovRol2XYwZWjRQpYx";
  final String sandboxUrl = "https://api.sandbox.paypal.com";

  Future<String> createPayment(double amount) async {
    try {
      // Get access token
      final tokenResponse = await http.post(
        Uri.parse('$sandboxUrl/v1/oauth2/token'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception("Failed to get access token: ${tokenResponse.body}");
      }

      final tokenData = json.decode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      // Create payment
      final paymentResponse = await http.post(
        Uri.parse('$sandboxUrl/v1/payments/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "intent": "sale",
          "payer": {"payment_method": "paypal"},
          "transactions": [
            {
              "amount": {"total": amount.toStringAsFixed(2), "currency": "USD"},
              "description": "Payment description"
            }
          ],
          "redirect_urls": {
            "return_url": "https://your-return-url.com",
            "cancel_url": "https://your-cancel-url.com"
          }
        }),
      );

      if (paymentResponse.statusCode != 201) {
        throw Exception("Failed to create payment: ${paymentResponse.body}");
      }

      final paymentData = json.decode(paymentResponse.body);

      // Extract approval URL
      final approvalUrl = paymentData['links'].firstWhere(
          (link) => link['rel'] == 'approval_url',
          orElse: () => null);
      if (approvalUrl == null) {
        throw Exception("Approval URL not found in the response");
      }
      return approvalUrl['href'];
    } catch (e) {
      print("Error creating PayPal payment: $e");
      throw e;
    }
  }
}
