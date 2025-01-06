import 'package:flutter/material.dart';

String kUrl = 'localhost:8000';
Color kBlackColor = Colors.black;

Color kListCard = const Color.fromARGB(255, 127, 191, 226);
Color kverticalLine = const Color.fromARGB(255, 154, 150, 150);
Color kBoxShadow = const Color.fromARGB(255, 211, 201, 201);
Color kGreyShade = Colors.grey.shade900;

Widget kgradientButton(String title, onPressed) {
  return Container(
    height: 40,
    width: 150,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
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
        elevation: 0,
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    ),
  );
}
