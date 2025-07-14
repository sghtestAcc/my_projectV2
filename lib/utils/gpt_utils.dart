import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Utility function to translate text using GPT API.
Future<String> translateWithGPT(String text,
    {String targetLanguage = "English"}) async {
  final String? apiKey = dotenv.env['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('❌ OpenAI API key not found in .env file');
  }

  print("📤 Calling GPT to translate to $targetLanguage: $text");

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a translation assistant."},
        {
          "role": "user",
          "content": "Translate the following to $targetLanguage:\n$text"
        }
      ]
    }),
  );

  if (response.statusCode == 200) {
    final decoded =
        utf8.decode(response.bodyBytes); // Handle UTF8 characters like Chinese
    final data = jsonDecode(decoded);
    final translatedText = data['choices'][0]['message']['content'].trim();
    print("✅ Translated result: $translatedText");
    return translatedText;
  } else {
    print("❌ Translation failed: ${response.statusCode} - ${response.body}");
    return text; // Fallback to original
  }
}
