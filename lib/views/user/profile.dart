import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final surfaceColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    TextEditingController name_controller = TextEditingController();
    TextEditingController email_controller = TextEditingController();
    TextEditingController phone_controller = TextEditingController();
    TextEditingController address_controller = TextEditingController();
    TextEditingController password_controller = TextEditingController();
    TextEditingController confirm_controller = TextEditingController();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back button at the top left
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            // Rest of the content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Colors.black26,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(surfaceColor!, textColor),
                            _buildSectionTitle('Name', textColor),
                            _buildSettingItem(
                              surfaceColor,
                              controller: name_controller,
                            ),
                            _buildSectionTitle('Email', textColor),
                            _buildSettingItem(
                              surfaceColor,
                              controller: email_controller,
                            ),
                            _buildSectionTitle('Phone Number', textColor),
                            _buildSettingItem(
                              surfaceColor,
                              controller: phone_controller,
                            ),
                            _buildSectionTitle('Address', textColor),
                            _buildTextArea(
                              Icons.account_circle_outlined,
                              'Edit Address',
                              surfaceColor,
                              textColor,
                              controller: address_controller,
                            ),
                            _buildSectionTitle('Password', textColor),
                            _buildSettingItem(
                              surfaceColor,
                              controller: password_controller,
                            ),
                            _buildSectionTitle('Confirm Password', textColor),
                            _buildSettingItem(
                              surfaceColor,
                              controller: confirm_controller,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ), // Customize the padding as needed
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: MoonFilledButton(
                                  buttonSize: MoonButtonSize.sm,
                                  onTap: () {},
                                  leading: const Icon(
                                    MoonIcons.generic_edit_16_light,
                                  ),
                                  label: const Text("Edit"),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color surfaceColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Text(title, style: TextStyle(fontSize: 18, color: textColor)),
    );
  }

  Widget _buildSettingItem(
    Color textColor, {
    double bottomPadding = 12,
    String? initialValue,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: MoonTextInput(
              controller: controller,
              initialValue: initialValue,
              textInputSize: MoonTextInputSize.md,
              backgroundColor: Colors.transparent,
              cursorColor: MoonColors.light.trunks, // Use a Moon color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(
    IconData icon,
    String label,
    Color surfaceColor,
    Color textColor, {
    double bottomPadding = 12,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: MoonTextArea(
              controller: controller,
              height: 100,
              validator:
                  (String? value) =>
                      value?.length != null && value!.length < 5
                          ? "The text should be longer than 5 characters."
                          : null,
            ),
          ),
        ],
      ),
    );
  }
}
