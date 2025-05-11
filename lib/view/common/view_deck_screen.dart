import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/svg_images.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/flashcard.dart';
import 'package:sp_code/model/flashcard_deck.dart';
import 'package:sp_code/utils/widgets/flip_card.dart';
import 'package:sp_code/utils/widgets/header.dart';
import 'package:intl/intl.dart';

class ViewDeckScreen extends StatefulWidget {
  const ViewDeckScreen({super.key, required this.deck});
  final FlashcardDeck deck;

  @override
  State<ViewDeckScreen> createState() => _ViewDeckScreenState();
}

class _ViewDeckScreenState extends State<ViewDeckScreen> {
  final CardSwiperController controller = CardSwiperController();
  Color bgColor = AppTheme.primary;
  String displayMessage = "";
  bool showEndButton = false;
  String nextCardDate = "";

  late final List<Container> wrappedCards;
  List<Flashcard> allCards = [];
  List<Flashcard> dueCards = [];
  int swiperKey = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allCards = widget.deck.cards;
    final futureCards =
        allCards
            .where((card) => card.nextReviewDate.isAfter(DateTime.now()))
            .toList();
    final Flashcard? nextCard =
        futureCards.isEmpty
            ? null
            : futureCards.reduce(
              (a, b) => a.nextReviewDate.isBefore(b.nextReviewDate) ? a : b,
            );

    if (nextCard != null) {
      final formattedDate = DateFormat.yMMMEd().add_jm().format(
        nextCard.nextReviewDate,
      );
      nextCardDate = 'Next Review Session: $formattedDate';
    }
    dueCards =
        widget.deck.cards
            .where((card) => card.nextReviewDate.isBefore(DateTime.now()))
            .toList();
    wrappedCards =
        dueCards
            .map(
              // ignore: avoid_unnecessary_containers
              (card) => Container(
                child: FlipCard(cardInfo: card, isEdit: false, isView: true),
              ),
            )
            .toList();
    wrappedCards.shuffle();
  }

  DateTime calculateNextReviewDate(int currentLevel) {
    switch (currentLevel) {
      case 1:
        return DateTime.now().add(const Duration(hours: 1)); // 1 hour
      case 2:
        return DateTime.now().add(const Duration(hours: 6)); // 6 hours
      case 3:
        return DateTime.now().add(const Duration(days: 1)); // 1 day
      case 4:
        return DateTime.now().add(const Duration(days: 2)); // 2 days
      case 5:
        return DateTime.now().add(const Duration(days: 3)); // 3 days
      default:
        return DateTime.now(); // Fallback if level is invalid
    }
  }

  Future<void> updateCard({
    required String deckId,
    required Flashcard updatedCard,
  }) async {
    final deckRef = FirebaseFirestore.instance
        .collection('decks')
        .doc(widget.deck.id);
    final snapshot = await deckRef.get();
    final data = snapshot.data();

    if (data == null) return;

    final cardsData = List<Map<String, dynamic>>.from(data['cards']);

    // Replace the matching card
    final updatedCards =
        cardsData.map((card) {
          if (card['id'] == updatedCard.id) {
            return updatedCard.toMap();
          }
          return card;
        }).toList();

    await deckRef.update({'cards': updatedCards});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: bgColor),
          child: Column(
            children: [
              dueCards.isNotEmpty
                  ? Flexible(
                    child: CardSwiper(
                      key: ValueKey(swiperKey),
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
                      onEnd: () {
                        setState(() {
                          showEndButton = true;
                        });
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
                  )
                  : Flexible(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(
                            replayIcon,
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: 220.responsiveW,
                            decoration: BoxDecoration(
                              color: AppTheme.secondary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.black,
                                width: 2,
                              ),
                            ),
                            child: TextButton(
                              child: const Text(
                                "Nothing to Review",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppTheme.black,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nextCardDate,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        if (showEndButton)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.string(replayIcon, width: 120, height: 120),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(5),
                  width: 220.responsiveW,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.black, width: 2),
                  ),
                  child: TextButton(
                    child: const Text(
                      "Finish Review",
                      style: TextStyle(fontSize: 20, color: AppTheme.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        Container(
          margin: EdgeInsets.only(bottom: 560.responsiveH),
          child: Center(
            child: Text(
              displayMessage,
              style: const TextStyle(color: AppTheme.white, fontSize: 24),
            ),
          ),
        ),
        const Header(
          title: "Review Flashcards",
          hasBackButton: true,
          color: AppTheme.white,
        ),
      ],
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
        dueCards[previousIndex].level = (dueCards[previousIndex].level + 1)
            .clamp(0, 4);
        final updatedCard = dueCards[previousIndex].copyWith(
          level: dueCards[previousIndex].level,
          nextReviewDate: calculateNextReviewDate(
            dueCards[previousIndex].level,
          ),
        );
        updateCard(deckId: widget.deck.id, updatedCard: updatedCard);
      } else {
        // Incorrect answer, move the card back to the previous level
        dueCards[previousIndex].level = 0;
        final updatedCard = dueCards[previousIndex].copyWith(
          level: dueCards[previousIndex].level,
          nextReviewDate: calculateNextReviewDate(
            dueCards[previousIndex].level,
          ),
        );
        updateCard(deckId: widget.deck.id, updatedCard: updatedCard);
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
        displayMessage = "I got it right";
        bgColor = AppTheme.green;
      } else if (currentDirection == CardSwiperDirection.left) {
        displayMessage = 'Need to review';
        bgColor = AppTheme.red;
      } else {
        displayMessage = "";
        bgColor = AppTheme.primary;
      }
    });
  }
}
