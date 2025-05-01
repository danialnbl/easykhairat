import 'package:easykhairat/controllers/fee_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';
import 'package:easykhairat/controllers/user_controller.dart';

class YuranIndividu extends StatefulWidget {
  const YuranIndividu({super.key});

  @override
  YuranIndividuState createState() => YuranIndividuState();
}

class YuranIndividuState extends State<YuranIndividu> {
  final FeeController feeController = Get.put(FeeController());
  final NavigationController navController = Get.put(NavigationController());

  @override
  void initState() {
    super.initState();
  }

  // Fetch fees using userId from NavigationController

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
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: MoonColors.light.goku,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MoonBreadcrumb(
                      items: [
                        MoonBreadcrumbItem(
                          label: Text("Home"),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(label: Text("Kewangan")),
                        MoonBreadcrumbItem(label: Text("Yuran Individu")),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Section: Form
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: MoonColors.light.goku,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Maklumat Yuran Ahli ${navController.getUser()?.userName}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Jumlah (RM)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Tarikh Bayaran",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile(
                                    value: "Tunai",
                                    groupValue: "Tunai",
                                    onChanged: (value) {},
                                    title: Text("Tunai"),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile(
                                    value: "Lain-lain",
                                    groupValue: "Tunai",
                                    onChanged: (value) {},
                                    title: Text("Lain-lain"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Nombor Resit",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Nota Tambahan",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField(
                              items: [
                                DropdownMenuItem(
                                  child: Text("Invois 1"),
                                  value: "1",
                                ),
                                DropdownMenuItem(
                                  child: Text("Invois 2"),
                                  value: "2",
                                ),
                              ],
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                labelText: "Invois",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text("Simpan"),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: Text("Batal"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right Section: Account Transactions
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
                            Text(
                              "Transaksi Akaun",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Text("Yuran Tertunggak"),
                            const SizedBox(height: 8),
                            ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                ListTile(
                                  title: Text("Yuran Tahunan 2020"),
                                  subtitle: Text("29 Feb 20"),
                                  trailing: Text("RM 50.00"),
                                ),
                                ListTile(
                                  title: Text("Yuran Tahunan 2021"),
                                  subtitle: Text("28 Feb 21"),
                                  trailing: Text("RM 200.00"),
                                ),
                                // Add more items here
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text("Transaksi Bayaran dan Tuntutan"),
                            const SizedBox(height: 8),
                            ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                ListTile(
                                  title: Text(
                                    "Tuntutan untuk Ahli yang meninggal",
                                  ),
                                  subtitle: Text("30 Oct 19"),
                                  trailing: Text("RM 1,000.00"),
                                ),
                                ListTile(
                                  title: Text("Bayaran Yuran Ahli"),
                                  subtitle: Text("02 Feb 22"),
                                  trailing: Text("RM 20.00"),
                                ),
                                // Add more items here
                              ],
                            ),
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
}
