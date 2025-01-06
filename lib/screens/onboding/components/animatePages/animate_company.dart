import 'dart:ui';

import 'package:campapplication/screens/entryPoint/entry_point.dart';
import 'package:campapplication/screens/home/buttons.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CompanyAnimatePage extends StatefulWidget {
  final Map<String, dynamic> data;
  const CompanyAnimatePage({required this.data, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompanyAnimatePageState createState() => _CompanyAnimatePageState();
}

class _CompanyAnimatePageState extends State<CompanyAnimatePage> {
  String? selectedCompanyDomain;
  Map<String, String>? selectedCompany;
  List<Map<String, String>> companies = [];

  @override
  void initState() {
    super.initState();
    _initializeCompanies();
  }

  void _initializeCompanies() {
    final campaign = widget.data['payload']['campaign'] ?? [];
    companies = campaign.map<Map<String, String>>((campaignData) {
      return {
        'domain': campaignData['campaign']['domain'].toString(),
        'name': campaignData['campaign']['name'].toString(),
      };
    }).toList();
  }

  Future<void> confirmCompany() async {
    if (selectedCompany != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'companyName', jsonEncode(selectedCompany?['name']));
      await prefs.setString('url_domain', jsonEncode(selectedCompanyDomain));

      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => EntryPoint(
            data: widget.data,
            // selectedCompany: selectedCompany,
          ),
        ),
        (route) => false,
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'No company selected',
            ),
            content: const Text(
              'You have to select one of the companies.',
              style: TextStyle(color: Colors.red),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 5),
              CustomButton(
                buttonText: 'Yes, Sure',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                height: 40,
                width: 140,
                radius: 10,
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(children: [
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomImage(height: 50),
                const SizedBox(height: 50),
                const Text(
                  "Enter Your Company",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Select Company",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    value: selectedCompanyDomain,
                    items: companies.map<DropdownMenuItem<String>>((company) {
                      return DropdownMenuItem<String>(
                        value: company['domain'],
                        child: Text(company['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCompanyDomain = value;
                        selectedCompany = companies.firstWhere(
                            (company) => company['domain'] == value);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a company';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  child: CustomButton(
                    buttonText: 'Confirm',
                    onPressed: confirmCompany,
                    height: 45,
                    width: 145,
                    radius: 10,
                  ),
                ),
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
