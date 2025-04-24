import '../models/feeModel.dart';
import '../repositories/fee_repository.dart';

class FeeController {
  final FeeRepository _feeRepository;

  FeeController(this._feeRepository);

  Future<List<FeeModel>> getAllFees() async {
    return await _feeRepository.getAllFees();
  }

  Future<List<FeeModel>> getFeesByUserId(String userId) async {
    return await _feeRepository.getFeesByUserId(userId);
  }

  Future<void> addFee({
    required String description,
    required DateTime dueDate,
    required String feeType,
    required int adminId,
    required String userId,
  }) async {
    final now = DateTime.now();

    final newFee = FeeModel(
      feeId: 0, // This will be assigned by Supabase if it's auto-incrementing
      feeDescription: description,
      feeDue: dueDate,
      feeType: feeType,
      feeCreatedAt: now,
      feeUpdatedAt: now,
      adminId: adminId,
      userId: userId,
    );

    await _feeRepository.addFee(newFee);
  }

  Future<void> updateFee(FeeModel fee) async {
    // Update the updatedAt timestamp
    final updatedFee = FeeModel(
      feeId: fee.feeId,
      feeDescription: fee.feeDescription,
      feeDue: fee.feeDue,
      feeType: fee.feeType,
      feeCreatedAt: fee.feeCreatedAt,
      feeUpdatedAt: DateTime.now(),
      adminId: fee.adminId,
      userId: fee.userId,
    );

    await _feeRepository.updateFee(updatedFee);
  }

  Future<void> deleteFee(int feeId) async {
    await _feeRepository.deleteFee(feeId);
  }
}
