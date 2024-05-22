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
  List<Message> messages = [];
  late ScrollController _scrollController;
  bool _isListening = false;

  Future<void> setFanStatus(int status) async {
    final url = Uri.parse('http://192.168.3.140/setStatus');
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
              _controller.text =
                  result.recognizedWords; // Set recognized text to text field
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
    final url = Uri.parse('https://astriai.openai.azure.com/openai/deployments/40Astri/chat/completions?api-version=2024-02-15-preview');

    final requestBody = jsonEncode({
      "messages": [
        {
          "role": "system",
          "content":
              "Classify the provided text into one exclusive category: 'Hot Room' if the text discusses the temperature of a room, 'Cold Room' if the text discusses the temperature of a room, or 'Unspecified' if the content does not relate to room temperature or a room in general. The classification should be precise, selecting only one category without any additional information or explanations."
        },
        {"role": "user", "content": message}
      ],
      "max_tokens": 8,
      "temperature": 0.7,
      "frequency_penalty": 0,
      "presence_penalty": 0,
      "top_p": 0.95,
      "stop": null
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'api-key': '68da0d7eea374f06826d2a055c954b70',
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
      } else if (responseData.contains("Cold Room")) {
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Color(0xFFD4145A), Color(0xFFFBB03B)],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(
              'Astrid AI',
              style: TextStyle(
                color: Colors.transparent, // Transparent text color
                fontFamily: '', // Custom font
                fontWeight: FontWeight.bold, // Make it bold
                letterSpacing: 2.0, // Add some letter spacing
                shadows: [
                  Shadow(
                    blurRadius: 0.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFBB03B), Color.fromARGB(255, 255, 249, 221)],
              ),
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor:
            Color.fromARGB(255, 255, 249, 221), // Set background color to white
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ListTile(
                    title: Text(
                      message.role == 'user'
                          ? 'You: ${message.content}'
                          : 'Astrid AI: ${message.content}',
                      style: TextStyle(
                        color: Color(0xFFD4145A),
                        backgroundColor: Color.fromARGB(255, 255, 249, 221),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
                  onPressed: _toggleListening,
                  color: Color(0xFFFBB03B),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Type a message...',
                        labelStyle: TextStyle(color: Color(0xFFD4145A)),
                      ),
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
      ),
    );
  }
}
