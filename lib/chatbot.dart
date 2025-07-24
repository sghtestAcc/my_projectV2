import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "role": "system",
      "content": "You are a helpful assistant. Answer as clearly and concisely as possible."
    }
  ];
  bool _loading = false;

  Future<void> _sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty) return;
    setState(() {
      _loading = true;
      _messages.add({"role": "user", "content": userInput});
      _controller.clear();
    });
    try {
      final reply = await fetchChatGPTResponse(_messages);
      setState(() {
        _messages.add({"role": "assistant", "content": reply});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": 'Error: $e'});
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chatBot),
        backgroundColor: Color(0xFF0CE25C),
        foregroundColor: Colors.black,
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length - 1, // skip system message
                itemBuilder: (context, index) {
                  final msg = _messages[index + 1];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['content'] ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.typeYourMsg,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _loading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                        color: Colors.green,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> fetchChatGPTResponse(List<Map<String, String>> messages) async {
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
      'messages': messages,
    }),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return responseData['choices'][0]['message']['content'];
  } else {
    print('OpenAI API error: ${response.statusCode} ${response.body}');
    throw Exception('Failed to load response: ${response.body}');
  }
}
