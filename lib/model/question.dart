class Question {

  Question({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) => Question(
      text: map['text'],
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Map<String, dynamic> toMap() => {
      'text': text,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };

  Question copyWith({
    String? text,
    List<String>? options,
    int? correctOptionIndex,
  }) => Question(
      text: text ?? this.text,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
    );
}
