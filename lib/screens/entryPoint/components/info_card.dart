import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.name,
    required this.bio,
  });

  final String name, bio;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: 50,
        width: 50,
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(100), // Adjust the radius as needed
          child: const RiveAnimation.asset(
            "assets/RiveAssets/shapes_.riv",
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        bio,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
