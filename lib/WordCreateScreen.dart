import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pocket_vocabulary/DatabaseHelper.dart';
import 'package:flutter_pocket_vocabulary/model.dart';
import 'package:translator/translator.dart';
import 'dart:io';

class WordCreateScreen extends StatefulWidget {
  const WordCreateScreen({super.key});

  @override
  _WordCreateScreenState createState() => _WordCreateScreenState();
}

class _WordCreateScreenState extends State<WordCreateScreen> {
  var database = DatabaseHelper.instance;

  final translator = GoogleTranslator();

  static const List<String> languages = <String>['RU', 'EN'];
  int _selectedFromLanguageIndex = 0;
  int _selectedToLanguageIndex = 1;

  final double _kItemExtent = 32.0;

  String fromLanguageDropdownValue = languages.first;
  String toLanguageDropdownValue = languages.last;
  bool isLoading = false;

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

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  Widget _getPlatformPicker(bool selectedFromLanguage) {
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showDialog(
          CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: _kItemExtent,
            scrollController: FixedExtentScrollController(
              initialItem: selectedFromLanguage
                  ? _selectedFromLanguageIndex
                  : _selectedToLanguageIndex,
            ),
            onSelectedItemChanged: (int selectedIndex) {
              setState(() {
                changeValuesIOSPicker(selectedFromLanguage, selectedIndex);
              });
            },
            children: List<Widget>.generate(languages.length, (int index) {
              return Center(
                child: Text(
                  languages[index],
                ),
              );
            }),
          ),
        ),
        // This displays the selected language.
        child: Text(
          selectedFromLanguage
              ? languages[_selectedFromLanguageIndex]
              : languages[_selectedToLanguageIndex],
          style: const TextStyle(
            fontSize: 22.0,
          ),
        ),
      );
    } else {
      return DropdownButton(
        value: selectedFromLanguage
            ? fromLanguageDropdownValue
            : toLanguageDropdownValue,
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
        items: languages.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            for (int i = 0; i < languages.length; i++) {
              if (languages[i] == value) {
                if (selectedFromLanguage) {
                  toLanguageDropdownValue = fromLanguageDropdownValue;
                  fromLanguageDropdownValue = value!;
                } else {
                  fromLanguageDropdownValue = toLanguageDropdownValue;
                  toLanguageDropdownValue = value!;
                }
              }
            }
          });
        },
      );
    }
  }

  void changeValuesIOSPicker(bool selectedFromLanguage, int index) {
    if (selectedFromLanguage) {
      if (_selectedToLanguageIndex == index) {
        _selectedToLanguageIndex = _selectedFromLanguageIndex;
        _selectedFromLanguageIndex = index;
      } else {
        _selectedToLanguageIndex = index;
      }
    } else {
      if (_selectedFromLanguageIndex == index) {
        _selectedFromLanguageIndex = _selectedToLanguageIndex;
        _selectedToLanguageIndex = index;
      } else {
        _selectedFromLanguageIndex = index;
      }
    }
  }

  void _onAddButtonTapped() async {
    // String value
    String originalText = _originalTextFieldController.text;
    String translatedText = _translatedTextFieldController.text;
    String categoryNameText = _categoryNameTextFieldController.text;

    int? categoryId;
    int? wordId;

    if (originalText.isEmpty && translatedText.isEmpty) {
      _showPlatformAlert(
        context,
        title: 'Произошла ошибка...',
        content: 'Заполните все поля',
        actionTitle: 'OK',
      );
      return;
    }
    if (originalText.isEmpty) {
      _showPlatformAlert(
        context,
        title: 'Произошла ошибка...',
        content: 'Укажите слово для перевода и повторите попытку',
        actionTitle: 'OK',
      );
      return;
    }
    if (translatedText.isEmpty) {
      _showPlatformAlert(
        context,
        title: 'Произошла ошибка...',
        content:
            'Перевод слова пуст, воспользуйтесь функцией перевода слова или укажите перевод слова самостоятельно',
        actionTitle: 'OK',
      );
      return;
    }

    if (categoryNameText.isEmpty) {
      _showPlatformAlert(
        context,
        title: 'Произошла ошибка...',
        content: 'Укажите категорию для слова и повторите попытку',
        actionTitle: 'OK',
      );
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

  void _onTranslateButtonTapped() async {
    setState(() {
      isLoading = true;
    });
    String originalText = _originalTextFieldController.text;
    var translation = await translator.translate(
      originalText,
      from: Platform.isIOS || Platform.isMacOS
          ? languages[_selectedFromLanguageIndex].toLowerCase()
          : fromLanguageDropdownValue.toLowerCase(),
      to: Platform.isIOS || Platform.isMacOS
          ? languages[_selectedToLanguageIndex].toLowerCase()
          : toLanguageDropdownValue.toLowerCase(),
    );
    setState(() {
      isLoading = false;
      _translatedTextFieldController.text = translation.text;
    });
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
        title: const Text('Добавление слова'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _getPlatformPicker(true),
                      const Icon(
                        Icons.swap_horiz,
                        size: 30,
                      ),
                      _getPlatformPicker(false),
                    ],
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: TextFormField(
                    controller: _originalTextFieldController,
                    decoration: const InputDecoration(
                      hintText: 'Введите слово',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _onTranslateButtonTapped,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 46.0, vertical: 16.0),
                    ),
                    backgroundColor:
                        const MaterialStatePropertyAll<Color>(Colors.blue),
                    foregroundColor:
                        const MaterialStatePropertyAll<Color>(Colors.white),
                  ),
                  child: const Text('Перевести'),
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: TextFormField(
                    controller: _categoryNameTextFieldController,
                    decoration: const InputDecoration(
                      hintText: 'Укажите категорию',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _onAddButtonTapped,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 46.0, vertical: 16.0),
                    ),
                    backgroundColor:
                        const MaterialStatePropertyAll<Color>(Colors.blue),
                    foregroundColor:
                        const MaterialStatePropertyAll<Color>(Colors.white),
                  ),
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
          isLoading
              // ? const Center(child: CircularProgressIndicator())
              ? Center(child: showPlatformProgressIndicator())
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
