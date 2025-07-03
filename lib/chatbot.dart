import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotScreen extends StatefulWidget{
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  Future<void> _sendMessage() async {
    setState(() {
      _loading = true;
    });
    try {
      final reply = await fetchChatGPTResponse(_controller.text);
      setState(() {
        _response = reply;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Ask something...'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _sendMessage,
              child: _loading ? CircularProgressIndicator() : const Text('Send'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_response),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> fetchChatGPTResponse(String userMessage) async {
  final String? apiKey = dotenv.env['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('OpenAI API key not found');
  }

  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {"role": "user", "content": userMessage}
      ],
    }),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return responseData['choices'][0]['message']['content'];
  } else {
    // Print the error details for debugging
    print('OpenAI API error: ${response.statusCode} ${response.body}');
    throw Exception('Failed to load response: ${response.body}');
  }
}
