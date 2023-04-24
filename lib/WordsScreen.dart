import 'package:flutter/material.dart';
import 'package:flutter_pocket_vocabulary/DatabaseHelper.dart';
import 'package:flutter_pocket_vocabulary/WordCreateScreen.dart';
import 'package:flutter_pocket_vocabulary/model.dart';

class WordsScreen extends StatefulWidget {
  @override
  _WordsScreenState createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  Future<List<Word>>? _words;

  var database = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _words = database.words();
  }

  void _reloadData() {
    Future<List<Word>> items = database.words();
    setState(() {
      _words = items;
    });
  }

  void _onFloatingButtonTapped() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordCreateScreen()),
    ).then((value) {
      _reloadData();
    });
  }

  void _deleteWord(int id) async {
    database.deleteWord(id).then((value) {
      _reloadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список слов'),
      ),
      body: FutureBuilder<List<Word>>(
        future: _words,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final item = snapshot.data?[index];
                if (item != null) {
                  return Dismissible(
                      key: Key(item.toString()),
                      onDismissed: (direction) {
                        _deleteWord(item.id);
                        setState(() {
                          snapshot.data!.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("$item dismissed")));
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          item.originalText.toLowerCase(),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.translatedText.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ));
                }
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFloatingButtonTapped,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
