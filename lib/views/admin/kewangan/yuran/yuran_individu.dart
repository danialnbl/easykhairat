import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/payment_controller.dart';
import 'package:easykhairat/models/paymentModel.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';

class YuranIndividu extends StatefulWidget {
  const YuranIndividu({super.key});

  @override
  YuranIndividuState createState() => YuranIndividuState();
}

class YuranIndividuState extends State<YuranIndividu> {
  final FeeController feeController = Get.put(FeeController());
  final NavigationController navController = Get.put(NavigationController());
  final PaymentController paymentController = Get.put(PaymentController());

  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Form controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController receiptController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Form state
  String paymentMethod = "Tunai";
  String? selectedInvoice;
  int currentStep = 0;
  final RxBool isSubmitting = false.obs;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Auto-fill today's date
    selectedDate = DateTime.now();
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Auto-fill amount when fee is selected
  void _onFeeSelected(String? feeId) {
    setState(() {
      selectedInvoice = feeId;
      if (feeId != null) {
        final selectedFee = feeController.yuranTertunggak.firstWhere(
          (fee) => fee.feeId.toString() == feeId,
        );
        amountController.text = selectedFee.feeAmount.toStringAsFixed(2);
      } else {
        amountController.clear();
      }
    });
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepItem(0, "Pilih Yuran", Icons.list_alt),
          _buildStepConnector(currentStep > 0),
          _buildStepItem(1, "Maklumat Bayaran", Icons.payment),
          _buildStepConnector(currentStep > 1),
          _buildStepItem(2, "Pengesahan", Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    bool isActive = currentStep >= step;
    bool isCurrent = currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey.shade300,
              shape: BoxShape.circle,
              border:
                  isCurrent ? Border.all(color: Colors.blue, width: 3) : null,
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted) {
    return Container(
      height: 2,
      width: 40,
      color: isCompleted ? Colors.blue : Colors.grey.shade300,
    );
  }

  Widget _buildStep1() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Yuran untuk: ${navController.getUser()?.userName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Pilih yuran yang ingin dibayar:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (feeController.yuranTertunggak.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Tiada Yuran Tertunggak",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Semua yuran telah dijelaskan!",
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children:
                    feeController.yuranTertunggak.map((fee) {
                      bool isSelected = selectedInvoice == fee.feeId.toString();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          color:
                              isSelected ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Radio<String>(
                            value: fee.feeId.toString(),
                            groupValue: selectedInvoice,
                            onChanged: _onFeeSelected,
                          ),
                          title: Text(
                            fee.feeDescription,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? Colors.blue.shade700
                                      : Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "Tarikh Terbuat: ${formatDate(fee.feeCreatedAt)}",
                              ),
                              Text("Tarikh Akhir: ${formatDate(fee.feeDue)}"),
                              if (fee.feeDue.isBefore(DateTime.now()))
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "LEWAT TEMPOH",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "RM ${fee.feeAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          onTap: () => _onFeeSelected(fee.feeId.toString()),
                        ),
                      );
                    }).toList(),
              );
            }),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed:
                      selectedInvoice != null
                          ? () {
                            setState(() {
                              currentStep = 1;
                            });
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Seterusnya"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payment, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    "Maklumat Bayaran",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount field with better formatting
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: "Jumlah Bayaran (RM)",
                  prefixText: "RM ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calculate),
                    onPressed: () {
                      if (selectedInvoice != null) {
                        final selectedFee = feeController.yuranTertunggak
                            .firstWhere(
                              (fee) => fee.feeId.toString() == selectedInvoice,
                            );
                        amountController.text = selectedFee.feeAmount
                            .toStringAsFixed(2);
                      }
                    },
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila isi jumlah bayaran';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Jumlah tidak sah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date picker with better UX
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Tarikh Bayaran",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      dateController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(picked);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila pilih tarikh bayaran';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment method with better design
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: InputDecoration(
                  labelText: "Kaedah Pembayaran",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                items: const [
                  DropdownMenuItem(value: "Tunai", child: Text("💵 Tunai")),
                  DropdownMenuItem(
                    value: "Bank Transfer",
                    child: Text("🏦 Pindahan Bank"),
                  ),
                  DropdownMenuItem(value: "Cek", child: Text("📋 Cek")),
                  DropdownMenuItem(
                    value: "Lain-lain",
                    child: Text("📄 Lain-lain"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Receipt number
              TextFormField(
                controller: receiptController,
                decoration: InputDecoration(
                  labelText: "Nombor Resit (Pilihan)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.receipt),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Nota Tambahan (Pilihan)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentStep = 0;
                      });
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Kembali"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          currentStep = 2;
                        });
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Seterusnya"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final selectedFee = feeController.yuranTertunggak.firstWhereOrNull(
      (fee) => fee.feeId.toString() == selectedInvoice,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "Pengesahan Bayaran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  _buildConfirmationRow(
                    "Ahli",
                    navController.getUser()?.userName ?? "",
                  ),
                  const Divider(),
                  _buildConfirmationRow(
                    "Yuran",
                    selectedFee?.feeDescription ?? "",
                  ),
                  const Divider(),
                  _buildConfirmationRow(
                    "Jumlah",
                    "RM ${amountController.text}",
                  ),
                  const Divider(),
                  _buildConfirmationRow("Tarikh", dateController.text),
                  const Divider(),
                  _buildConfirmationRow("Kaedah", paymentMethod),
                  if (receiptController.text.isNotEmpty) ...[
                    const Divider(),
                    _buildConfirmationRow("No. Resit", receiptController.text),
                  ],
                  if (noteController.text.isNotEmpty) ...[
                    const Divider(),
                    _buildConfirmationRow("Nota", noteController.text),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Sila semak maklumat di atas sebelum meneruskan. Bayaran yang telah dibuat tidak boleh dibatalkan.",
                      style: TextStyle(color: Colors.amber.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Final buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      currentStep = 1;
                    });
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Kembali"),
                ),
                Obx(
                  () => ElevatedButton(
                    onPressed: isSubmitting.value ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child:
                        isSubmitting.value
                            ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text("Memproses..."),
                              ],
                            )
                            : const Text("Sahkan Bayaran"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPayment() async {
    isSubmitting.value = true;

    try {
      final payment = PaymentModel(
        paymentValue: double.parse(amountController.text),
        paymentDescription:
            noteController.text.isEmpty ? "Bayaran Yuran" : noteController.text,
        paymentCreatedAt: DateTime.now(),
        paymentUpdatedAt: DateTime.now(),
        feeId: int.parse(selectedInvoice ?? '0'),
        userId: navController.getUser()?.userId,
        paymentType: paymentMethod,
      );

      await paymentController.addPayment(payment);

      // Clear form
      _formKey.currentState?.reset();
      amountController.clear();
      dateController.clear();
      receiptController.clear();
      noteController.clear();
      setState(() {
        selectedInvoice = null;
        paymentMethod = "Tunai";
        currentStep = 0;
      });

      // Refresh data
      await feeController.fetchYuranTertunggak(
        navController.getUser()?.userId.toString() ?? "",
      );

      // Navigate back to first step
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );

      // Show success message
      Get.snackbar(
        'Berjaya!',
        'Bayaran telah berjaya disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } catch (error) {
      Get.snackbar(
        'Ralat!',
        'Gagal menyimpan bayaran: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(title: "Bayaran Yuran", notificationCount: 3),
              const SizedBox(height: 16),

              // Breadcrumb (same as before)
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: MoonColors.light.goku,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MoonBreadcrumb(
                      visibleItemCount: 5,
                      items: [
                        MoonBreadcrumbItem(
                          label: const Text("Home"),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(label: const Text("Kewangan")),
                        MoonBreadcrumbItem(
                          label: const Text("Proses Yuran"),
                          onTap: () => navController.selectedIndex.value = 4,
                        ),
                        MoonBreadcrumbItem(label: const Text("Yuran Individu")),
                        MoonBreadcrumbItem(
                          label: Text("${navController.getUser()?.userName}"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step indicator
              Card(
                color: MoonColors.light.goku,
                elevation: 4,
                child: _buildStepIndicator(),
              ),
              const SizedBox(height: 16),

              // Main content with stepper
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form section
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 600,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [_buildStep1(), _buildStep2(), _buildStep3()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Transaction history (enhanced)
                  Expanded(
                    flex: 3,
                    child: Card(
                      color: MoonColors.light.goku,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  "Transaksi Akaun",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Outstanding fees with better design
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pending_actions,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Yuran Tertunggak",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            Obx(() {
                              if (feeController.yuranTertunggak.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Tiada yuran tertunggak!",
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      feeController.yuranTertunggak.length,
                                  itemBuilder: (context, index) {
                                    final fee =
                                        feeController.yuranTertunggak[index];
                                    bool isOverdue = fee.feeDue.isBefore(
                                      DateTime.now(),
                                    );

                                    return Container(
                                      decoration: BoxDecoration(
                                        border:
                                            index > 0
                                                ? Border(
                                                  top: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                )
                                                : null,
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              isOverdue
                                                  ? Colors.red.shade100
                                                  : Colors.orange.shade100,
                                          child: Text(
                                            "${index + 1}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isOverdue
                                                      ? Colors.red.shade700
                                                      : Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          fee.feeDescription,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          formatDate(fee.feeCreatedAt),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "RM ${fee.feeAmount.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (isOverdue)
                                              Text(
                                                "LEWAT",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),

                            const SizedBox(height: 16),

                            // Payment history with better design
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Sejarah Bayaran",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            Obx(() {
                              if (paymentController.payments.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text("Tiada sejarah bayaran"),
                                  ),
                                );
                              }

                              return Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: paymentController.payments.length,
                                  itemBuilder: (context, index) {
                                    final payment =
                                        paymentController.payments[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        border:
                                            index > 0
                                                ? Border(
                                                  top: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                )
                                                : null,
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              Colors.green.shade100,
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        title: Text(
                                          payment.paymentDescription != null
                                              ? payment.paymentDescription!
                                              : "Bayaran",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          formatDate(payment.paymentCreatedAt),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        trailing: Text(
                                          "RM ${payment.paymentValue.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    amountController.dispose();
    dateController.dispose();
    receiptController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
