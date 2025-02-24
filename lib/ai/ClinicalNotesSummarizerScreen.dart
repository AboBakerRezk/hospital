import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Global constant: OpenAI API key
const String openAiApiKey =
    "sk-proj-Gjc9HykEBorx1xPZFkufi6xsXKtC5CNT5luhJ9msR-8L4Qz3ROd7jvO-haSCTu7fAsloL8u_svWCRtxV0aRFsA";

class ClinicalNotesSummarizerScreen extends StatefulWidget {
  const ClinicalNotesSummarizerScreen({Key? key}) : super(key: key);

  @override
  _ClinicalNotesSummarizerScreenState createState() => _ClinicalNotesSummarizerScreenState();
}

class _ClinicalNotesSummarizerScreenState extends State<ClinicalNotesSummarizerScreen> {
  final TextEditingController _notesController = TextEditingController();
  String _summary = "";
  bool _isLoading = false;

  /// Sends the clinical notes to OpenAI API for summarization.
  Future<void> _summarizeNotes() async {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) return;

    setState(() {
      _isLoading = true;
      _summary = "";
    });

    try {
      final url = Uri.parse("https://api.openai.com/v1/chat/completions");
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $openAiApiKey",
      };

      // Create a prompt asking to summarize the clinical notes.
      final prompt = "Summarize the following clinical notes into a concise summary that highlights key clinical findings and recommendations:\n\n$notes";

      final body = jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a helpful medical summarization assistant."},
          {"role": "user", "content": prompt}
        ],
        "max_tokens": 200,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        setState(() {
          _summary = content.trim();
        });
      } else {
        setState(() {
          _summary = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _summary = "Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clinical Notes Summarizer"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter Clinical Notes:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "Paste or type the clinical notes here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _summarizeNotes,
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
                "Summarize Notes",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Summary:",
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
                    _summary,
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
