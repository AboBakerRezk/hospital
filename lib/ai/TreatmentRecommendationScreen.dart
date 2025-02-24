import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Global constants
const String openAiApiKey =
    "sk-proj-Gjc9HykEBorx1xPZFkufi6xsXKtC5CNTejl_gJN-QBr9nKQD8L4Qz3ROd7jvO-haSCTu7fAsloL8u_svWCRtxV0aRFsA";

class TreatmentRecommendationScreen extends StatefulWidget {
  const TreatmentRecommendationScreen({Key? key}) : super(key: key);

  @override
  _TreatmentRecommendationScreenState createState() =>
      _TreatmentRecommendationScreenState();
}

class _TreatmentRecommendationScreenState
    extends State<TreatmentRecommendationScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _labValuesController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();

  String _recommendation = "";
  bool _isLoading = false;

  /// Send patient data to OpenAI API to generate a treatment recommendation.
  Future<void> _generateRecommendation() async {
    final symptoms = _symptomsController.text.trim();
    final labValues = _labValuesController.text.trim();
    final history = _historyController.text.trim();

    if (symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter patient symptoms.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recommendation = "";
    });

    try {
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
            "You are a clinical decision support assistant for doctors. Provide concise, evidence-based treatment recommendations and differential diagnoses based on the patient data provided."
          },
          {
            "role": "user",
            "content":
            "Patient Symptoms: $symptoms\nLab Values: $labValues\nPatient History: $history\nPlease provide a treatment recommendation and differential diagnosis."
          }
        ],
        "max_tokens": 300,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        setState(() {
          _recommendation = content.trim();
        });
      } else {
        setState(() {
          _recommendation =
          "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _recommendation = "Exception: $e";
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
    _labValuesController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The design uses green for primary elements and white for backgrounds.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Treatment Recommendation"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            TextField(
              controller: _symptomsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Symptoms",
                hintText:
                "e.g., Chest pain, shortness of breath, nausea",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labValuesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Lab Values",
                hintText:
                "e.g., BP: 140/90, Blood Sugar: 150 mg/dL",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _historyController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Patient History",
                hintText: "e.g., Hypertension, Diabetes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateRecommendation,
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
                "Generate Recommendation",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Recommendation:",
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
                    _recommendation,
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
