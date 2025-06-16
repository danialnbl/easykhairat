import 'package:easykhairat/controllers/family_controller.dart';
import 'package:easykhairat/controllers/navigation_controller.dart';
import 'package:easykhairat/controllers/user_controller.dart';
import 'package:easykhairat/models/familyModel.dart';
import 'package:easykhairat/models/userModel.dart';
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
  final FamilyController familyController = Get.put(FamilyController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noKadPengenalanController =
      TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noTelefonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _statusKeahlianController =
      TextEditingController();

  var isEditing = false;
  var isEditingFamily = false;

  @override
  void initState() {
    super.initState();
    final member = navController.getUser();
    if (member != null && member.userId != null) {
      familyController.fetchFamilyMembersByUserId(member.userId!);
    }
  }

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
                      visibleItemCount: 5,
                      items: [
                        MoonBreadcrumbItem(
                          label: Text("Home"),
                          onTap: () => Get.toNamed('/adminMain'),
                        ),
                        MoonBreadcrumbItem(label: Text("Ahli")),
                        MoonBreadcrumbItem(
                          label: Text("Senarai Ahli"),
                          onTap: () => navController.selectedIndex.value = 1,
                        ),
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
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (member == null)
                                Text("Tiada maklumat ahli tersedia.")
                              else if (isEditing)
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller:
                                            _namaController
                                              ..text = member?.userName ?? '',
                                        decoration: InputDecoration(
                                          labelText: "Nama",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller:
                                            _noKadPengenalanController
                                              ..text =
                                                  member?.userIdentification ??
                                                  '',
                                        decoration: InputDecoration(
                                          labelText: "No. Kad Pengenalan",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller:
                                            _alamatController
                                              ..text =
                                                  member?.userAddress ?? '',
                                        decoration: InputDecoration(
                                          labelText: "Alamat",
                                          border: OutlineInputBorder(),
                                        ),
                                        maxLines: 3,
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller:
                                            _noTelefonController
                                              ..text =
                                                  member?.userPhoneNo ?? '',
                                        decoration: InputDecoration(
                                          labelText: "No. Telefon",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller:
                                            _emailController
                                              ..text = member?.userEmail ?? '',
                                        decoration: InputDecoration(
                                          labelText: "Email",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller:
                                            _statusKeahlianController
                                              ..text = member?.userType ?? '',
                                        decoration: InputDecoration(
                                          labelText: "Status Keahlian",
                                          border: OutlineInputBorder(),
                                        ),
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // Handle form submission logic here

                                                final updatedUser = User(
                                                  userId: member?.userId,
                                                  userName:
                                                      _namaController.text,
                                                  userIdentification:
                                                      _noKadPengenalanController
                                                          .text,
                                                  userPhoneNo:
                                                      _noTelefonController.text,
                                                  userAddress:
                                                      _alamatController.text,
                                                  userEmail:
                                                      _emailController.text,
                                                  userType:
                                                      _statusKeahlianController
                                                          .text,
                                                  userPassword:
                                                      member?.userPassword ??
                                                      '', // Keep the existing password
                                                  userCreatedAt:
                                                      member?.userCreatedAt ??
                                                      DateTime.now(),
                                                  userUpdatedAt: DateTime.now(),
                                                );

                                                // Call the updateUser method from UserController
                                                await UserController()
                                                    .updateUser(updatedUser);

                                                navController.setUser(
                                                  updatedUser,
                                                );

                                                // Exit editing mode
                                                setState(() {
                                                  isEditing = false;
                                                });

                                                // Show success message
                                                Get.snackbar(
                                                  'Berjaya',
                                                  'Maklumat ahli telah dikemaskini.',
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.green,
                                                  colorText: Colors.white,
                                                );
                                              } else {
                                                Get.snackbar(
                                                  'Ralat',
                                                  'Maklumat ahli gagal dikemaskini.',
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                );
                                              }
                                            },
                                            child: const Text("Save"),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                isEditing = false;
                                              });
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
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
                                            "No. Ahli :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Nama :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "No. Kad Pengenalan :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Alamat :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "No. Telefon :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Email :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Status Keahlian :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member.userId != null
                                                  ? member.userId!.substring(
                                                    0,
                                                    8,
                                                  )
                                                  : "Unknown ID",
                                            ),
                                            const SizedBox(height: 8),
                                            Text(member.userName),
                                            const SizedBox(height: 8),
                                            Text(member.userIdentification),
                                            const SizedBox(height: 8),
                                            Text(
                                              member.userAddress,
                                              softWrap: true,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(member.userPhoneNo),
                                            const SizedBox(height: 8),
                                            Text(member.userEmail),
                                            const SizedBox(height: 8),
                                            Text(member.userType),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              if (!isEditing)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        isEditing = !isEditing;
                                      });
                                    },
                                    label: const Text("Update"),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
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
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              // Replace the existing Obx section with this code:
                              Obx(() {
                                if (familyController.isLoading.value) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                // Automatically add an empty row if there are no family members and in editing mode
                                if (familyController.familyMembers.isEmpty &&
                                    isEditingFamily) {
                                  familyController.familyMembers.add(
                                    FamilyModel(
                                      familymemberName: '',
                                      familymemberIdentification: '',
                                      familymemberRelationship: '',
                                      familyCreatedAt: DateTime.now(),
                                      familyUpdatedAt: DateTime.now(),
                                      userId:
                                          navController.getUser()?.userId ?? '',
                                    ),
                                  );
                                }

                                if (familyController.familyMembers.isEmpty &&
                                    !isEditingFamily) {
                                  return Column(
                                    children: [
                                      const Text("Tiada tanggungan tersedia."),
                                    ],
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(1),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(2),
                                        3: FlexColumnWidth(2),
                                        4: FlexColumnWidth(1),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                          ),
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                "No.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                "Nama",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                "IC/SuratBeranak",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                "Pertalian",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                "Tindakan",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ...familyController.familyMembers
                                            .asMap()
                                            .entries
                                            .map(
                                              (entry) => TableRow(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).dividerColor,
                                                    ),
                                                  ),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                        ),
                                                    child: Text(
                                                      (entry.key + 1)
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                        ),
                                                    child:
                                                        isEditingFamily
                                                            ? TextFormField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                              initialValue:
                                                                  entry
                                                                      .value
                                                                      .familymemberName,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              onChanged: (
                                                                value,
                                                              ) {
                                                                var updatedMember = entry
                                                                    .value
                                                                    .copyWith(
                                                                      familymemberName:
                                                                          value,
                                                                      familyUpdatedAt:
                                                                          DateTime.now(),
                                                                    );
                                                                familyController
                                                                        .familyMembers[entry
                                                                        .key] =
                                                                    updatedMember;
                                                              },
                                                            )
                                                            : Text(
                                                              entry
                                                                  .value
                                                                  .familymemberName,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                        ),
                                                    child:
                                                        isEditingFamily
                                                            ? TextFormField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                              initialValue:
                                                                  entry
                                                                      .value
                                                                      .familymemberIdentification,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              onChanged: (
                                                                value,
                                                              ) {
                                                                var updatedMember = entry
                                                                    .value
                                                                    .copyWith(
                                                                      familymemberIdentification:
                                                                          value,
                                                                      familyUpdatedAt:
                                                                          DateTime.now(),
                                                                    );
                                                                familyController
                                                                        .familyMembers[entry
                                                                        .key] =
                                                                    updatedMember;
                                                              },
                                                            )
                                                            : Text(
                                                              entry
                                                                  .value
                                                                  .familymemberIdentification,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                        ),
                                                    child:
                                                        isEditingFamily
                                                            ? TextFormField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                              initialValue:
                                                                  entry
                                                                      .value
                                                                      .familymemberRelationship,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              onChanged: (
                                                                value,
                                                              ) {
                                                                var updatedMember = entry
                                                                    .value
                                                                    .copyWith(
                                                                      familymemberRelationship:
                                                                          value,
                                                                      familyUpdatedAt:
                                                                          DateTime.now(),
                                                                    );
                                                                familyController
                                                                        .familyMembers[entry
                                                                        .key] =
                                                                    updatedMember;
                                                              },
                                                            )
                                                            : Text(
                                                              entry
                                                                  .value
                                                                  .familymemberRelationship,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                        ),
                                                    child:
                                                        isEditingFamily
                                                            ? IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () async {
                                                                if (entry
                                                                        .value
                                                                        .familyId !=
                                                                    null) {
                                                                  await familyController
                                                                      .deleteFamilyMember(
                                                                        entry
                                                                            .value
                                                                            .familyId!,
                                                                      );
                                                                }
                                                                familyController
                                                                    .familyMembers
                                                                    .removeAt(
                                                                      entry.key,
                                                                    );
                                                              },
                                                            )
                                                            : const SizedBox.shrink(),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (isEditingFamily)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              familyController.familyMembers.add(
                                                FamilyModel(
                                                  familymemberName: '',
                                                  familymemberIdentification:
                                                      '',
                                                  familymemberRelationship: '',
                                                  familyCreatedAt:
                                                      DateTime.now(),
                                                  familyUpdatedAt:
                                                      DateTime.now(),
                                                  userId:
                                                      navController
                                                          .getUser()
                                                          ?.userId ??
                                                      '',
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            label: const Text("Add Row"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              for (var member
                                                  in familyController
                                                      .familyMembers) {
                                                if (member.familyId != null) {
                                                  await familyController
                                                      .updateFamilyMember(
                                                        member,
                                                      );
                                                } else {
                                                  await familyController
                                                      .addFamilyMember(member);
                                                }
                                              }
                                              setState(() {
                                                isEditingFamily = false;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.save,
                                              color: Colors.white,
                                            ),
                                            label: const Text("Save All"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                isEditingFamily = false;
                                                final member =
                                                    navController.getUser();
                                                if (member != null &&
                                                    member.userId != null) {
                                                  familyController
                                                      .fetchFamilyMembersByUserId(
                                                        member.userId!,
                                                      );
                                                }
                                              });
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      ),
                                  ],
                                );
                              }),
                              const SizedBox(height: 16),
                              if (!isEditingFamily)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        isEditingFamily = !isEditingFamily;
                                      });
                                    },
                                    label: const Text("Edit"),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
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
