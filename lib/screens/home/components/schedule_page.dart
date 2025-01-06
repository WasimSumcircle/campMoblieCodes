import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/constans.dart';
import 'package:campapplication/screens/home/components/opd_page.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";

import 'package:url_launcher/url_launcher.dart';

class SchedulePage extends StatefulWidget {
  final Map<String, dynamic> data;

  const SchedulePage({
    super.key,
    required this.data,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _dateList = [];
  List<dynamic> _scheduleList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();
    _selectedDate = today;
    _generateDateList();
  }

  void _generateDateList() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      _dateList.add(DateTime.now().add(Duration(days: i)));
    }
  }

  void _goToClinicDialogLocation(dynamic schedule) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Go to Clinic Location'),
          content: const Text('Are you sure you want Go?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            CustomButton(
              buttonText: 'Yes',
              onPressed: () {
                Navigator.of(context).pop();
                _goToClinicLocation(schedule);
              },
              height: 40,
              width: 80,
              radius: 10,
            ),
          ],
        );
      },
    );
  }

  void _goToClinicLocation(dynamic schedule) async {
    const clinicLat = 37.38233141;
    const clinicLng = -122.0812186;
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      var url =
          "https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$clinicLat,$clinicLng";
      final Uri url0 = Uri.parse(url);
      launchUrl(url0);
    } catch (e) {
      successBar(
        // ignore: use_build_context_synchronously
        context,
        message: 'Error retrieving location: $e',
        color: Colors.red,
      );

      return;
    }
    try {} catch (_) {
      successBar(
        // ignore: use_build_context_synchronously
        context,
        message: 'Error launch Map',
        color: Colors.red,
      );
    }
  }

  void _showCancelConfirmationDialog(dynamic schedule) {
    List<String> reasons = [
      // 'Technician not on time',
      // 'Leave',
      // 'Technician not available',
      // 'Patient not available',
      'Doctor on Leave',
      'Other'
    ];

    String selectedReason = reasons[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Cancel OPD',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to cancel OPD?',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: InputDecoration(
                  labelText: 'Reason for cancellation',
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                items: reasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedReason = newValue;
                  }
                },
                dropdownColor: Colors.white,
                menuMaxHeight: 200,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            CustomButton(
              buttonText: 'Yes',
              onPressed: () async {
                if (selectedReason.isNotEmpty) {
                  Navigator.of(context).pop();
                  await _cancelSchedule(schedule, selectedReason);
                } else {
                  successBar(
                    context,
                    message: 'Please select a reason for cancellation',
                    color: Colors.red,
                  );
                }
              },
              height: 40,
              width: 80,
              radius: 10,
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelSchedule(dynamic schedule, String reason) async {
    final Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    try {
      var baseUrl = Uri.parse(
          'http://ciplaxyz.$kUrl/cancle_schedule/${schedule['scheduleID']}/');
      final response = await http.put(
        baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${schedule['token']}',
        },
        body: json.encode({
          'status': 4,
          'phlebo_id': schedule['phelboID'],
          'latitude': position.latitude,
          'longitude': position.longitude,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          schedule['status'] = 4;
        });
        successBar(
          // ignore: use_build_context_synchronously
          context,
          message: 'OPD has been cancelled',
          color: Colors.red,
        );
      } else {
        successBar(
          // ignore: use_build_context_synchronously
          context,
          message: 'Failed to cancel OPD',
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

  Future<void> _fetchSchedule(DateTime date) async {
    setState(() {
      // make true for show loader
      _isLoading = false;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    var baseUrl = Uri.parse('http://ciplaxyz.$kUrl/schedular_app_master/');

    try {
      final response = await http.post(
        baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.data['access']}',
        },
        body: json.encode({
          'phelbo_id': widget.data['payload']['phleboID'],
          'scheduleDate': formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        var scheduleData = jsonDecode(response.body);
        List scheduleList = (scheduleData['data'] as List).map((item) {
          return {
            'doctorName': item['doctor']['name'],
            'doctorID': item['doctor']['id'],
            'token': widget.data['access'],
            'scheduleID': item['id'],
            'phelboID': item['phelbo']['id'],
            'phelbo': item['phelbo']['name'],
            'inventory': item['inventory_id']['name'],
            'scheduled_date': item['scheduled_date'],
            'start_time': item['start_time'],
            'end_time': item['end_time'],
            'status': item['status'],
            'title': item['doctor']['name'],
            'color': const Color(0xFF7553F6),
            'iconSrc': "assets/icons/doctor.svg",
          };
        }).toList();

        setState(() {
          _scheduleList = scheduleList;
        });
      } else {
        successBar(
          // ignore: use_build_context_synchronously
          context,
          message: 'Failed to fetch schedule',
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startSchedule(dynamic schedule) async {
    DateTime scheduleDate = DateTime.parse(schedule['scheduled_date']);
    DateTime today = DateTime.now().toLocal();

    if (scheduleDate.year != today.year ||
        scheduleDate.month != today.month ||
        scheduleDate.day != today.day) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.redAccent,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Not Today's OPD",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "You can only start an OPD for today's date.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  buttonText: 'Yes,Sure',
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  height: 40,
                  width: 150,
                  radius: 10,
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    bool hasOngoingOPD = _scheduleList.any((s) => s['status'] == 2);

    if (hasOngoingOPD) {
      showDialog(
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
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Existing OPD Ongoing",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Please complete the existing OPD before starting a new one.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107B8B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

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
            backgroundColor: Colors.white,
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
                    CustomButton(
                      buttonText: 'Yes',
                      onPressed: () async {
                        successBar(
                          context,
                          message: 'OPD Started',
                          color: Colors.green,
                        );
                        Navigator.of(context).pop(true);
                      },
                      height: 40,
                      width: 150,
                      radius: 10,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
      if (shouldStart) {
        var baseUrl = Uri.parse(
            'http://ciplaxyz.$kUrl/schedular_app_master/${schedule['scheduleID']}/');

        try {
          final response = await http.put(
            baseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${schedule['token']}',
            },
            body: json.encode({
              'status': 2,
              'latitude': position.latitude,
              'longitude': position.longitude,
            }),
          );
          if (response.statusCode == 200) {
            setState(() {
              schedule['status'] = 2;
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving location: $e')),
      );
    }
  }

  void _refresh() {
    _fetchSchedule(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    _fetchSchedule(_selectedDate);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF107B8B),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                DateFormat('MMMM, yyyy').format(_selectedDate),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            _buildDateSelector(),
            const SizedBox(height: 20),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            Expanded(
              child: _scheduleList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _scheduleList.length,
                      itemBuilder: (context, index) {
                        final schedule = _scheduleList[index];
                        return _buildScheduleCard(schedule);
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
    );
  }

  _goToOPD(dynamic schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OPDPage(
          data: widget.data,
          // selectedCompany: widget.selectedCompany,
          token: widget.data['access'],
          scheduleID: schedule['scheduleID'],
          doctorID: schedule['doctorID'],
          phelboID: schedule['phelboID'],
          doctorName: schedule['doctorName'],
          startTime: schedule['start_time'],
          endTime: schedule['end_time'],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dateList.length,
        itemBuilder: (context, index) {
          DateTime date = _dateList[index];
          bool isSelected = _selectedDate == date;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _fetchSchedule(date);
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF107B8B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF107B8B)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(dynamic schedule) {
    Color borderColor;
    switch (schedule['status']) {
      case 1:
        borderColor = Colors.green;
        break;
      case 2:
        borderColor = Colors.orange;
        break;
      case 3:
        borderColor = Colors.blue.withOpacity(0.6);
        break;
      case 4:
        borderColor = Colors.red;
        break;
      default:
        borderColor = Colors.grey.withOpacity(0.6);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 100,
              spreadRadius: 9,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  "${schedule['start_time']} - ${schedule['end_time']}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 140),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'cancel_opd':
                        _showCancelConfirmationDialog(schedule);
                        break;
                      case 'clinic_location':
                        _goToClinicDialogLocation(schedule);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      if (schedule['status'] != 3 && schedule['status'] != 4)
                        const PopupMenuItem<String>(
                          value: 'cancel_opd',
                          child: Text('Cancel OPD'),
                        ),
                      const PopupMenuItem<String>(
                        value: 'clinic_location',
                        child: Text('Go to Clinic Location'),
                      ),
                    ];
                  },
                )
              ],
            ),
            Row(
              children: [
                const Icon(Icons.home, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  schedule['title'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              schedule['inventory'],
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Address',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (schedule['status'] == 1)
              CustomButton(
                buttonText: 'Start Schedule',
                onPressed: () async {
                  await _startSchedule(schedule);
                },
                height: 40,
                width: 150,
                radius: 10,
              ),
            if (schedule['status'] == 2)
              Row(
                children: [
                  const Text(
                    'Ongoing',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera),
                    color: const Color(0xFF107B8B),
                    onPressed: () async {
                      await _goToOPD(schedule);
                    },
                  ),
                ],
              ),
            if (schedule['status'] == 3)
              const Text(
                'OPD has ended',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (schedule['status'] == 4)
              const Text(
                'OPD Cancelled',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
