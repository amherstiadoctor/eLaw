// ignore_for_file: must_be_immutable

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
    required this.flashcardTitleController,
    required this.frontInfoController,
    required this.backInfoController,
  });
  final TextEditingController flashcardTitleController;
  final TextEditingController frontInfoController;
  final TextEditingController backInfoController;

  void dispose() {
    flashcardTitleController.dispose();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isEdit) {
      _initData();
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
                flashcardTitleController: TextEditingController(
                  text: card.title,
                ),
                frontInfoController: TextEditingController(
                  text: card.frontInfo,
                ),
                backInfoController: TextEditingController(text: card.backInfo),
              ),
            )
            .toList();
  }

  void _addFlashcard() {
    setState(() {
      _flashcardItems.add(
        FlashcardFromItem(
          flashcardTitleController: TextEditingController(),
          frontInfoController: TextEditingController(),
          backInfoController: TextEditingController(),
        ),
      );
    });
  }

  void _removeFlashcard(int index) {
    setState(() {
      _flashcardItems[index].dispose();
      _flashcardItems.removeAt(index);
    });
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
                    title: item.flashcardTitleController.text.trim(),
                    frontInfo: item.frontInfoController.text.trim(),
                    backInfo: item.backInfoController.text.trim(),
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
                    title: item.flashcardTitleController.text.trim(),
                    frontInfo: item.frontInfoController.text.trim(),
                    backInfo: item.backInfoController.text.trim(),
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
                                    _removeFlashcard(_currentCarouselPage);
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
