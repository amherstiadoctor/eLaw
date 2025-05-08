import 'package:sp_code/model/flashcard.dart';

class FlashcardDeck {
  final String id;
  final String title;
  final List<Flashcard> cards;

  FlashcardDeck({required this.id, required this.title, required this.cards});

  factory FlashcardDeck.fromMap(String id, Map<String, dynamic> map) {
    return FlashcardDeck(
      id: id,
      title: map['title'] ?? "",
      cards:
          ((map['cards'] ?? []) as List)
              .map((e) => Flashcard.fromMap(e))
              .toList(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {'title': title, 'cards': cards.map((e) => e.toMap()).toList()};
  }

  FlashcardDeck copyWith({String? title, List<Flashcard>? cards}) {
    return FlashcardDeck(
      id: id,
      title: title ?? this.title,
      cards: cards ?? this.cards,
    );
  }
}
