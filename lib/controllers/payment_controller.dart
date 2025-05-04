import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easykhairat/models/paymentModel.dart';

class PaymentController extends GetxController {
  var payments = <PaymentModel>[].obs;
  var totalPayments = 0.0.obs;
  var isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    listenForRealTimeUpdates();
  }

  // Fetch all payments
  Future<void> fetchPayments() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('payments').select();

      final fetchedPayments =
          (response as List<dynamic>)
              .map(
                (json) => PaymentModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      payments.assignAll(fetchedPayments);
    } catch (e) {
      print("Error fetching payments: $e");
      Get.snackbar('Error', 'Failed to fetch payments');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch payments by user ID
  Future<void> fetchPaymentsByUserId(String userId) async {
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User ID is invalid');
      return;
    }

    try {
      isLoading.value = true;
      final response = await supabase
          .from('payments')
          .select()
          .eq('user_id', userId);

      final fetchedPayments =
          (response as List<dynamic>)
              .map(
                (json) => PaymentModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      payments.assignAll(fetchedPayments);
    } catch (e) {
      print("Error fetching payments by user ID: $e");
      Get.snackbar('Error', 'Failed to fetch payments');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new payment
  Future<void> addPayment(PaymentModel payment) async {
    try {
      isLoading.value = true;
      await supabase.from('payments').insert(payment.toJson());
      Get.snackbar('Success', 'Payment added');
    } catch (e) {
      print("Error adding payment: $e");
      Get.snackbar('Error', 'Failed to add payment');
    } finally {
      isLoading.value = false;
    }
  }

  // Update a payment
  Future<void> updatePayment(PaymentModel payment) async {
    try {
      isLoading.value = true;
      await supabase
          .from('payments')
          .update(payment.toJson())
          .eq('payment_id', payment.paymentId ?? 0);

      Get.snackbar('Success', 'Payment updated');
    } catch (e) {
      Get.log("Error updating payment: $e", isError: true);
      Get.snackbar('Error', 'Failed to update payment');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a payment
  Future<void> deletePayment(int paymentId) async {
    try {
      isLoading.value = true;
      await supabase.from('payments').delete().eq('payment_id', paymentId);
      Get.snackbar('Success', 'Payment deleted');
    } catch (e) {
      print("Error deleting payment: $e");
      Get.snackbar('Error', 'Failed to delete payment');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTotalPayments() async {
    final response = await supabase.from('payments').select('payment_value');

    double total = 0.0;
    for (var item in response) {
      total += (item['payment_value'] ?? 0).toDouble();
    }

    totalPayments.value = total;
  }

  // Listen for real-time updates
  void listenForRealTimeUpdates() {
    supabase.from('payments').stream(primaryKey: ['payment_id']).listen((
      List<Map<String, dynamic>> changes,
    ) {
      if (changes.isNotEmpty) {
        fetchPayments();
      }
    });
  }

  // Stream payments by user ID (for real-time updates)
  Stream<List<Map<String, dynamic>>> streamPaymentsByUserId(String userId) {
    return supabase
        .from('payments')
        .stream(primaryKey: ['payment_id'])
        .eq('user_id', userId);
  }
}
