import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pocket_vocabulary/DatabaseHelper.dart';
import 'package:flutter_pocket_vocabulary/model.dart';
import 'dart:math';
import 'dart:io';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  _TrainScreenState createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  Future<List<Word>>? _words;
  List<Word> wordList = List.empty();
  String originalWord = '';
  String translatedWord = '';
  bool isLoading = false;

  var database = DatabaseHelper.instance;

  final TextEditingController _translatedTextFieldController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _words = database.words().then((list) => wordList = list);
  }

  void _onFloatingButtonTapped() {
    print('floating button tapped');
  }

  Word _getRandomWord() {
    final random = Random();
    final wordsLength = wordList.length;
    final randomIndex = random.nextInt(wordsLength);
    Word randomWord = wordList[randomIndex];
    setState(() {
      originalWord = randomWord.originalText;
      translatedWord = randomWord.translatedText;
    });

    return randomWord;
  }

  void _checkTranslate() {
    if (originalWord.isEmpty) {
      // Для начала получите слово для перевода и повторите попытку
      _showPlatformAlert(
        context,
        title: 'Произошла ошибка...',
        content: 'Для начала получите слово для перевода и повторите попытку',
        actionTitle: 'OK',
      );
      return;
    }

    if (translatedWord.isEmpty) {
      // Укажите перевод слова и повторите попытку
      _showPlatformAlert(
        context,
        title: 'Не указан перевод',
        content: 'Укажите перевод слова и повторите попытку',
        actionTitle: 'OK',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (_translatedTextFieldController.text.toUpperCase() ==
        translatedWord.toUpperCase()) {
      _getRandomWord();
      _translatedTextFieldController.text = '';
    } else {
      // Показываем алерт и просим повторить попытку
      _showPlatformAlert(
        context,
        title: 'Неправильный перевод',
        content: 'Попробуйте еще раз',
        actionTitle: 'OK',
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showPlatformAlert(context,
      {required String title,
      required String content,
      required String actionTitle}) {
    Text alertTitle = Text(title);
    Text alertContent = Text(content);
    TextButton alertButton = TextButton(
      child: const Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Platform.isIOS || Platform.isMacOS
        ? showCupertinoDialog<String>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: alertTitle,
              content: alertContent,
              actions: [alertButton],
            ),
          )
        : showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: alertTitle,
              content: alertContent,
              actions: [alertButton],
            ),
          );
  }

  Widget showPlatformProgressIndicator() {
    if (Platform.isIOS || Platform.isMacOS) {
      return const CupertinoActivityIndicator();
    } else {
      return const CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Тренировка'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  // padding: EdgeInsets.symmetric(vertical: 4.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 20.0),
                  child: TextButton(
                    onPressed: _getRandomWord,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 46.0, vertical: 16.0),
                      ),
                      backgroundColor: const MaterialStatePropertyAll<Color>(
                          Colors.lightGreen),
                      foregroundColor:
                          const MaterialStatePropertyAll<Color>(Colors.white),
                    ),
                    child: const Text(
                      'Получить слово',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Text(
                    originalWord.toUpperCase(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: TextFormField(
                    controller: _translatedTextFieldController,
                    decoration: const InputDecoration(
                      hintText: 'Введите перевод',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 60,
                  // padding: EdgeInsets.symmetric(vertical: 4.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 20.0),
                  child: TextButton(
                    onPressed: _checkTranslate,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 46.0, vertical: 16.0),
                      ),
                      backgroundColor: const MaterialStatePropertyAll<Color>(
                          Colors.lightGreen),
                      foregroundColor:
                          const MaterialStatePropertyAll<Color>(Colors.white),
                    ),
                    child: const Text(
                      'Проверить',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            isLoading
                // ? const Center(child: CircularProgressIndicator())
                ? Center(child: showPlatformProgressIndicator())
                : const SizedBox.shrink(),
          ],
        ));
  }
}
