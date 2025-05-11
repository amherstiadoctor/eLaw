import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/flashcard.dart';
import 'package:sp_code/model/flashcard_deck.dart';
import 'package:sp_code/utils/widgets/flip_card.dart';
// import 'package:sp_code/utils/widgets/header.dart';

class ViewDeckScreen extends StatefulWidget {
  const ViewDeckScreen({super.key, required this.deck});
  final FlashcardDeck deck;

  @override
  State<ViewDeckScreen> createState() => _ViewDeckScreenState();
}

class _ViewDeckScreenState extends State<ViewDeckScreen> {
  final CardSwiperController controller = CardSwiperController();
  Color bgColor = AppTheme.primary;

  late final List<Container> wrappedCards;
  late final List<Flashcard> currentCards;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentCards = widget.deck.cards;
    wrappedCards =
        widget.deck.cards
            .map(
              // ignore: avoid_unnecessary_containers
              (card) => Container(
                child: FlipCard(cardInfo: card, isEdit: false, isView: true),
              ),
            )
            .toList();
    wrappedCards.shuffle();
  }

  Future<void> _updateAllCardLevelsInFirestore() async {
    final deckRef = FirebaseFirestore.instance
        .collection('decks')
        .doc(widget.deck.id);

    try {
      final snapshot = await deckRef.get();

      if (!snapshot.exists) {
        print("Deck not found");
        return;
      }
      // Loop through and update each card
      final List updatedCards =
          currentCards.map((card) {
            // Set next review date based on new level (simplified)
            final now = DateTime.now();
            final intervals = [
              const Duration(hours: 0),
              const Duration(hours: 8),
              const Duration(days: 1),
              const Duration(days: 3),
              const Duration(days: 7),
            ];
            final nextReviewDate = now.add(intervals[card.level]);

            return {
              'id': card.id,
              'backInfo': card.backInfo,
              'frontInfo': card.frontInfo,
              'level': card.level,
              'nextReviewDate': nextReviewDate,
            };
          }).toList();

      // Update the deck document with new card list
      await deckRef.update({'cards': updatedCards});

      print("All cards updated successfully.");
    } catch (e) {
      print("Failed to update cards: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: bgColor),
        child: Column(
          children: [
            Flexible(
              child: CardSwiper(
                allowedSwipeDirection: const AllowedSwipeDirection.only(
                  left: true,
                  right: true,
                  up: false,
                  down: false,
                ),
                isLoop: false,
                controller: controller,
                cardsCount: wrappedCards.length,
                onSwipe: _onSwipe,
                onSwipeDirectionChange: _handleSwipeDirectionChange,
                onEnd: () async {
                  await _updateAllCardLevelsInFirestore();
                },
                numberOfCardsDisplayed:
                    wrappedCards.length < 3 ? wrappedCards.length : 3,
                padding: const EdgeInsets.all(24.0),
                cardBuilder:
                    (
                      context,
                      index,
                      horizontalThresholdPercentage,
                      verticalThresholdPercentage,
                    ) => wrappedCards[index],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() {
      if (direction.name == "right") {
        // Correct answer, move the card to the next level
        currentCards[previousIndex]
            .level = (currentCards[previousIndex].level + 1).clamp(0, 4);
      } else {
        // Incorrect answer, move the card back to the previous level
        currentCards[previousIndex].level = 0;
      }
      bgColor = AppTheme.primary;
    });
    return true;
  }

  void _handleSwipeDirectionChange(
    CardSwiperDirection currentDirection,
    CardSwiperDirection previousDirection,
  ) {
    setState(() {
      if (currentDirection == CardSwiperDirection.right) {
        bgColor = AppTheme.green;
      } else if (currentDirection == CardSwiperDirection.left) {
        bgColor = AppTheme.red;
      } else {
        bgColor = AppTheme.primary;
      }
    });
  }
}
