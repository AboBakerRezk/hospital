// services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AIService {
  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";

  /// Sends a message to the AI model (ChatGPT) and returns its response.
  static Future<String> sendMessageToAI(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": message}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.trim();
      } else {
        return "An error occurred: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      return "Connection error: $e";
    }
  }

  /// Analyzes a given text using OpenAI, returning the analysis in English.
  static Future<String> analyzeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
              "You are a virtual assistant specialized in analyzing medical documents. Please provide a clear and concise analysis in English."
            },
            {
              "role": "user",
              "content": "Please analyze the following document/text:\n$text"
            }
          ],
          "max_tokens": 400,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.trim();
      } else {
        return "An error occurred while connecting to OpenAI: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection error: $e";
    }
  }
}
