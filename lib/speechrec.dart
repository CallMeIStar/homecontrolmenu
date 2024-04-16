// ignore_for_file: sort_child_properties_last, avoid_print, sized_box_for_whitespace, prefer_is_empty, prefer_final_fields, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestMicrophonePermission();
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
                padding: EdgeInsets.only(bottom: 80), // Add padding here             
              ),
              Text(
                  _text,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAddButton(_recognizedWords1, 0),
                  _buildAddButton(_recognizedWords2, 1),
                  _buildAddButton(_recognizedWords3, 2),
                  _buildAddButton(_recognizedWords4, 3),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Recognized Words:',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                          'Added Word: ${_textFieldController.text}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      String word;
                      List<String> list;
                      int listIndex;
                      String listName;
                      if (index <= _recognizedWords1.length) {
                        word = _recognizedWords1[index - 1];
                        list = _recognizedWords1;
                        listIndex = 0;
                        listName = 'Elevator Up';
                      } else if (index <=
                          _recognizedWords1.length + _recognizedWords2.length) {
                        word = _recognizedWords2[
                            index - _recognizedWords1.length - 1];
                        list = _recognizedWords2;
                        listIndex = 1;
                        listName = 'Elevator Down';
                      } else if (index <=
                          _recognizedWords1.length +
                              _recognizedWords2.length +
                              _recognizedWords3.length) {
                        word = _recognizedWords3[index -
                            _recognizedWords1.length -
                            _recognizedWords2.length -
                            1];
                        list = _recognizedWords3;
                        listIndex = 2;
                        listName = 'Fan On';
                      } else {
                        word = _recognizedWords4[index -
                            _recognizedWords1.length -
                            _recognizedWords2.length -
                            _recognizedWords3.length -
                            1];
                        list = _recognizedWords4;
                        listIndex = 3;
                        listName = 'Fan Off';
                      }
                      return ListTile(
                        title: Text(word),
                        subtitle: Text(listName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _removeWordFromList(list, word, listIndex),
                        ),
                      );
                    }
                  },
                ),
              ),
              Switch(
                value: _isListening,
                onChanged: (value) {
                  setState(() {
                    _isListening = value;
                    if (_isListening) {
                      _stopListening = false; // Reset _stopListening flag
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
              _text = result.recognizedWords;
            });
            _checkRecognizedWord(result.recognizedWords);
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

  void _checkRecognizedWord(String phrase) {
    // Check each list for the recognized words in the phrase
    for (var element in _recognizedWords1) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          print('Recognized word: $element - Found in List 1');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
        }

        //phrase = phrase.replaceAll(element, '');
      }
    }
    for (var element in _recognizedWords2) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          print('Recognized word: $element - Found in List 2');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
        }

        //phrase = phrase.replaceAll(element, '');
      }
    }
    for (var element in _recognizedWords3) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          print('Recognized word: $element - Found in List 3');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
        }

        //phrase = phrase.replaceAll(element, '');
      }
    }
    for (var element in _recognizedWords4) {
      if (phrase.contains(element)) {
        if (countOccurrences(phrase, element) == foundWords[element]) {
          break;
        } else {
          print('Recognized word: $element - Found in List 4');
          if (!foundWords.containsKey(element)) {
            foundWords[element] = 1;
          } else {
            foundWords[element]++;
          }
        }

        //phrase = phrase.replaceAll(element, '');
      }
    }
  }

  void _addWordToList(List<String> list) {
    String word = _textFieldController.text.trim();
    if (word.isNotEmpty && !list.contains(word)) {
      setState(() {
        list.add(word);
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
