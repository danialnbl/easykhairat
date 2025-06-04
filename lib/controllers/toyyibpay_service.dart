import 'dart:convert';
import 'package:http/http.dart' as http;

class ToyyibPayService {
  final String apiKey =
      '1y7d1m73-9e3t-tl5d-0i2y-epv6q1zposog'; // Your ToyyibPay secret key
  final String baseUrl = 'https://dev.toyyibpay.com/';

  /// Creates a new bill in ToyyibPay
  Future<String?> createBill({
    required String billTitle,
    required String billDescription,
    required String billAmount,
    required String userEmail,
    required String userPhone,
    required String categoryCode,
    String returnUrl = 'easykhairat://payment-status',
    String callbackUrl = 'https://example.com/callback',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}index.php/api/createBill'),
        body: {
          'userSecretKey': apiKey,
          'categoryCode': categoryCode,
          'billName': billTitle,
          'billDescription': billDescription,
          'billPriceSetting': '1',
          'billPayorInfo': '1',
          'billAmount': billAmount,
          'billReturnUrl': returnUrl,
          'billCallbackUrl': callbackUrl,
          'billTo': userEmail,
          'billEmail': userEmail,
          'billPhone': userPhone,
          'billSplitPayment': '0',
          'billSplitPaymentArgs': '',
          'billPaymentChannel': '0', // All payment channels
          'billContentEmail': 'Thank you for your payment!',
          'billChargeToCustomer': '1', // No extra charges to customer
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          // Create bill parameters with billCode in return URL
          final billCode = responseData[0]['BillCode'];

          return billCode; // Return the generated bill code
        } else {
          throw Exception('Invalid response from ToyyibPay API');
        }
      } else {
        throw Exception('Failed to create bill: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error creating bill: $error');
    }
  }

  /// Checks the payment status of a bill
  /// Returns:
  /// - 1: Successful payment
  /// - 2: Pending payment
  /// - 3: Failed payment
  /// - 0: Unknown status/error
  Future<int> getBillPaymentStatus(String billCode) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}index.php/api/getBillTransactions'),
        body: {'userSecretKey': apiKey, 'billCode': billCode},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if we have valid transaction data
        if (responseData is List && responseData.isNotEmpty) {
          // Check if there's any transaction for this bill
          if (responseData.length > 0) {
            // Check the payment status
            if (responseData[0]['billpaymentStatus'] != null) {
              return int.parse(responseData[0]['billpaymentStatus'].toString());
            }
          }
          return 2; // Bill exists but no transaction yet (pending)
        }
        return 0; // No data found
      } else {
        print(
          'Error checking bill status: ${response.statusCode}, ${response.body}',
        );
        return 0; // Error status
      }
    } catch (error) {
      print('Exception checking payment status: $error');
      return 0; // Error status
    }
  }

  /// Gets the transaction details for a specific bill
  Future<Map<String, dynamic>?> getBillTransactionDetails(
    String billCode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}index.php/api/getBillTransactions'),
        body: {'userSecretKey': apiKey, 'billCode': billCode},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          return responseData[0];
        }
        return null;
      } else {
        print(
          'Error getting transaction details: ${response.statusCode}, ${response.body}',
        );
        return null;
      }
    } catch (error) {
      print('Exception getting transaction details: $error');
      return null;
    }
  }

  /// Gets all available categories
  Future<List<Map<String, dynamic>>?> getCategories() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}index.php/api/getCategories'),
        body: {'userSecretKey': apiKey},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return null;
      } else {
        print(
          'Error getting categories: ${response.statusCode}, ${response.body}',
        );
        return null;
      }
    } catch (error) {
      print('Exception getting categories: $error');
      return null;
    }
  }
}
