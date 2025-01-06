import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.title,
    this.color = const Color(0xFF7553F6),
    this.iconSrc = "assets/icons/ios.svg",
  });

  final String title, iconSrc;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      height: 100,
      width: 350,
      decoration: const BoxDecoration(
        color: Color(0xFF107B8B),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 211, 201, 201),
            blurRadius: 4,
            offset: Offset(2, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 0, right: 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          1,
                          (index) => Transform.translate(
                            offset: Offset((-10 * index).toDouble(), 0),
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const RiveAnimation.asset(
                                  "assets/RiveAssets/shapes_.riv",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "",
                        style: TextStyle(
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
