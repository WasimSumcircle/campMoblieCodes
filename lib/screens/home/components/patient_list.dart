import 'package:campapplication/screens/home/components/patient_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecondaryCourseCard extends StatelessWidget {
  const SecondaryCourseCard({
    super.key,
    required this.title,
    required this.token,
    required this.gender,
    required this.age,
    required this.patientID,
    required this.iconSrc,
    this.color = Colors.teal,
  });

  final String title, token, gender, iconSrc;
  final String age;
  final int patientID;
  final Color color;

  @override
  Widget build(BuildContext context) {
    void patientDetails() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              // AddNewCardPage(),
              PatientDetailsPage(
            title: title,
            token: token,
            gender: gender,
            age: age,
            patientID: patientID,
            iconSrc: iconSrc,
            color: const Color(0xFF107B8B),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: patientDetails,
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
                    'UID: $title',
                    // 'ID: $patientID',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$age years, Gender: $gender',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // CircleAvatar(
            // backgroundImage: AssetImage(iconSrc),
            SvgPicture.asset(
              iconSrc,
              height: 30,
              width: 40,
              // ignore: deprecated_member_use
              color: const Color(0xFF107B8B),
            ),
            // radius: 20,
            // ),
          ],
        ),
      ),
    );
  }
}
