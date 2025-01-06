import 'package:campapplication/screens/home/buttons.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const AboutUsPage({
    super.key,
    required this.data,
  });
  @override
  // ignore: library_private_types_in_public_api
  _AboutUsPage createState() => _AboutUsPage();
}

class _AboutUsPage extends State<AboutUsPage> {
  @override
  void initState() {
    super.initState();
  }

  void _refresh() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 16, 123, 139),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                CustomImage(height: 30), // Adjust height to fit image size
                SizedBox(height: 20),
                Text(
                  "About Kartavya Healtheon Pvt Ltd",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Kartavya Healtheon Pvt Ltd is a trusted healthcare partner, delivering compassionate care and fostering relationships.",
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                SizedBox(height: 16),

                Divider(color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Email: test@test.com\nPhone: +91 12345 67890\nAddress:  Mumbai, India",
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
