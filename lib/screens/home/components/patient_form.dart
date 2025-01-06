import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:campapplication/screens/home/buttons.dart';
import 'package:campapplication/screens/home/components/constans.dart';

class AddPatientForm extends StatefulWidget {
  final int scheduleID;
  final int phelboID;
  final int doctorID;
  final String doctorName;
  final String token;
  final VoidCallback onPatientAdded;

  const AddPatientForm({
    super.key,
    required this.scheduleID,
    required this.phelboID,
    required this.doctorID,
    required this.doctorName,
    required this.token,
    required this.onPatientAdded,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddPatientFormState createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<AddPatientForm> {
  final _formKey = GlobalKey<FormState>();
  // final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _voidedVolumeController = TextEditingController();
  final _maxFlowRateController = TextEditingController();
  final _avgFlowRateController = TextEditingController();
  // final _voidingTimeController = TextEditingController();
  // final _flowTimeController = TextEditingController();
  // final _timeToMaxController = TextEditingController();
  // final _hesitancyController = TextEditingController();
  bool _diabetes = false;
  bool _bp = false;
  bool _obesity = false;
  String _gender = 'Male';
  // String? _consentFilePath;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var baseUrl = Uri.parse('http://ciplaxyz.$kUrl/insert_patient_master/');
      try {
        final response = await http.post(
          baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: json.encode({
            'schedular': widget.scheduleID,
            'phelbo': widget.phelboID,
            'doctor': widget.doctorID,
            'age': _ageController.text,
            'gender': _gender,
            'uid': 123,
            // Uncomment these lines when you are ready to use these fields
            // 'voided_volume': double.tryParse(_voidedVolumeController.text),
            // 'max_flow_rate': int.tryParse(_maxFlowRateController.text),
            // 'avg_flow_rate': int.tryParse(_avgFlowRateController.text),
            // 'voiding_time': int.tryParse(_voidingTimeController.text),
            // 'flow_time': int.tryParse(_flowTimeController.text),
            // 'time_to_max': int.tryParse(_timeToMaxController.text),
            // 'hesitancy': int.tryParse(_hesitancyController.text),
            // 'diabetes': _diabetes,
            // 'bp': _bp,
            // 'obesity': _obesity,
          }),
        );
        if (response.statusCode == 201) {
          successBar(
            // ignore: use_build_context_synchronously
            context,
            message: 'Patient Added Successfully',
            color: Colors.green,
          );
          widget.onPatientAdded();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        } else {
          successBar(
            // ignore: use_build_context_synchronously
            context,
            message: 'Failed to add patient',
            color: Colors.red,
          );
        }
      } catch (e) {
        successBar(
          // ignore: use_build_context_synchronously
          context,
          message: 'Error occurred:',
          color: Colors.red,
        );
      }
    }
  }

  Future<void> _pickConsentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        // _consentFilePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF107B8B),
        title: const Text(
          'Add Patient',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField(_ageController, 'Age', 'Please enter age'),
                const SizedBox(height: 16),
                _buildGenderSelection(),
                const SizedBox(height: 16),
                _buildTextFormField(_voidedVolumeController, 'Voided Volume',
                    'Please enter voided volume'),
                const SizedBox(height: 16),
                _buildTextFormField(
                    _maxFlowRateController, 'Max Flow Rate (seconds)'),
                const SizedBox(height: 16),
                _buildTextFormField(
                    _avgFlowRateController, 'Average Flow Rate (seconds)'),
                const SizedBox(height: 16),
                _buildSwitchTile('Diabetes', _diabetes,
                    (value) => setState(() => _diabetes = value)),
                _buildSwitchTile(
                    'BP', _bp, (value) => setState(() => _bp = value)),
                _buildSwitchTile('Obesity', _obesity,
                    (value) => setState(() => _obesity = value)),
                const SizedBox(height: 24),
                Center(
                  child: CustomButton(
                    buttonText: 'Add Patient',
                    onPressed: _submitForm,
                    height: 45,
                    width: 200,
                    radius: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      [String? validatorMessage]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (validatorMessage != null && (value == null || value.isEmpty)) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        const Text(
          'Gender',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRadioOption('Male'),
              _buildRadioOption('Female'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value) {
    return Row(
      children: [
        Radio<String>(
          fillColor: WidgetStateProperty.all(Colors.teal),
          value: value,
          groupValue: _gender,
          onChanged: (value) {
            setState(() {
              _gender = value!;
            });
          },
        ),
        Text(value),
      ],
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      activeColor: Colors.teal,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
