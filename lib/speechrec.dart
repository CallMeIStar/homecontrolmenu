import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _stopListening = false;
  String _text = 'Press the button and say or type a word';
  List<String> _recognizedWords1 = [];
  List<String> _recognizedWords2 = [];
  List<String> _recognizedWords3 = [];
  List<String> _recognizedWords4 = [];
  Map<String, dynamic> foundWords = {};
  TextEditingController _textFieldController = TextEditingController();
  late SharedPreferences _prefs;

  Future<void> setElevatorStatus(int status) async {
    final url = Uri.parse('http://192.168.3.251/setestatus');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'estate': status});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Elevator status set successfully');
    } else {
      throw Exception('Failed to set Elevator status');
    }
  }

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
    _speech = stt.SpeechToText();
    _requestMicrophonePermission();
    _loadAddedWords();
  }

  void _loadAddedWords() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _recognizedWords1 = (_prefs.getStringList('recognizedWords1') ?? [])
          .map((word) => word.toLowerCase())
          .toList();
      _recognizedWords2 = (_prefs.getStringList('recognizedWords2') ?? [])
          .map((word) => word.toLowerCase())
          .toList();
      _recognizedWords3 = (_prefs.getStringList('recognizedWords3') ?? [])
          .map((word) => word.toLowerCase())
          .toList();
      _recognizedWords4 = (_prefs.getStringList('recognizedWords4') ?? [])
          .map((word) => word.toLowerCase())
          .toList();
    });
  }

  void _saveAddedWords() {
    _prefs.setStringList('recognizedWords1', _recognizedWords1);
    _prefs.setStringList('recognizedWords2', _recognizedWords2);
    _prefs.setStringList('recognizedWords3', _recognizedWords3);
    _prefs.setStringList('recognizedWords4', _recognizedWords4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Recognition'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [Color(0xFFD4145A), Color(0xFFFBB03B)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 80),
              ),
              Text(
                _text.toLowerCase(),
                style: TextStyle(color: Color.fromARGB(255, 44, 24, 0)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(
                  labelText: 'Add trigger words to recognize',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildAddButton(_recognizedWords1, 0),
                  _buildAddButton(_recognizedWords2, 1),
                  _buildAddButton(_recognizedWords3, 2),
                  _buildAddButton(_recognizedWords4, 3),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Last 5 Recognized Words:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                lastFiveRecognizedWords.isEmpty
                    ? 'No recognized words yet'
                    : '${lastFiveRecognizedWords.reversed.toList().join(' ')}',
                style: TextStyle(
                  color: Color.fromARGB(255, 44, 24, 0),
                  backgroundColor: Color.fromARGB(255, 255, 243, 190),
                ),
                textAlign: TextAlign.center,
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: _recognizedWords1.length +
                    _recognizedWords2.length +
                    _recognizedWords3.length +
                    _recognizedWords4.length +
                    1, // Add one for the added word
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: Text(
                        'Added Words: ${_textFieldController.text.toLowerCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  } else {
                    String word;
                    String listName;
                    if (index <= _recognizedWords1.length) {
                      word = _recognizedWords1[index - 1];
                      listName = 'Elevator Up';
                    } else if (index <=
                        _recognizedWords1.length + _recognizedWords2.length) {
                      word = _recognizedWords2[
                          index - _recognizedWords1.length - 1];
                      listName = 'Elevator Down';
                    } else if (index <=
                        _recognizedWords1.length +
                            _recognizedWords2.length +
                            _recognizedWords3.length) {
                      word = _recognizedWords3[index -
                          _recognizedWords1.length -
                          _recognizedWords2.length -
                          1];
                      listName = 'Fan On';
                    } else {
                      word = _recognizedWords4[index -
                          _recognizedWords1.length -
                          _recognizedWords2.length -
                          _recognizedWords3.length -
                          1];
                      listName = 'Fan Off';
                    }
                    return ListTile(
                      title: Text(word),
                      subtitle: Text(listName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          int listIndex = index <= _recognizedWords1.length
                              ? 0
                              : index <=
                                      _recognizedWords1.length +
                                          _recognizedWords2.length
                                  ? 1
                                  : index <=
                                          _recognizedWords1.length +
                                              _recognizedWords2.length +
                                              _recognizedWords3.length
                                      ? 2
                                      : 3;
                          _removeWordFromList(
                              _recognizedWords1, word, listIndex);
                          _removeWordFromList(
                              _recognizedWords2, word, listIndex);
                          _removeWordFromList(
                              _recognizedWords3, word, listIndex);
                          _removeWordFromList(
                              _recognizedWords4, word, listIndex);
                        },
                      ),
                    );
                  }
                },
              )),
              Switch(
                value: _isListening,
                onChanged: (value) {
                  setState(() {
                    _isListening = value;
                    if (_isListening) {
                      _stopListening = false;
                      foundWords.clear();
                      _startListening();
                    } else {
                      _stopListening = true;
                      foundWords.clear();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeWordFromList(List<String> list, String word, int listIndex) {
    setState(() {
      list.remove(word);
      _saveAddedWords(); // Call save method after removing word
      print('Word $word removed from List ${listIndex + 1}');
    });
  }

  Widget _buildAddButton(List<String> list, int listIndex) {
    String buttonLabel = '';
    switch (listIndex) {
      case 0:
        buttonLabel = 'Elevator';
        break;
      case 1:
        buttonLabel = 'Elevator';
        break;
      case 2:
        buttonLabel = 'Fan On';
        break;
      case 3:
        buttonLabel = 'Fan Off';
        break;
      default:
        buttonLabel = 'Add to List ${listIndex + 1}';
    }

    return Container(
      width: 96,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _addWordToList(list),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13), // Adjust the font size as needed
            ),
            if (listIndex == 0) // Only show "Up" for Elevator buttons
              const Text(
                'Up',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 13), // Adjust the font size as needed
              )
            else if (listIndex == 1) // Only show "Up" for Elevator buttons
              const Text(
                'Down',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 13), // Adjust the font size as needed
              )
          ],
        ),
        style: const ButtonStyle(
          alignment: Alignment.center,
        ),
      ),
    );
  }

  void _requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();
    print("Microphone permission status: $status");
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _text = 'Listening...';
      });
      while (!_stopListening) {
        await _speech.listen(
          onResult: (result) {
            setState(() {
              if (result.recognizedWords.length == 0) {
                print('nu e nimic');
                foundWords.clear();
              }
              _text = result.recognizedWords.toLowerCase();
            });
            _checkRecognizedWord(result.recognizedWords.toLowerCase());
          },
        );
      }
    }
  }

  int countOccurrences(String text, String pattern) {
    RegExp regExp = RegExp(pattern);
    Iterable<Match> matches = regExp.allMatches(text);
    return matches.length;
  }

  String _lastRecognizedWord = '';
  List<String> lastFiveRecognizedWords = [];

  void _checkRecognizedWord(String phrase) {
    for (var element in _recognizedWords1) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          _lastRecognizedWord = '$element - Found in Elevator Up at ${DateTime.now().toLocal().toString().split('.')[0]} \n';
          print('Recognized word: $element - Found in List 1');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
          _updateLastFiveRecognizedWords(_lastRecognizedWord);
        }
        setElevatorStatus(1);
        break;
      }
    }
    for (var element in _recognizedWords2) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          _lastRecognizedWord = '$element - Found in Elevator Down at ${DateTime.now().toLocal().toString().split('.')[0]} \n';
          print('Recognized word: $element - Found in List 2');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
          _updateLastFiveRecognizedWords(_lastRecognizedWord);
        }
        setElevatorStatus(0);
        break;
      }
    }
    for (var element in _recognizedWords3) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          _lastRecognizedWord = '$element - Found in Fan On at ${DateTime.now().toLocal().toString().split('.')[0]} \n';
          print('Recognized word: $element - Found in List 3');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
          _updateLastFiveRecognizedWords(_lastRecognizedWord);
        }
        setFanStatus(1);
        break;
      }
    }
    for (var element in _recognizedWords4) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          _lastRecognizedWord = '$element - Found in Fan Off at ${DateTime.now().toLocal().toString().split('.')[0]} \n';
          print('Recognized word: $element - Found in List 4');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
          _updateLastFiveRecognizedWords(_lastRecognizedWord);
        }
        setFanStatus(0);
        break;
      }
    }
    setState(() {
      _lastRecognizedWord = lastFiveRecognizedWords.join('');
    });
  }

  void _updateLastFiveRecognizedWords(String word) {
    if (lastFiveRecognizedWords.length >= 5) {
      lastFiveRecognizedWords.removeAt(0); // Remove the oldest word
    }
    lastFiveRecognizedWords.add(word); // Add the new recognized word
  }

  void _addWordToList(List<String> list) {
    String word = _textFieldController.text.trim().toLowerCase();
    if (word.isNotEmpty && !list.contains(word)) {
      setState(() {
        list.add(word);
        _saveAddedWords(); // Call save method after adding word
        _textFieldController.clear();
        print('List was initialized');
      });
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }
}
