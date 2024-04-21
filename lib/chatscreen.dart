import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final String apiKey =
      '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';
  List<Message> messages = [];
  late ScrollController _scrollController;
  bool _isListening = false;

    Future<void> setFanStatus(int status) async {
    final url = Uri.parse('http://192.168.224.140/setStatus');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'fanStatus': status});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Fan status set successfully');
    } else {
      throw Exception('Failed to set Fan status');
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _toggleListening() {
    if (!_isListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }

void _startListening() async {
  if (await _speech.initialize()) {
    setState(() {
      _isListening = true;
    });

    while (_isListening) {
      await _speech.listen(
        onResult: (result) {
          print('Result: ${result.recognizedWords}');
          setState(() {
            _controller.text = result.recognizedWords; // Set recognized text to text field
          });
          if (result.finalResult && _controller.text.isNotEmpty) {
            sendMessage(_controller.text);
            _controller.clear();
          }
        },
        onSoundLevelChange: (level) {
          // Handle sound level changes
        },
      );
    }
  }
}


  void _stopListening() {
    if (_speech.isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> sendMessage(String message) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final requestBody = jsonEncode({
      "messages": [
        {
          "role": "system",
          "content":
              "From the message only tell me either Hot Room if its about being warm in the room, Cold Room if it's about being chilly in the room and Unspecified if it is not about a room or the temperature is neutral, only write Hot Room , Cold Room or Unspecified and nothing else "
        },
        {"role": "user", "content": message}
      ],
      "model": "mixtral-8x7b-32768",
      "temperature": 0,
      "max_tokens": 8,
      "top_p": 1,
      "stream": false,
      "stop": null
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseData =
          jsonDecode(response.body)['choices'][0]['message']['content'];
      setState(() {
        messages.add(Message(role: 'user', content: message));
        messages.add(Message(role: 'system', content: responseData));
      });
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
          if (responseData.contains("Hot Room")) {
            print('HOTHOTHOTHOTHOTHOTHOTHOTHOTHOTHOTHOTHOTHOT');
      await setFanStatus(1);
    } else 
          if (responseData.contains("Cold Room")){
            print('COLDCOLDCOLDCOLDCOLDCOLDCOLDCOLDCOLDCOLDCOLDCOLDCOLDCOLDCOLD');
      await setFanStatus(0);
    }
    } else {
      setState(() {
        messages.add(Message(
            role: 'system',
            content: 'Failed to send message: ${response.statusCode}'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Astrid AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message.role == 'user'
                      ? 'You: ${message.content}'
                      : 'Astrid AI: ${message.content}'),
                );
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
                onPressed: _toggleListening,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Type a message...'),
                    onSubmitted: (message) {
                      sendMessage(message);
                      _controller.clear();
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
