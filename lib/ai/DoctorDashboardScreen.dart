import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ثابت يحوي المفتاح الخاص بك في OpenAI
const String openAiApiKey = "sk-proj-Gjc9HykEBorx1xPZFku3BlbkFJxJ8Yk3nwLoKnoOejl_gJN-QBr9nKQD8L4Qz3ROd7jvO-haSCTu7fAsloL8u_svWCRtxV0aRFsA";

class MedicationInteractionScreen extends StatefulWidget {
  const MedicationInteractionScreen({Key? key}) : super(key: key);

  @override
  State<MedicationInteractionScreen> createState() => _MedicationInteractionScreenState();
}

class _MedicationInteractionScreenState extends State<MedicationInteractionScreen> {
  final TextEditingController _drugsController = TextEditingController();
  String _result = "";
  bool _isLoading = false;

  /// الدالة التي تتعامل مع OpenAI للحصول على تفاعلات الأدوية
  Future<void> _checkInteractions() async {
    final drugsList = _drugsController.text.trim();
    if (drugsList.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = "";
    });

    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiApiKey',
      };
      final body = jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content": "You are a medical assistant focusing on medication interactions. Provide warnings and suggestions for drug interactions or contradictions based on the user input."
          },
          {
            "role": "user",
            "content": "Check drug interactions for: $drugsList"
          }
        ],
        "max_tokens": 200,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        setState(() {
          _result = content.trim();
        });
      } else {
        setState(() {
          _result = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _drugsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تصميم يعتمد على لونين أخضر وأبيض
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Interaction Checker'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter the drugs or conditions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _drugsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Aspirin, Lisinopril, Diabetes type 2...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkInteractions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Check Interactions', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            const Text(
              "Results:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
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
                    _result,
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
