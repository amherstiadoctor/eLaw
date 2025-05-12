// ignore_for_file: must_be_immutable

import 'package:app_tutorial/app_tutorial.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/flashcard.dart';
import 'package:sp_code/model/flashcard_deck.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/utils/widgets/flip_card.dart';
import 'package:sp_code/utils/widgets/header.dart';
import 'package:sp_code/utils/widgets/tutorial_item_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageDeckScreen extends StatefulWidget {
  ManageDeckScreen({
    super.key,
    required this.currentUser,
    this.isEdit = false,
    this.deck,
  });
  final Map<String, dynamic> currentUser;
  final bool isEdit;
  FlashcardDeck? deck;

  @override
  State<ManageDeckScreen> createState() => _ManageDeckScreenState();
}

class FlashcardFromItem {
  FlashcardFromItem({
    required this.id,
    required this.frontInfoController,
    required this.backInfoController,
    required this.nextReviewDate,
  });
  final String id;
  final TextEditingController frontInfoController;
  final TextEditingController backInfoController;
  final DateTime nextReviewDate;

  void dispose() {
    frontInfoController.dispose();
    backInfoController.dispose();
  }
}

class _ManageDeckScreenState extends State<ManageDeckScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  List<FlashcardFromItem> _flashcardItems = [];
  bool _isLoading = false;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  var _currentCarouselPage = 0;

  List<TutorialItem> items = [];

  final buttonKey = GlobalKey();
  final cardKey = GlobalKey();

  void initItems() {
    items.addAll([
      TutorialItem(
        globalKey: buttonKey,
        color: Colors.black.withOpacity(0.6),
        borderRadius: const Radius.circular(15.0),
        shapeFocus: ShapeFocus.roundedSquare,
        child: TutorialItemContent(
          title: 'Add flashcard button',
          content: 'Tap this button to add a flashcard',
        ),
      ),
      TutorialItem(
        globalKey: cardKey,
        color: Colors.black.withOpacity(0.6),
        borderRadius: const Radius.circular(15.0),
        shapeFocus: ShapeFocus.roundedSquare,
        child: TutorialItemContent(
          title: 'Flashcard',
          content: 'Tap the white area under the text box to flip the card',
        ),
      ),
    ]);
  }

  Future<void> saveTutorialCompletedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flashCard_tutorial_completed', true);
  }

  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('flashCard_tutorial_completed') ?? false;
  }

  void checkTutorialStatus() async {
    final bool completed = await isTutorialCompleted();
    if (!completed) {
      initItems();
      Future.delayed(const Duration(microseconds: 200)).then((value) {
        Tutorial.showTutorial(
          context,
          items,
          onTutorialComplete: () {
            saveTutorialCompletedFlag();
          },
        );
      });
    } else {
      saveTutorialCompletedFlag();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    checkTutorialStatus();
    super.initState();
    if (widget.isEdit) {
      _initData();
    } else {
      _addFlashcard();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    for (var item in _flashcardItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _initData() {
    _titleController = TextEditingController(text: widget.deck?.title);
    _flashcardItems =
        widget.deck!.cards
            .map(
              (card) => FlashcardFromItem(
                id: card.id,
                frontInfoController: TextEditingController(
                  text: card.frontInfo,
                ),
                backInfoController: TextEditingController(text: card.backInfo),
                nextReviewDate: card.nextReviewDate,
              ),
            )
            .toList();
  }

  void _addFlashcard() {
    final cardRef =
        FirebaseFirestore.instance
            .collection('flashcardDecks')
            .doc(widget.deck?.id)
            .collection('cards')
            .doc();
    setState(() {
      _flashcardItems.add(
        FlashcardFromItem(
          id: cardRef.id,
          frontInfoController: TextEditingController(),
          backInfoController: TextEditingController(),
          nextReviewDate: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _removeFlashcard(int index, String cardId) async {
    try {
      setState(() {
        _flashcardItems[index].dispose();
        _flashcardItems.removeAt(index);

        _currentCarouselPage == 0
            ? _currentCarouselPage
            : _currentCarouselPage--;
      });

      if (widget.isEdit) {
        await FirebaseFirestore.instance
            .collection('flashcardDecks')
            .doc(widget.deck!.id)
            .collection('cards')
            .doc(cardId)
            .delete();
      }
    } catch (e) {
      print("Error deleting flashcard: $e");
    }
  }

  Future<void> _saveDeck(Map<String, dynamic> currentUser) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!widget.isEdit) {
        final flashcards =
            _flashcardItems
                .map(
                  (item) => Flashcard(
                    id: item.id,
                    frontInfo: item.frontInfoController.text.trim(),
                    backInfo: item.backInfoController.text.trim(),
                    nextReviewDate: item.nextReviewDate,
                  ),
                )
                .toList();

        await _firestore
            .collection("decks")
            .doc()
            .set(
              FlashcardDeck(
                id: _firestore.collection("decks").doc().id,
                title: _titleController.text.trim(),
                cards: flashcards,
                creatorId: currentUser['id'],
              ).toMap(),
            );

        GetMessage.getGoodToastMessage("Flashcard deck added successfully!");

        if (!mounted) return;
        Navigator.pop(context);
      } else {
        final flashcards =
            _flashcardItems
                .map(
                  (item) => Flashcard(
                    id: item.id,
                    frontInfo: item.frontInfoController.text.trim(),
                    backInfo: item.backInfoController.text.trim(),
                    nextReviewDate: item.nextReviewDate,
                  ),
                )
                .toList();
        final updateDeck = widget.deck!.copyWith(
          title: _titleController.text.trim(),
          cards: flashcards,
        );
        await _firestore
            .collection("decks")
            .doc(widget.deck!.id)
            .update(updateDeck.toMap(isUpdate: true));

        GetMessage.getGoodToastMessage("Changes saved!");
        if (!mounted) return;

        Navigator.pop(context);
      }
    } catch (e) {
      GetMessage.getToastMessage(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Container(
          height: 350.responsiveH,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        Header(
          title: widget.isEdit ? "Edit Flashcard Deck" : "Add Flashcard Deck",
          hasBackButton: true,
          color: AppTheme.white,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 90),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelText: "Deck Title",
                        hintText: "Enter a deck title",
                        prefixIcon: const Icon(
                          Icons.title,
                          color: AppTheme.primary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter deck title";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      key: cardKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Flashcards",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              key: buttonKey,
                              onPressed: _addFlashcard,
                              label: const Text("Add Flashcard"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryShade,
                                foregroundColor: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                        if (_flashcardItems.isNotEmpty)
                          Center(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _removeFlashcard(
                                      _currentCarouselPage,
                                      _flashcardItems[_currentCarouselPage].id,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppTheme.red,
                                    size: 24,
                                  ),
                                ),
                                Visibility(
                                  visible: _flashcardItems.isNotEmpty,
                                  child: Center(
                                    child: Text(
                                      "${_currentCarouselPage + 1}/${_flashcardItems.length}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        CarouselSlider(
                          carouselController: _carouselController,
                          items:
                              _flashcardItems
                                  .map(
                                    (i) => Builder(
                                      builder:
                                          (context) => Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            child: FlipCard(
                                              frontInfoController:
                                                  i.frontInfoController,
                                              backInfoController:
                                                  i.backInfoController,
                                            ),
                                          ),
                                    ),
                                  )
                                  .toList(),
                          options: CarouselOptions(
                            viewportFraction: 1,
                            padEnds: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCarouselPage = index;
                              });
                            },
                            height: 500,
                            enableInfiniteScroll: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _saveDeck(widget.currentUser),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    "Save Deck",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
