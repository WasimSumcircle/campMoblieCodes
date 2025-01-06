import 'dart:ui';
import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/qr_code.dart';
import 'package:campapplication/screens/onboding/components/animatePages/animate_otp_in.dart';
import 'package:campapplication/screens/onboding/components/animatePages/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginAnimatePage extends StatefulWidget {
  const LoginAnimatePage({super.key});

  @override
  State<LoginAnimatePage> createState() => _LoginAnimatePageState();
}

class _LoginAnimatePageState extends State<LoginAnimatePage> {
  bool isShowSignInDialog = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePassword);
    usernameController.addListener(_validateUsername);

    _checkDataAndNavigate();
  }

  void _validatePassword() {
    setState(() {
      isPasswordValid = passwordController.text.trim().isNotEmpty;
    });
  }

  void _validateUsername() {
    setState(() {
      isUsernameValid = usernameController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    passwordController.removeListener(_validatePassword);
    usernameController.removeListener(_validateUsername);
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isUsernameValid = true;
  bool isPasswordValid = true;

  Future<void> signUserIn() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      isUsernameValid = username.isNotEmpty;
      isPasswordValid = password.isNotEmpty;
    });

    if (isUsernameValid && isPasswordValid) {
      try {
        final response = await http.post(
          Uri.parse("http://localhost:8000/phlebo_login/"),
          body: {
            'username': username,
            'password': password,
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final url1 = Uri.parse('http://localhost:8000/give_secret/');

          final generateSecrete = await http.get(
            url1,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${data['access']}',
            },
          );
          var outPut = jsonDecode(generateSecrete.body);
          if (outPut['data']['qr'] == false) {
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => OtpAnimatePage(
                  data: data,
                ),
              ),
            );
          } else {
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => ChangePassword(
                  userData: data,
                ),
              ),
            );
          }
        } else {
          _showErrorDialog("Incorrect username or password. Please try again.");
        }
      } catch (e) {
        _showErrorDialog("An error occurred. Please try again later.");
      }
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
              Navigator.of(context).pop(true);
            },
            height: 40,
            width: 150,
            radius: 10,
          ),
        ],
      ),
    );
  }

  Future<void> _checkDataAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    String? dataString = prefs.getString('data');

    if (dataString != null) {}
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
              // filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    const CustomImage(height: 50),
                    const SizedBox(height: 50),
                    const SizedBox(height: 25),
                    MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),
                    if (!isUsernameValid)
                      const Padding(
                        padding: EdgeInsets.only(top: 0, left: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Username field is required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: false,
                    ),
                    if (!isPasswordValid)
                      const Padding(
                        padding: EdgeInsets.only(top: 5, left: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Password field is required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 45),
                    CustomButton(
                      buttonText: 'Login',
                      onPressed: signUserIn,
                      height: 45,
                      width: 145,
                      radius: 10,
                    ),
                    const SizedBox(height: 50),
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
