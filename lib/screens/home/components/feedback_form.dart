import 'dart:io';
import 'package:campapplication/screens/entryPoint/entry_point.dart';
import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/constans.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class FeedbackFormScreen extends StatefulWidget {
  final int scheduleID;
  final int phelboID;
  final int doctorID;
  final String token;
  final Map<String, dynamic> data;

  const FeedbackFormScreen({
    super.key,
    required this.data,
    required this.scheduleID,
    required this.phelboID,
    required this.doctorID,
    required this.token,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackFormScreenState createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile1;
  File? _selectedFile2;
  int? _selectedNumber;

  Future<void> _showPickerOptions(int fileNumber) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Choose an option',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.file_present, color: Colors.teal),
                title: const Text('Upload File'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFile(fileNumber);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.teal),
                title: const Text('Select Image'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, fileNumber);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Open Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, fileNumber);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile(int fileNumber) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (fileNumber == 1) {
          _selectedFile1 = File(result.files.single.path!);
        } else {
          _selectedFile2 = File(result.files.single.path!);
        }
      });
    } else {
      _showFeedbackMessage('No file selected', Colors.red);
    }
  }

  Future<void> _pickImage(ImageSource source, int fileNumber) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (fileNumber == 1) {
          _selectedFile1 = File(pickedFile.path);
        } else {
          _selectedFile2 = File(pickedFile.path);
        }
      });
    } else {
      _showFeedbackMessage('No image selected', Colors.red);
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState?.validate() == true &&
        (_selectedFile1 != null || _selectedFile2 != null)) {
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Confirm Submission",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: const Text(
              "Are you sure you want to submit the feedback?",
              style: TextStyle(color: Colors.black87),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              CustomButton(
                buttonText: 'Yes',
                onPressed: () => Navigator.of(context).pop(true),
                height: 40,
                width: 140,
                radius: 10,
              ),
            ],
          );
        },
      );

      if (!confirm) return;
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://ciplaxyz.$kUrl/end_schedule/${widget.scheduleID}/'),
      );
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.headers['Content-Type'] = 'multipart/form-data';

      request.fields['status'] = '3';
      request.fields['phlebo_id'] = widget.phelboID.toString();
      request.fields['patients_benefited'] = _selectedNumber.toString();

      if (_selectedFile1 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file1',
          _selectedFile1!.path,
        ));
      }
      if (_selectedFile2 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file2',
          _selectedFile2!.path,
        ));
      }

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          _showFeedbackMessage('Feedback submitted successfully', Colors.green);
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => EntryPoint(
                data: widget.data,
              ),
            ),
            (route) => false,
          );
        } else {
          _showFeedbackMessage(
              'Failed to submit feedback: $responseBody', Colors.red);
        }
      } catch (e) {
        _showFeedbackMessage('An error occurred', Colors.red);
      }
    } else {
      _showFeedbackMessage('Please fill in all mandatory fields', Colors.red);
    }
  }

  void _showFeedbackMessage(String message, Color color) {
    successBar(
      context,
      message: message,
      color: color,
    );
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF107B8B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      menuMaxHeight: 400.0,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Number of Patients Benefited',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                        ),
                      ),
                      value: _selectedNumber,
                      onChanged: (value) {
                        setState(() {
                          _selectedNumber = value;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(
                        10,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select the number of patients benefited';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _commentsController,
                      minLines: 4,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'Comments',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.teal, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _buildFileUploadSection(
                      'Upload Image or File 1',
                      _selectedFile1,
                      () => _showPickerOptions(1),
                    ),
                    const SizedBox(height: 20.0),
                    _buildFileUploadSection(
                      'Upload RX File',
                      _selectedFile2,
                      () => _showPickerOptions(2),
                    ),
                    const SizedBox(height: 30.0),
                    CustomButton(
                      buttonText: 'Submit Feedback',
                      onPressed: _submitFeedback,
                      height: 50,
                      width: double.infinity,
                      radius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection(String label, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.teal, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : Colors.teal,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                file != null
                    ? 'File Selected: ${file.path.split('/').last}'
                    : label,
                style: TextStyle(
                  color: file != null ? Colors.green : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
