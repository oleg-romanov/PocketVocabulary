class WordCategory {
  final int id;
  final String name;

  const WordCategory({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class WordCategoryDTO {
  String name;

  WordCategoryDTO({
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class Word {
  final int id;
  final String fromLanguage;
  final String toLanguage;
  final String originalText;
  final String translatedText;
  final int categoryId;

  const Word(
      {required this.id,
      required this.fromLanguage,
      required this.toLanguage,
      required this.originalText,
      required this.translatedText,
      required this.categoryId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
      'originalText': originalText,
      'translatedText': translatedText,
      'categoryId': categoryId,
    };
  }
}

class WordDTO {
  String fromLanguage;
  String toLanguage;
  String originalText;
  String translatedText;
  int? categoryId;

  WordDTO({
    required this.fromLanguage,
    required this.toLanguage,
    required this.originalText,
    required this.translatedText,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
      'originalText': originalText,
      'translatedText': translatedText,
      'categoryId': categoryId,
    };
  }
}
