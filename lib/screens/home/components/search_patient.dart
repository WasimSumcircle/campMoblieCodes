import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/constans.dart';
import 'package:flutter/material.dart';
import 'package:campapplication/screens/home/components/patient_list.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPatientPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const SearchPatientPage({
    super.key,
    required this.data,
  });
  @override
  // ignore: library_private_types_in_public_api
  _SearchPatientPage createState() => _SearchPatientPage();
}

class _SearchPatientPage extends State<SearchPatientPage> {
  List<dynamic> patientList = [];
  List<dynamic> filteredPatientList = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPatientList();
  }

  Future<void> _fetchPatientList() async {
    final response = await http.get(
      Uri.parse('http://ciplaxyz.$kUrl/insert_patient_master/'),
      headers: {
        'Authorization': 'Bearer ${widget.data['access']}',
      },
    );

    if (response.statusCode == 200) {
      var patientData = jsonDecode(response.body);
      var data = patientData['data'];
      List patientListData = data.map((item) {
        return {
          'patientName': item['uid'] ?? 'Unknown',
          'uid': item['id'] ?? 'Unknown',
          'age': item['age'] ?? 'Unknown',
          'patientID': item['id'],
          'gender': item['gender'],
          'colorl': const Color(0xFF9CC5FF),
          'iconSrc': "assets/icons/User.svg",
        };
      }).toList();

      setState(() {
        patientList = patientListData;
        filteredPatientList = patientListData;
      });
    } else {
      successBar(
        // ignore: use_build_context_synchronously
        context,
        message: 'Failed to load patient list',
        color: Colors.red,
      );
    }
  }

  void _filterPatients(String query) {
    final filteredPatients = patientList.where((patient) {
      final patientName = patient['patientName'].toLowerCase();
      final searchLower = query.toLowerCase();
      return patientName.contains(searchLower);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredPatientList = filteredPatients;
    });
  }

  void _refresh() {
    _fetchPatientList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Patient List",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 16, 123, 139),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: 'Search patients...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterPatients,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredPatientList.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredPatientList.length,
                        itemBuilder: (context, index) {
                          final course = filteredPatientList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: SecondaryCourseCard(
                              title: course['patientName'],
                              patientID: course['patientID'],
                              age: course['age'],
                              gender: course['gender'],
                              token: widget.data['access'],
                              iconSrc: course['iconSrc'],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Image.asset(
                          'assets/logo/no_data.png',
                          height: 250,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientSearchDelegate extends SearchDelegate {
  final List<dynamic> patientList;
  final ValueChanged<dynamic> onSelected;

  PatientSearchDelegate({required this.patientList, required this.onSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = patientList.where((patient) {
      return patient['patientName'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final patient = results[index];
        return ListTile(
          title: Text(patient['patientName']),
          subtitle: Text('ID: ${patient['patientID']}'),
          onTap: () {
            onSelected(patient);
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = patientList.where((patient) {
      return patient['patientName'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final patient = suggestions[index];
        return ListTile(
          title: Text(patient['patientName']),
          subtitle: Text('ID: ${patient['patientID']}'),
          onTap: () {
            onSelected(patient);
            close(context, null);
          },
        );
      },
    );
  }
}
