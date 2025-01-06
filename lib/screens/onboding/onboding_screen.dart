import 'dart:ui';

import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/onboding/components/animatePages/animate_log_in.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/animated_btn.dart';

class OnbodingScreen extends StatefulWidget {
  const OnbodingScreen({super.key});

  @override
  State<OnbodingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnbodingScreen> {
  late RiveAnimationController _btnAnimationController;
  bool isShowSignInDialog = false;

  @override
  void initState() {
    super.initState();

    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );

    _checkDataAndNavigate();
  }

  Future<void> _checkDataAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    String? dataString = prefs.getString('data');

    if (dataString != null) {
      // print(1);
    }
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
          AnimatedPositioned(
            top: isShowSignInDialog ? -50 : 0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            duration: const Duration(milliseconds: 260),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const CustomImage(
                      height: 60,
                    ),
                    const SizedBox(
                      width: 260,
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Text(
                              "Kartavya Healtheon Pvt Ltd is a trusted healthcare partner, delivering compassionate care and fostering relationships."),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    AnimatedBtn(
                      btnAnimationController: _btnAnimationController,
                      press: () {
                        _btnAnimationController.isActive = true;

                        Future.delayed(
                          const Duration(milliseconds: 800),
                          () {
                            setState(() {
                              isShowSignInDialog = true;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginAnimatePage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 40,
                    )
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
