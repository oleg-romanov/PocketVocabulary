import 'package:flutter/material.dart';
import 'package:flutter_pocket_vocabulary/DatabaseHelper.dart';
import 'package:flutter_pocket_vocabulary/model.dart';

class WordCreateScreen extends StatefulWidget {
  @override
  _WordCreateScreenState createState() => _WordCreateScreenState();
}

class _WordCreateScreenState extends State<WordCreateScreen> {
  var database = DatabaseHelper.instance;

  static const List<String> languages = <String>['RU', 'EN'];
  String fromLanguageDropdownValue = languages.first;
  String toLanguageDropdownValue = languages.first;

  final TextEditingController _originalTextFieldController =
      TextEditingController();
  final TextEditingController _translatedTextFieldController =
      TextEditingController();
  final TextEditingController _categoryNameTextFieldController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _onAddButtonClicked() async {
    // String value
    String originalText = _originalTextFieldController.text;
    String translatedText = _translatedTextFieldController.text;
    String categoryNameText = _categoryNameTextFieldController.text;

    int? categoryId;
    int? wordId;

    if (originalText.isEmpty && translatedText.isEmpty) {
      print('Все поля пустые');
      return;
    }
    if (originalText.isEmpty) {
      print('original text is empty');
      return;
    }
    if (translatedText.isEmpty) {
      print('translated text is empty');
      return;
    }

    if (categoryNameText.isNotEmpty) {
      WordCategoryDTO newCategory = WordCategoryDTO(name: categoryNameText);
      categoryId = await database.insertCategory(newCategory);
    }

    WordDTO newWord = WordDTO(
      fromLanguage: fromLanguageDropdownValue,
      toLanguage: toLanguageDropdownValue,
      originalText: originalText,
      translatedText: translatedText,
      categoryId: categoryId,
    );
    wordId = await database.insertWord(newWord);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Добавление слова'),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton(
                    value: fromLanguageDropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    items:
                        languages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        fromLanguageDropdownValue = value!;
                      });
                    }),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _originalTextFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Введите слово',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              DropdownButton(
                  value: toLanguageDropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  items:
                      languages.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      toLanguageDropdownValue = value!;
                    });
                  }),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _translatedTextFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Введите перевод',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: TextFormField(
                  controller: _categoryNameTextFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Укажите категорию',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF42A5F5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(24.0),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _onAddButtonClicked,
                      child: const Text('Добавить'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )));
  }
}
