import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/qr_code.dart';
import 'package:campapplication/screens/onboding/components/animatePages/animate_company.dart';
import 'package:campapplication/screens/onboding/onboding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const SettingPage({
    super.key,
    required this.data,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<Map<String, dynamic>> settingList = [
    {
      "title": "OTP authentication",
      "icon": Icons.key,
      "message": "For QR code or to obtain the secret key!",
      "function": 1,
    },
    {
      "title": "Change Campaign ",
      "icon": Icons.business,
      "message": "Want to change company?",
      "function": 2,
    },
    {
      "title": "Log Out",
      "icon": Icons.logout,
      "message": "Want to log out?",
      "function": 3,
    },
    // Add more settings here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Setting",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 16, 123, 139),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const CustomImage(height: 30),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: settingList.length,
                  itemBuilder: (context, index) {
                    final setting = settingList[index];
                    final title = setting['title'] ?? 'Default Title';
                    final message = setting['message'] ?? 'Default Message';
                    final icons = setting['icon'] ?? Icons.help;
                    final function = setting['function'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SettingListCard(
                        userData: widget.data,
                        title: title,
                        message: message,
                        icons: icons,
                        function: function.toString(),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingListCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Color color;
  final IconData icons;
  final String title, message;
  final VoidCallback? onTap;
  final String function;

  const SettingListCard({
    super.key,
    this.color = Colors.black,
    required this.userData,
    required this.title,
    required this.icons,
    required this.message,
    required this.function,
    this.onTap,
  });

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Logout'),
          content: const Text(
              'Are you sure you want to log out and delete all stored data?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 5),
            CustomButton(
              buttonText: 'Yes, Sure',
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout(context);
              },
              height: 40,
              width: 140,
              radius: 10,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const OnbodingScreen()),
    );
  }

  void _changeCompany(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyAnimatePage(
          data: userData,
        ),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('OTP authentication'),
          content: const Text(
            'Are you certain you wish to proceed with modifying the OTP authentication?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 5),
            CustomButton(
              buttonText: 'Yes, Sure',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePassword(
                      userData: userData,
                    ),
                  ),
                );
              },
              height: 40,
              width: 140,
              radius: 10,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (function == '1') {
          _changePassword(context);
        } else if (function == '2') {
          _changeCompany(context);
        } else if (function == '3') {
          _showLogoutConfirmation(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.question_answer,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(icons)
          ],
        ),
      ),
    );
  }
}
