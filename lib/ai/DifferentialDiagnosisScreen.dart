import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Global constant: OpenAI API key.
const String openAiApiKey =
    "sk-proj-Gjc9HykEBorx1xPZFkufi6xsXejl_gJN-QBr9nKQD8L4Qz3ROd7jvO-haSCTu7fAsloL8u_svWCRtxV0aRFsA";

class DifferentialDiagnosisScreen extends StatefulWidget {
  const DifferentialDiagnosisScreen({Key? key}) : super(key: key);

  @override
  _DifferentialDiagnosisScreenState createState() => _DifferentialDiagnosisScreenState();
}

class _DifferentialDiagnosisScreenState extends State<DifferentialDiagnosisScreen> {
  // Controllers for input fields.
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _labsController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  String _diagnosisResult = "";
  bool _isLoading = false;

  /// Sends the clinical data to OpenAI API and fetches differential diagnosis.
  Future<void> _getDifferentialDiagnosis() async {
    final symptoms = _symptomsController.text.trim();
    final labs = _labsController.text.trim();
    final additional = _infoController.text.trim();

    if (symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the patient's symptoms.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _diagnosisResult = "";
    });

    try {
      final prompt =
          "Based on the following clinical data, provide a differential diagnosis along with recommendations for further evaluation:\n"
          "Symptoms: $symptoms\n"
          "Lab Findings: $labs\n"
          "Additional Information: $additional";

      final url = Uri.parse("https://api.openai.com/v1/chat/completions");
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $openAiApiKey",
      };

      final body = jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content":
            "You are a clinical assistant providing differential diagnosis for doctors. Give a concise list of possible diagnoses and next steps."
          },
          {"role": "user", "content": prompt}
        ],
        "max_tokens": 250,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        setState(() {
          _diagnosisResult = content.trim();
        });
      } else {
        setState(() {
          _diagnosisResult = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _diagnosisResult = "Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _labsController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using green and white colors for a professional look.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Differential Diagnosis Assistant"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter Clinical Data:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _symptomsController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Symptoms",
                hintText: "e.g., Chest pain, shortness of breath",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labsController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Lab Findings",
                hintText: "e.g., BP: 140/90, Cholesterol: 220 mg/dL",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _infoController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Additional Information",
                hintText: "e.g., Patient has a history of hypertension",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _getDifferentialDiagnosis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                "Get Differential Diagnosis",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Results:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _diagnosisResult,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
