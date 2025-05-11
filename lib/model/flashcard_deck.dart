import 'package:sp_code/model/flashcard.dart';

class FlashcardDeck {
  FlashcardDeck({
    required this.id,
    required this.title,
    required this.cards,
    required this.creatorId,
  });

  factory FlashcardDeck.fromMap(String id, Map<String, dynamic> map) =>
      FlashcardDeck(
        id: id,
        title: map['title'] ?? "",
        cards:
            ((map['cards'] ?? []) as List)
                .map((e) => Flashcard.fromMap(e))
                .toList(),
        creatorId: map['creatorId'] ?? "",
      );
  final String id;
  final String title;
  final List<Flashcard> cards;
  final String creatorId;

  Map<String, dynamic> toMap({bool isUpdate = false}) => {
    'title': title,
    'cards': cards.map((e) => e.toMap()).toList(),
    'creatorId': creatorId,
  };

  FlashcardDeck copyWith({String? title, List<Flashcard>? cards}) =>
      FlashcardDeck(
        id: id,
        title: title ?? this.title,
        cards: cards ?? this.cards,
        creatorId: creatorId,
      );

  List<Flashcard> getCardsForLevel(int level) =>
      cards.where((card) => card.level == level).toList();
}
