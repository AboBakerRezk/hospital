import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../ai/ai_service.dart';
import '../data/db_helper.dart'; // يحتوي على DBHelper ونموذج Patient

class PatientsListScreen extends StatefulWidget {
  @override
  _PatientsListScreenState createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Patient> _patients = [];
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _prepopulateIfEmpty(); // اختياري لتعبئة بيانات افتراضية إذا كانت قاعدة البيانات فارغة
  }

  Future<void> _prepopulateIfEmpty() async {
    final data = await _dbHelper.getAllPatients();
    if (data.isEmpty) {
      await _dbHelper.insertPatient(Patient(
        name: "John Doe",
        age: 45,
        condition: "Hypertension",
        systolicBP: 130,
        diastolicBP: 85,
        heartRate: 75,
        weight: 80,
        height: 175,
        temperature: 36.8,
        respiratoryRate: 18,
        cholesterol: 200,
        bloodSugar: 110,
        oxygenSaturation: 98,
        smokingStatus: "Non-Smoker",
        exerciseFrequency: "Regular",
        medicalHistory: "None significant",
        medications: "Atenolol",
        notes: "Patient is stable",
        analysisResult: "Risk analysis: Moderate risk. Follow up required.",
        filePath: "",
      ));
      await _fetchPatients();
    }
  }

  Future<void> _fetchPatients() async {
    final data = await _dbHelper.getAllPatients();
    setState(() {
      _patients = data;
    });
  }

  List<Patient> _filteredPatients() {
    if (_searchQuery.isEmpty) return _patients;
    return _patients.where((patient) =>
        patient.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Future<bool> _confirmDelete(String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Patient'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _deletePatient(int id) async {
    await _dbHelper.deletePatient(id);
    await _fetchPatients();
  }

  Future<void> _addPatientDialog() async {
    // Controllers for required fields
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController conditionController = TextEditingController();
    final TextEditingController systolicBPController = TextEditingController();
    final TextEditingController diastolicBPController = TextEditingController();
    final TextEditingController heartRateController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController temperatureController = TextEditingController();
    final TextEditingController respiratoryRateController = TextEditingController();
    final TextEditingController cholesterolController = TextEditingController();
    final TextEditingController bloodSugarController = TextEditingController();
    final TextEditingController oxygenSaturationController = TextEditingController();
    final TextEditingController smokingStatusController = TextEditingController();
    final TextEditingController exerciseFrequencyController = TextEditingController();
    final TextEditingController medicalHistoryController = TextEditingController();
    final TextEditingController medicationsController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController manualTextController = TextEditingController();

    String? selectedFilePath;
    bool isAnalyzing = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          Future<void> _pickPdfFile() async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );
            if (result != null && result.files.single.path != null) {
              setStateDialog(() {
                selectedFilePath = result.files.single.path!;
              });
            }
          }

          Future<void> handlePdfOrText(int patientId) async {
            try {
              String textToAnalyze = manualTextController.text.trim();
              if (textToAnalyze.isEmpty && selectedFilePath != null) {
                // Here you can extract real text from the PDF using a dedicated library.
                textToAnalyze = "Sample text extracted from PDF: $selectedFilePath";
              }
              // Ensure required fields are filled
              if (nameController.text.trim().isEmpty ||
                  ageController.text.trim().isEmpty ||
                  conditionController.text.trim().isEmpty ||
                  systolicBPController.text.trim().isEmpty ||
                  diastolicBPController.text.trim().isEmpty ||
                  heartRateController.text.trim().isEmpty ||
                  weightController.text.trim().isEmpty ||
                  heightController.text.trim().isEmpty ||
                  temperatureController.text.trim().isEmpty ||
                  respiratoryRateController.text.trim().isEmpty ||
                  cholesterolController.text.trim().isEmpty ||
                  bloodSugarController.text.trim().isEmpty ||
                  oxygenSaturationController.text.trim().isEmpty ||
                  smokingStatusController.text.trim().isEmpty ||
                  exerciseFrequencyController.text.trim().isEmpty ||
                  medicalHistoryController.text.trim().isEmpty ||
                  medicationsController.text.trim().isEmpty ||
                  notesController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }
              if (textToAnalyze.isEmpty) return;
              setStateDialog(() {
                isAnalyzing = true;
              });
              final analysis = await AIService.analyzeText(textToAnalyze);
              await _dbHelper.updatePatient(patientId, Patient(
                name: nameController.text.trim(),
                age: int.tryParse(ageController.text.trim()) ?? 0,
                condition: conditionController.text.trim(),
                systolicBP: int.tryParse(systolicBPController.text.trim()) ?? 0,
                diastolicBP: int.tryParse(diastolicBPController.text.trim()) ?? 0,
                heartRate: int.tryParse(heartRateController.text.trim()) ?? 0,
                weight: double.tryParse(weightController.text.trim()) ?? 0,
                height: double.tryParse(heightController.text.trim()) ?? 0,
                temperature: double.tryParse(temperatureController.text.trim()) ?? 0,
                respiratoryRate: int.tryParse(respiratoryRateController.text.trim()) ?? 0,
                cholesterol: int.tryParse(cholesterolController.text.trim()) ?? 0,
                bloodSugar: int.tryParse(bloodSugarController.text.trim()) ?? 0,
                oxygenSaturation: int.tryParse(oxygenSaturationController.text.trim()) ?? 0,
                smokingStatus: smokingStatusController.text.trim(),
                exerciseFrequency: exerciseFrequencyController.text.trim(),
                medicalHistory: medicalHistoryController.text.trim(),
                medications: medicationsController.text.trim(),
                notes: notesController.text.trim(),
                analysisResult: analysis,
                filePath: selectedFilePath ?? '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error during analysis: $e')),
              );
            } finally {
              setStateDialog(() {
                isAnalyzing = false;
              });
            }
          }

          return AlertDialog(
            title: Text('Add New Patient'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Required fields
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name *'),
                  ),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Age *'),
                  ),
                  TextField(
                    controller: conditionController,
                    decoration: InputDecoration(labelText: 'Condition *'),
                  ),
                  TextField(
                    controller: systolicBPController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Systolic BP *'),
                  ),
                  TextField(
                    controller: diastolicBPController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Diastolic BP *'),
                  ),
                  TextField(
                    controller: heartRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Heart Rate *'),
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Weight (kg) *'),
                  ),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Height (cm) *'),
                  ),
                  TextField(
                    controller: temperatureController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Temperature (°C) *'),
                  ),
                  TextField(
                    controller: respiratoryRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Respiratory Rate *'),
                  ),
                  TextField(
                    controller: cholesterolController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Cholesterol *'),
                  ),
                  TextField(
                    controller: bloodSugarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Blood Sugar *'),
                  ),
                  TextField(
                    controller: oxygenSaturationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Oxygen Saturation *'),
                  ),
                  TextField(
                    controller: smokingStatusController,
                    decoration: InputDecoration(labelText: 'Smoking Status *'),
                  ),
                  TextField(
                    controller: exerciseFrequencyController,
                    decoration: InputDecoration(labelText: 'Exercise Frequency *'),
                  ),
                  TextField(
                    controller: medicalHistoryController,
                    decoration: InputDecoration(labelText: 'Medical History *'),
                  ),
                  TextField(
                    controller: medicationsController,
                    decoration: InputDecoration(labelText: 'Medications *'),
                  ),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(labelText: 'Notes *'),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Text(
                    'Upload a PDF file or enter manual text for AI analysis:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickPdfFile,
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('Select PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[600],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedFilePath ?? 'No file selected',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: manualTextController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Manual text (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (isAnalyzing) CircularProgressIndicator(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isAnalyzing
                    ? null
                    : () async {
                  if (nameController.text.trim().isEmpty ||
                      ageController.text.trim().isEmpty ||
                      conditionController.text.trim().isEmpty ||
                      systolicBPController.text.trim().isEmpty ||
                      diastolicBPController.text.trim().isEmpty ||
                      heartRateController.text.trim().isEmpty ||
                      weightController.text.trim().isEmpty ||
                      heightController.text.trim().isEmpty ||
                      temperatureController.text.trim().isEmpty ||
                      respiratoryRateController.text.trim().isEmpty ||
                      cholesterolController.text.trim().isEmpty ||
                      bloodSugarController.text.trim().isEmpty ||
                      oxygenSaturationController.text.trim().isEmpty ||
                      smokingStatusController.text.trim().isEmpty ||
                      exerciseFrequencyController.text.trim().isEmpty ||
                      medicalHistoryController.text.trim().isEmpty ||
                      medicationsController.text.trim().isEmpty ||
                      notesController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all required fields')),
                    );
                    return;
                  }
                  // Insert new patient first
                  int newId = await _dbHelper.insertPatient(Patient(
                    name: nameController.text.trim(),
                    age: int.tryParse(ageController.text.trim()) ?? 0,
                    condition: conditionController.text.trim(),
                    systolicBP: int.tryParse(systolicBPController.text.trim()) ?? 0,
                    diastolicBP: int.tryParse(diastolicBPController.text.trim()) ?? 0,
                    heartRate: int.tryParse(heartRateController.text.trim()) ?? 0,
                    weight: double.tryParse(weightController.text.trim()) ?? 0,
                    height: double.tryParse(heightController.text.trim()) ?? 0,
                    temperature: double.tryParse(temperatureController.text.trim()) ?? 0,
                    respiratoryRate: int.tryParse(respiratoryRateController.text.trim()) ?? 0,
                    cholesterol: int.tryParse(cholesterolController.text.trim()) ?? 0,
                    bloodSugar: int.tryParse(bloodSugarController.text.trim()) ?? 0,
                    oxygenSaturation: int.tryParse(oxygenSaturationController.text.trim()) ?? 0,
                    smokingStatus: smokingStatusController.text.trim(),
                    exerciseFrequency: exerciseFrequencyController.text.trim(),
                    medicalHistory: medicalHistoryController.text.trim(),
                    medications: medicationsController.text.trim(),
                    notes: notesController.text.trim(),
                  ));
                  await handlePdfOrText(newId);
                  Navigator.pop(ctx);
                  await _fetchPatients();
                },
                child: Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _editPatientDialog(Patient patient) async {
    final TextEditingController nameController =
    TextEditingController(text: patient.name);
    final TextEditingController ageController =
    TextEditingController(text: patient.age.toString());
    final TextEditingController conditionController =
    TextEditingController(text: patient.condition);
    final TextEditingController systolicBPController =
    TextEditingController(text: patient.systolicBP.toString());
    final TextEditingController diastolicBPController =
    TextEditingController(text: patient.diastolicBP.toString());
    final TextEditingController heartRateController =
    TextEditingController(text: patient.heartRate.toString());
    final TextEditingController weightController =
    TextEditingController(text: patient.weight.toString());
    final TextEditingController heightController =
    TextEditingController(text: patient.height.toString());
    final TextEditingController temperatureController =
    TextEditingController(text: patient.temperature.toString());
    final TextEditingController respiratoryRateController =
    TextEditingController(text: patient.respiratoryRate.toString());
    final TextEditingController cholesterolController =
    TextEditingController(text: patient.cholesterol.toString());
    final TextEditingController bloodSugarController =
    TextEditingController(text: patient.bloodSugar.toString());
    final TextEditingController oxygenSaturationController =
    TextEditingController(text: patient.oxygenSaturation.toString());
    final TextEditingController smokingStatusController =
    TextEditingController(text: patient.smokingStatus);
    final TextEditingController exerciseFrequencyController =
    TextEditingController(text: patient.exerciseFrequency);
    final TextEditingController medicalHistoryController =
    TextEditingController(text: patient.medicalHistory);
    final TextEditingController medicationsController =
    TextEditingController(text: patient.medications);
    final TextEditingController notesController =
    TextEditingController(text: patient.notes);
    final TextEditingController manualTextController = TextEditingController();

    String? selectedFilePath;
    bool isAnalyzing = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          Future<void> _pickPdfFile() async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );
            if (result != null && result.files.single.path != null) {
              setStateDialog(() {
                selectedFilePath = result.files.single.path!;
              });
            }
          }

          Future<void> handlePdfOrText() async {
            try {
              String textToAnalyze = manualTextController.text.trim();
              if (textToAnalyze.isEmpty && selectedFilePath != null) {
                textToAnalyze = "Sample text extracted from PDF: $selectedFilePath";
              }
              if (textToAnalyze.isEmpty) return;
              setStateDialog(() {
                isAnalyzing = true;
              });
              final analysis = await AIService.analyzeText(textToAnalyze);
              await _dbHelper.updatePatient(patient.id!, Patient(
                name: nameController.text.trim(),
                age: int.tryParse(ageController.text.trim()) ?? 0,
                condition: conditionController.text.trim(),
                systolicBP: int.tryParse(systolicBPController.text.trim()) ?? 0,
                diastolicBP: int.tryParse(diastolicBPController.text.trim()) ?? 0,
                heartRate: int.tryParse(heartRateController.text.trim()) ?? 0,
                weight: double.tryParse(weightController.text.trim()) ?? 0,
                height: double.tryParse(heightController.text.trim()) ?? 0,
                temperature: double.tryParse(temperatureController.text.trim()) ?? 0,
                respiratoryRate: int.tryParse(respiratoryRateController.text.trim()) ?? 0,
                cholesterol: int.tryParse(cholesterolController.text.trim()) ?? 0,
                bloodSugar: int.tryParse(bloodSugarController.text.trim()) ?? 0,
                oxygenSaturation: int.tryParse(oxygenSaturationController.text.trim()) ?? 0,
                smokingStatus: smokingStatusController.text.trim(),
                exerciseFrequency: exerciseFrequencyController.text.trim(),
                medicalHistory: medicalHistoryController.text.trim(),
                medications: medicationsController.text.trim(),
                notes: notesController.text.trim(),
                analysisResult: analysis,
                filePath: selectedFilePath ?? patient.filePath,
                createdAt: patient.createdAt,
                updatedAt: DateTime.now(),
              ));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error during analysis: $e')),
              );
            } finally {
              setStateDialog(() {
                isAnalyzing = false;
              });
            }
          }

          return AlertDialog(
            title: Text('Edit Patient Details'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name *'),
                  ),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Age *'),
                  ),
                  TextField(
                    controller: conditionController,
                    decoration: InputDecoration(labelText: 'Condition *'),
                  ),
                  TextField(
                    controller: systolicBPController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Systolic BP *'),
                  ),
                  TextField(
                    controller: diastolicBPController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Diastolic BP *'),
                  ),
                  TextField(
                    controller: heartRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Heart Rate *'),
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Weight (kg) *'),
                  ),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Height (cm) *'),
                  ),
                  TextField(
                    controller: temperatureController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Temperature (°C) *'),
                  ),
                  TextField(
                    controller: respiratoryRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Respiratory Rate *'),
                  ),
                  TextField(
                    controller: cholesterolController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Cholesterol *'),
                  ),
                  TextField(
                    controller: bloodSugarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Blood Sugar *'),
                  ),
                  TextField(
                    controller: oxygenSaturationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Oxygen Saturation *'),
                  ),
                  TextField(
                    controller: smokingStatusController,
                    decoration: InputDecoration(labelText: 'Smoking Status *'),
                  ),
                  TextField(
                    controller: exerciseFrequencyController,
                    decoration: InputDecoration(labelText: 'Exercise Frequency *'),
                  ),
                  TextField(
                    controller: medicalHistoryController,
                    decoration: InputDecoration(labelText: 'Medical History *'),
                  ),
                  TextField(
                    controller: medicationsController,
                    decoration: InputDecoration(labelText: 'Medications *'),
                  ),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(labelText: 'Notes *'),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Text(
                    'Upload a PDF file or enter manual text for AI analysis:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickPdfFile,
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('Select PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[600],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedFilePath ?? 'No file selected',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: manualTextController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Manual text (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (isAnalyzing) CircularProgressIndicator(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Save basic changes only
                  await _dbHelper.updatePatient(patient.id!, Patient(
                    name: nameController.text.trim(),
                    age: int.tryParse(ageController.text.trim()) ?? 0,
                    condition: conditionController.text.trim(),
                    systolicBP: int.tryParse(systolicBPController.text.trim()) ?? 0,
                    diastolicBP: int.tryParse(diastolicBPController.text.trim()) ?? 0,
                    heartRate: int.tryParse(heartRateController.text.trim()) ?? 0,
                    weight: double.tryParse(weightController.text.trim()) ?? 0,
                    height: double.tryParse(heightController.text.trim()) ?? 0,
                    temperature: double.tryParse(temperatureController.text.trim()) ?? 0,
                    respiratoryRate: int.tryParse(respiratoryRateController.text.trim()) ?? 0,
                    cholesterol: int.tryParse(cholesterolController.text.trim()) ?? 0,
                    bloodSugar: int.tryParse(bloodSugarController.text.trim()) ?? 0,
                    oxygenSaturation: int.tryParse(oxygenSaturationController.text.trim()) ?? 0,
                    smokingStatus: smokingStatusController.text.trim(),
                    exerciseFrequency: exerciseFrequencyController.text.trim(),
                    medicalHistory: medicalHistoryController.text.trim(),
                    medications: medicationsController.text.trim(),
                    notes: notesController.text.trim(),
                    analysisResult: patient.analysisResult,
                    filePath: patient.filePath,
                    createdAt: patient.createdAt,
                    updatedAt: DateTime.now(),
                  ));
                  Navigator.pop(ctx);
                  await _fetchPatients();
                },
                child: Text('Save Only'),
              ),
              ElevatedButton(
                onPressed: isAnalyzing
                    ? null
                    : () async {
                  // Update basic data
                  await _dbHelper.updatePatient(patient.id!, Patient(
                    name: nameController.text.trim(),
                    age: int.tryParse(ageController.text.trim()) ?? 0,
                    condition: conditionController.text.trim(),
                    systolicBP: int.tryParse(systolicBPController.text.trim()) ?? 0,
                    diastolicBP: int.tryParse(diastolicBPController.text.trim()) ?? 0,
                    heartRate: int.tryParse(heartRateController.text.trim()) ?? 0,
                    weight: double.tryParse(weightController.text.trim()) ?? 0,
                    height: double.tryParse(heightController.text.trim()) ?? 0,
                    temperature: double.tryParse(temperatureController.text.trim()) ?? 0,
                    respiratoryRate: int.tryParse(respiratoryRateController.text.trim()) ?? 0,
                    cholesterol: int.tryParse(cholesterolController.text.trim()) ?? 0,
                    bloodSugar: int.tryParse(bloodSugarController.text.trim()) ?? 0,
                    oxygenSaturation: int.tryParse(oxygenSaturationController.text.trim()) ?? 0,
                    smokingStatus: smokingStatusController.text.trim(),
                    exerciseFrequency: exerciseFrequencyController.text.trim(),
                    medicalHistory: medicalHistoryController.text.trim(),
                    medications: medicationsController.text.trim(),
                    notes: notesController.text.trim(),
                    analysisResult: patient.analysisResult,
                    filePath: patient.filePath,
                    createdAt: patient.createdAt,
                    updatedAt: DateTime.now(),
                  ));
                  // Then perform AI analysis
                  await handlePdfOrText();
                  Navigator.pop(ctx);
                  await _fetchPatients();
                },
                child: Text('Upload/Analyze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPatients();

    return Scaffold(
      appBar: AppBar(
        title: Text('Patients List (Hive)'),
        backgroundColor: Colors.teal[700],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patient...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPatients,
        child: filtered.isEmpty
            ? ListView(
          children: [
            SizedBox(height: 200),
            Center(child: Text('No patients found.')),
          ],
        )
            : ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final patient = filtered[index];
            return Dismissible(
              key: Key(patient.id.toString()),
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _confirmDelete(patient.name),
              onDismissed: (_) async {
                await _deletePatient(patient.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${patient.name}"')),
                );
              },
              child: Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.teal[700]),
                  title: Text(patient.name),
                  subtitle: Text('Age: ${patient.age} - ${patient.condition}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _editPatientDialog(patient),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/patientDetail',
                      arguments: {'id': patient.id},
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        child: Icon(Icons.add),
        onPressed: _addPatientDialog,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal[700],
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/patients');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
      ),
    );
  }
}
