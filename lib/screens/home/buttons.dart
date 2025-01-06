import 'dart:typed_data';

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final double height;
  final double width;
  final double radius;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A6A76),
            Color.fromARGB(255, 13, 192, 216),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CustomImage extends StatelessWidget {
  final double height;
  const CustomImage({
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/Kartavya-Logo.png',
      height: height,
    );
  }
}

class CustomQRImage extends StatelessWidget {
  final Uint8List? qrImageBytes;
  const CustomQRImage({
    required this.qrImageBytes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return qrImageBytes != null
        ? Image.memory(
            qrImageBytes!,
            width: 250,
            height: 250,
          )
        : Container();
  }
}

class CustomSmallImage extends StatelessWidget {
  const CustomSmallImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/Kartavya-Logo.png',
      height: 60,
    );
  }
}

void successBar(BuildContext context,
    {required String message, required Color color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
