import 'dart:convert';
import 'dart:ui';
import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/onboding/components/animatePages/animate_otp_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';

class ChangePassword extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ChangePassword({super.key, required this.userData});

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  String secret = "";
  String qrCodeData = "";
  bool isLoading = true;
  Uint8List? qrImageBytes;

  @override
  void initState() {
    super.initState();
    _fetchSecretAndQRCode();
  }

  Future<void> _fetchSecretAndQRCode() async {
    const String url = "http://ciplaxyz.localhost:8000/generate_secret/";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userData['access']}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          secret = data['secret'];
          qrCodeData = data['qrCode'];
          final base64String = qrCodeData.split(',').last;
          qrImageBytes = base64Decode(base64String);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  bool isSecretVisible = false;

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
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const CustomImage(height: 50),
                    const SizedBox(height: 30),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              Container(
                                width: 240,
                                height: 240,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child:
                                    CustomQRImage(qrImageBytes: qrImageBytes),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Scan this QR code",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Please use your QR scanner to scan the code above.",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 30),
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  // color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Your Secret Key",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00796B),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    isSecretVisible
                                        ? Text(
                                            secret,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF333333),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: secret),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Key copied to clipboard!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 140, 181, 177),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text("Copy Key"),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    buttonText: 'Next',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OtpAnimatePage(
                                            data: widget.userData,
                                          ),
                                        ),
                                      );
                                    },
                                    height: 40,
                                    width: 120,
                                    radius: 50,
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
    );
  }
}
