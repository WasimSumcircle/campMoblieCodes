import 'package:flutter/material.dart';

class PatientDetailsPage extends StatefulWidget {
  final String title;
  final String token;
  final String gender;
  final String age;
  final int patientID;
  final String iconSrc;
  final Color color;

  const PatientDetailsPage({
    super.key,
    required this.title,
    required this.token,
    required this.gender,
    required this.age,
    required this.patientID,
    required this.iconSrc,
    required this.color,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetailsPage> {
  Widget _buildTag(String title, String data, String dataType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          dataType,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCardTag(String title, String data, String dataType) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dataType,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.color,
      ),
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Card(
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 350,
                height: 600,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 56),
                      Text(
                        'Patient Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Icon(Icons.person, color: widget.color, size: 48),
                          const SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Patient UID',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                widget.title.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'ID: ${widget.patientID}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTag('Age', widget.age, 'Years'),
                          _buildTag('Gender', widget.gender, ''),
                          _buildTag('Test', '22', 'Test'),
                        ],
                      ),
                      const SizedBox(height: 46),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCardTag('Diabetes', 'No', ''),
                          _buildCardTag('BP', 'No', ''),
                          _buildCardTag('Test', '22', 'Test'),
                        ],
                      ),
                      const SizedBox(height: 46),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCardTag('Test', '22', 'Test'),
                          _buildCardTag('Test', '22', 'Test'),
                          _buildCardTag('Test', '22', 'Test'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -40,
              child: Material(
                elevation: 6.0,
                shadowColor: widget.color.withOpacity(0.4),
                shape: const CircleBorder(),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: widget.color,
                  child: const Icon(
                    Icons.content_paste,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            const Positioned(
              top: -8,
              left: 170,
              child: Icon(
                Icons.create,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
