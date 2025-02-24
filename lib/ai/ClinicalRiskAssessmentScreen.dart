import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Global constant: OpenAI API key.
const String openAiApiKey =
    "sk-proj-Gjc9HykEBorx1xPZFkufi6xsXKtC5CNT5luhJ9msR-BRPf-QBr9nKQD8L4Qz3ROd7jvO-haSCTu7fAsloL8u_svWCRtxV0aRFsA";

class ClinicalRiskAssessmentScreen extends StatefulWidget {
  const ClinicalRiskAssessmentScreen({Key? key}) : super(key: key);

  @override
  _ClinicalRiskAssessmentScreenState createState() =>
      _ClinicalRiskAssessmentScreenState();
}

class _ClinicalRiskAssessmentScreenState
    extends State<ClinicalRiskAssessmentScreen> {
  // Controllers for numeric inputs.
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _cholesterolController = TextEditingController();

  // Dropdown selections.
  String _smokingStatus = 'Non-Smoker';
  String _diabetesStatus = 'No';

  String _riskResult = "";
  bool _isLoading = false;

  /// Calculate risk by sending a prompt to the OpenAI API.
  Future<void> _calculateRisk() async {
    final age = _ageController.text.trim();
    final systolic = _systolicController.text.trim();
    final cholesterol = _cholesterolController.text.trim();

    if (age.isEmpty || systolic.isEmpty || cholesterol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _riskResult = "";
    });

    try {
      final prompt =
          "Evaluate the risk of coronary heart disease for a patient with the following details:\n"
          "Age: $age years\n"
          "Systolic Blood Pressure: $systolic mmHg\n"
          "Cholesterol Level: $cholesterol mg/dL\n"
          "Smoking Status: $_smokingStatus\n"
          "Diabetes: $_diabetesStatus\n"
          "Provide a risk percentage and a brief recommendation.";

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
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
            "You are a clinical decision support assistant for doctors. Provide clear and concise risk assessment and recommendations."
          },
          {"role": "user", "content": prompt}
        ],
        "max_tokens": 200,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        setState(() {
          _riskResult = content.trim();
        });
      } else {
        setState(() {
          _riskResult = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _riskResult = "Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _systolicController.dispose();
    _cholesterolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Green and white design scheme.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clinical Risk Assessment"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enter Patient Data",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            // Age field
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Systolic BP field
            TextField(
              controller: _systolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Systolic BP (mmHg)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cholesterol field
            TextField(
              controller: _cholesterolController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Cholesterol (mg/dL)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Smoking Status Dropdown
            DropdownButtonFormField<String>(
              value: _smokingStatus,
              decoration: InputDecoration(
                labelText: "Smoking Status",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['Non-Smoker', 'Smoker']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _smokingStatus = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            // Diabetes Status Dropdown
            DropdownButtonFormField<String>(
              value: _diabetesStatus,
              decoration: InputDecoration(
                labelText: "Diabetes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['No', 'Yes']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _diabetesStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            // Calculate Risk Button
            ElevatedButton(
              onPressed: _isLoading ? null : _calculateRisk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                "Calculate Risk",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Risk Assessment:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            // Modified result container with increased font size and more room.
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _riskResult,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
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
