import 'dart:async';

import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/constans.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import "package:google_maps_flutter/google_maps_flutter.dart";

import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class SeheduleCard extends StatefulWidget {
  const SeheduleCard({
    super.key,
    required this.data,
    required this.selectedCompany,
    required this.title,
    // ignore: non_constant_identifier_names
    required this.start_time,
    // ignore: non_constant_identifier_names
    required this.end_time,
    required this.token,
    this.iconsSrc = "assets/icons/ios.svg",
    this.colorl = const Color(0xFF7553F6),
    required this.scheduleID,
    required this.phelboID,
    required this.doctorID,
    required this.doctorName,
    required this.imageUrl,
    required this.status,
  });
  final Map<String, dynamic> data;
  final Map<String, String>? selectedCompany;
  final String title, iconsSrc;
  final String token;
  final Color colorl;
  // ignore: non_constant_identifier_names
  final String start_time;
  // ignore: non_constant_identifier_names
  final String end_time;

  final int scheduleID;
  final int phelboID;
  final int doctorID;
  final String doctorName;
  final String imageUrl;
  final int status;
  @override
  // ignore: library_private_types_in_public_api
  _SeheduleCardState createState() => _SeheduleCardState();
}

class _SeheduleCardState extends State<SeheduleCard> {
  int _status = 0;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  Future<bool> _checkOngoingSchedules() async {
    var checkUrl = Uri.parse('http://ciplaxyz.$kUrl/check_ongoing_schedules/');
    try {
      final response = await http.get(
        checkUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ongoing'] as bool;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> _startSchedule() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        successBar(
          // ignore: use_build_context_synchronously
          context,
          message: 'Location permission denied',
          color: Colors.red,
        );

        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      successBar(
        // ignore: use_build_context_synchronously
        context,
        message:
            'Location permissions are permanently denied, we cannot request permissions.',
        color: Colors.red,
      );

      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
      Set<Marker> markers = {};
      // LatLng myCurrentLocation = const LatLng(37.33233141, -122.0312186);
      LatLng myCurrentLocation = LatLng(position.latitude, position.longitude);

      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: myCurrentLocation,
          infoWindow: const InfoWindow(
            title: 'Current Location',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );

      bool shouldStart = await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Share Location",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: GoogleMap(
                    myLocationButtonEnabled: false,
                    markers: markers,
                    initialCameraPosition: CameraPosition(
                      target: myCurrentLocation,
                      zoom: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Are you sure you want to share your location?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

      if (shouldStart) {
        if (await _checkOngoingSchedules()) {
          successBar(
            // ignore: use_build_context_synchronously
            context,
            message: 'Another OPD is already ongoing.',
            color: Colors.red,
          );

          return;
        }

        var baseUrl = Uri.parse(
            'http://ciplaxyz.$kUrl/schedular_app_master/${widget.scheduleID}/');

        try {
          final response = await http.put(
            baseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.token}',
            },
            body: json.encode({
              'status': 2,
              'latitude': position.latitude,
              'longitude': position.longitude,
            }),
          );
          if (response.statusCode == 200) {
            setState(() {
              _status = 2;
            });
          } else {
            successBar(
              // ignore: use_build_context_synchronously
              context,
              message: 'Failed to start schedule',
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
    } catch (e) {
      successBar(
        // ignore: use_build_context_synchronously
        context,
        message: 'Error retrieving location: $e',
        color: Colors.red,
      );
    }
  }

  void _goToOPD() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => OPDPage(
    //         data: widget.data,
    //         selectedCompany: widget.selectedCompany,
    //         // token: widget.token,
    //         // scheduleID: widget.scheduleID,
    //         // doctorID: widget.doctorID,
    //         // phelboID: widget.phelboID,
    //         // doctorName: widget.doctorName,
    //         // startTime: widget.start_time,
    //         // endTime: widget.end_time,
    //         ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    String statusText = '';
    Widget actionButton;
//
    switch (_status) {
      case 1:
        statusText = '';
        actionButton = SizedBox(
          width: 110.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(10, 30),
              backgroundColor: Colors.black,
            ),
            onPressed: _startSchedule,
            child: const Text(
              'Start',
              style: TextStyle(color: Colors.white, height: 2),
            ),
          ),
        );
        break;
      case 2:
        statusText = 'Ongoing';
        actionButton = const SizedBox.shrink();

        break;
      case 3:
        statusText = 'OPD has ended';
        actionButton = const SizedBox.shrink();
        break;
      default:
        statusText = '';
        actionButton = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _status == 2 ? _goToOPD : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        width: 400,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 107, 182, 222),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBlackColor),
          boxShadow: [
            BoxShadow(
              color: kBoxShadow,
              blurRadius: 4,
              offset: const Offset(10, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Opd Time : ${widget.start_time} - ${widget.end_time}",
                    style: TextStyle(
                      color: kGreyShade,
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 40,
              child: VerticalDivider(
                color: Color.fromARGB(179, 195, 193, 193),
              ),
            ),
            Column(
              children: [
                if (statusText.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                actionButton,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
