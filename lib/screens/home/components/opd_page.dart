import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/constans.dart';
import 'package:campapplication/screens/home/components/feedback_form.dart';
import 'package:campapplication/screens/home/components/patient_form.dart';
import 'package:campapplication/screens/home/components/patient_list.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

class OPDPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final int scheduleID;
  final int phelboID;
  final int doctorID;
  final String doctorName;
  final String startTime;
  final String endTime;
  final String token;

  const OPDPage({
    super.key,
    required this.data,
    required this.scheduleID,
    required this.phelboID,
    required this.doctorID,
    required this.doctorName,
    required this.startTime,
    required this.endTime,
    required this.token,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OPDPageState createState() => _OPDPageState();
}

class _OPDPageState extends State<OPDPage> {
  List<dynamic> patientList = [];

  @override
  void initState() {
    super.initState();
    _fetchPatientList();
  }

  Future<void> _fetchPatientList() async {
    var baseUrl =
        Uri.parse('http://ciplaxyz.$kUrl/patient_data_by_schedule_id/');

    try {
      final response = await http.post(
        baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.data['access']}',
        },
        body: json.encode({
          'phelbo_id': widget.data['payload']['phleboID'],
          'schedule_id': widget.scheduleID,
        }),
      );
      if (response.statusCode == 200) {
        var patientData = jsonDecode(response.body);

        // var message = patientData['message'];
        var data = patientData['data'] ?? [];
        List patientListData = data.map((item) {
          return {
            'patientName': item['uid'] ?? 'Unknown',
            'age': item['age'] ?? 'Unknown',
            'patientID': item['id'],
            'gender': item['gender'],
            'colorl': const Color(0xFF9CC5FF),
            'iconSrc': "assets/icons/User.svg",
          };
        }).toList();
        setState(() {
          patientList = patientListData;
        });
      } else {
        successBar(
          // ignore: use_build_context_synchronously
          context,
          message: 'Failed to load patient list',
          color: Colors.red,
        );
      }
    } catch (e) {
      successBar(
        // ignore: use_build_context_synchronously
        context,
        message: 'Error occurred: $e',
        color: Colors.red,
      );
    }
  }

  void _showAddPatientForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientForm(
          scheduleID: widget.scheduleID,
          token: widget.token,
          doctorID: widget.doctorID,
          phelboID: widget.phelboID,
          doctorName: widget.doctorName,
          onPatientAdded: _fetchPatientList,
        ),
      ),
    );
  }

  void _exitOpd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackFormScreen(
          data: widget.data,
          scheduleID: widget.scheduleID,
          phelboID: widget.phelboID,
          doctorID: widget.doctorID,
          token: widget.token,
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OPD Schedule',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'End OPD':
                  _exitOpd();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'End OPD',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.black,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'End OPD',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Colors.white,
            elevation: 4.0,
          )
        ],
        backgroundColor: const Color.fromARGB(255, 16, 123, 139),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                // color: Color.fromARGB(255, 16, 123, 139),
                border: Border.all(
                    color: const Color.fromARGB(255, 16, 123, 139)
                        .withOpacity(0.6)),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 211, 201, 201),
                    blurRadius: 4,
                    offset: Offset(4, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctorName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CustomButton(
                          buttonText: 'Add Patient',
                          onPressed: _showAddPatientForm,
                          height: 40,
                          width: 150,
                          radius: 80,
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  patientList.isEmpty
                      ? Center(
                          child: Image.asset(
                          'assets/logo/no_data.png',
                          height: 250,
                        ))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: patientList.length,
                            itemBuilder: (context, index) {
                              final patient = patientList[index];
                              return Column(
                                children: [
                                  SecondaryCourseCard(
                                    title: patient['patientName'],
                                    patientID: patient['patientID'],
                                    age: patient['age'],
                                    gender: patient['gender'],
                                    token: widget.data['access'],
                                    iconSrc: patient['iconSrc'],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            },
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
