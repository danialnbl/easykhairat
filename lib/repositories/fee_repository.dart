import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feeModel.dart';

class FeeRepository {
  final SupabaseClient _supabaseClient;

  FeeRepository(this._supabaseClient);

  Future<List<FeeModel>> getAllFees() async {
    try {
      final data = await _supabaseClient.from('fee').select();

      return (data as List<dynamic>)
          .map((json) => FeeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch fees: $e');
    }
  }

  Future<List<FeeModel>> getFeesByUserId(String userId) async {
    try {
      final data = await _supabaseClient
          .from('fee')
          .select()
          .eq('user_id', userId);

      return (data as List<dynamic>)
          .map((json) => FeeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch fees for user: $e');
    }
  }

  // Add a fee
  Future<void> addFee(FeeModel fee) async {
    try {
      await _supabaseClient.from('fee').insert(fee.toJson());
    } catch (e) {
      throw Exception('Failed to add fee: $e');
    }
  }

  // Update a fee
  Future<void> updateFee(FeeModel fee) async {
    try {
      await _supabaseClient
          .from('fee')
          .update(fee.toJson())
          .eq('fee_id', fee.feeId);
    } catch (e) {
      throw Exception('Failed to update fee: $e');
    }
  }

  // Delete a fee
  Future<void> deleteFee(int feeId) async {
    try {
      await _supabaseClient.from('fee').delete().eq('fee_id', feeId);
    } catch (e) {
      throw Exception('Failed to delete fee: $e');
    }
  }
}
