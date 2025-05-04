import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:get/get.dart';

class MaklumatAhli extends StatefulWidget {
  const MaklumatAhli({super.key});

  @override
  MaklumatAhliState createState() => MaklumatAhliState();
}

class MaklumatAhliState extends State<MaklumatAhli> {
  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    final member = navController.getUser();

    return Scaffold(
      backgroundColor: MoonColors.light.gohan,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(title: "Maklumat Ahli", notificationCount: 3),
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
                        MoonBreadcrumbItem(label: Text("Ahli")),
                        MoonBreadcrumbItem(label: Text("Maklumat Ahli")),
                        MoonBreadcrumbItem(
                          label: Text(member?.userName ?? "Unknown User"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Card(
                        color: MoonColors.light.goku,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Maklumat Ahli ${member?.userName ?? "Unknown User"}",
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              if (member == null)
                                Text("Tiada maklumat ahli tersedia.")
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "No. Ahli",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Nama",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "No. Kad Pengenalan",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Alamat",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "No. Telefon",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Email",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Status Keahlian",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.userId != null
                                                ? member.userId!.substring(0, 8)
                                                : "Unknown ID",
                                          ),
                                          const SizedBox(height: 8),
                                          Text(member.userName),
                                          const SizedBox(height: 8),
                                          Text(member.userIdentification),
                                          const SizedBox(height: 8),
                                          Text(member.userAddress),
                                          const SizedBox(height: 8),
                                          Text(member.userPhoneNo),
                                          const SizedBox(height: 8),
                                          Text(member.userEmail),
                                          const SizedBox(height: 8),
                                          Text(member.userType),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        color: MoonColors.light.goku,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                "Tanggungan",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Table(
                                border: TableBorder.all(),
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "No.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Nama",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "IC/SuratBeranak",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Pertalian",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("1"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Ali Bin Abu"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("900101-01-1234"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Anak"),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("2"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Aminah Binti Ali"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("910202-02-5678"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Isteri"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
