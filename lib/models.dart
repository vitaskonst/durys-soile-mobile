/// The two word lists; [apiValue] is the API's `type` parameter.
enum WordType {
  mispronounced('commonly-mispronounced'),
  parasite('parasite');

  const WordType(this.apiValue);

  final String apiValue;
}

/// A correct replacement for a parasite (foreign) word, optionally with an
/// example sentence using the word wrongly and one using the replacement.
class CorrectVersion {
  const CorrectVersion({required this.word, this.incorrectUsage, this.correctUsage});

  // The API omits the usage keys when a version has no example sentence.
  factory CorrectVersion.fromJson(Map<String, dynamic> json) => CorrectVersion(
        word: json['word'] as String,
        incorrectUsage: json['incorrectUsage'] as String?,
        correctUsage: json['correctUsage'] as String?,
      );

  final String word;
  final String? incorrectUsage;
  final String? correctUsage;

  bool get hasExamples =>
      (incorrectUsage?.trim().isNotEmpty ?? false) || (correctUsage?.trim().isNotEmpty ?? false);
}

class Word {
  const Word({
    required this.id,
    required this.word,
    required this.type,
    this.correctVersions = const [],
    required this.json,
  });

  // The API omits correctVersions entirely for commonly mispronounced words.
  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json['id'] as int,
        word: json['word'] as String,
        type: json['type'] as String,
        correctVersions: [
          for (final version in (json['correctVersions'] as List<dynamic>? ?? const []))
            CorrectVersion.fromJson(version as Map<String, dynamic>),
        ],
        json: json,
      );

  final int id;
  final String word;
  final String type;
  final List<CorrectVersion> correctVersions;

  /// The response this word was parsed from, kept so favourites can store
  /// it as the API sent it.
  final Map<String, dynamic> json;

  /// The Kazakh replacement shown under a parasite word.
  String? get suggestion => correctVersions.isEmpty ? null : correctVersions.first.word;

  /// Words with correct versions open a detail sheet; the rest just play.
  bool get hasDetails => correctVersions.isNotEmpty;
}
