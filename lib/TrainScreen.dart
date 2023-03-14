import 'package:flutter/material.dart';
import 'package:flutter_pocket_vocabulary/DatabaseHelper.dart';
import 'package:flutter_pocket_vocabulary/model.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  _TrainScreenState createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  Future<List<Word>>? _words;

  var database = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _words = database.words();
  }

  void _onFloatingButtonTapped() {
    print('floating button tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Train'),
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
                  return ListTile(
                    title: Text(item.originalText),
                    subtitle: Text(item.translatedText),
                    onTap: () {
                      // Navigate to detail screen for selected item
                    },
                  );
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
    );
  }
}
