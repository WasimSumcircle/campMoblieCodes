import 'dart:ui';
import 'package:campapplication/screens/entryPoint/entry_point.dart';
import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/onboding/components/animatePages/animate_company.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpAnimatePage extends StatefulWidget {
  final Map<String, dynamic> data;
  const OtpAnimatePage({required this.data, super.key});

  @override
  State<OtpAnimatePage> createState() => _OtpAnimatePageState();
}

class _OtpAnimatePageState extends State<OtpAnimatePage> {
  bool isShowSignInDialog = false;

  String otpCode = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> confirmOtp() async {
    if (otpCode.length != 6) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Error'),
          contentPadding: const EdgeInsets.all(20),
          content: const Text('Please enter a 6-digit OTP.'),
          actions: [
            CustomButton(
              buttonText: 'Yes,Sure',
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              height: 40,
              width: 140,
              radius: 10,
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse('http://localhost:8000/generate_secret/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.data['access']}',
        },
        body: json.encode({'token': otpCode}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', widget.data['access']);
        await prefs.setString('username', widget.data['payload']['username']);
        await prefs.setString('data', jsonEncode(widget.data));

        if (widget.data['payload']['campaign'].length == 1) {
          var companyData = widget.data['payload']['campaign'][0];

          String urlDomain = companyData['campaign']['domain'];
          String companyName = companyData['campaign']['company']['name'];

          await prefs.setString('companyName', jsonEncode(companyName));
          await prefs.setString('url_domain', jsonEncode(urlDomain));
          Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => CompanyAnimatePage(
                  data: widget.data,
                ),
              ));
        } else {
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => EntryPoint(
                data: widget.data,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        _showErrorDialog("Invalid OTP.");
      }
    } catch (e) {
      _showErrorDialog('$e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          CustomButton(
            buttonText: 'Yes, Sure',
            onPressed: () {
              Navigator.of(context).pop(true); // Close the dialog
            },
            height: 40,
            width: 150,
            radius: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: const SizedBox(),
            ),
          ),
          const RiveAnimation.asset(
            "assets/RiveAssets/shape.riv",
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),
          Center(
            child: Container(
              height: 520,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 211, 201, 201),
                    blurRadius: 4,
                    offset: Offset(1, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const CustomImage(height: 50),
                  const SizedBox(height: 50),
                  Text(
                    'Enter Otp!',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),
                  OtpTextField(
                    enabledBorderColor: Colors.teal,
                    focusedBorderColor: Colors.grey,
                    numberOfFields: 6,
                    borderColor: Colors.black,
                    showFieldAsBox: true,
                    onCodeChanged: (String code) {
                      otpCode = code;
                    },
                    onSubmit: (String verificationCode) async {
                      otpCode = verificationCode;
                      await confirmOtp();
                    },
                  ),
                  const SizedBox(height: 45),
                  CustomButton(
                    buttonText: 'Confirm',
                    onPressed: confirmOtp,
                    height: 45,
                    width: 145,
                    radius: 10,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
