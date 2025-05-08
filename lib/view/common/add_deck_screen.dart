import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/flashcard.dart';
import 'package:sp_code/model/flashcard_deck.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/utils/widgets/flip_card.dart';

class AddDeckScreen extends StatefulWidget {
  final UserEntity loggedInUser;
  const AddDeckScreen({super.key, required this.loggedInUser});

  @override
  State<AddDeckScreen> createState() => _AddDeckScreenState();
}

class FlashcardFromItem {
  final TextEditingController flashcardTitleController;
  final TextEditingController frontInfoController;
  final TextEditingController backInfoController;

  FlashcardFromItem({
    required this.flashcardTitleController,
    required this.frontInfoController,
    required this.backInfoController,
  });

  void dispose() {
    flashcardTitleController.dispose();
    frontInfoController.dispose();
    backInfoController.dispose();
  }
}

class _AddDeckScreenState extends State<AddDeckScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  List<FlashcardFromItem> _flashcardItems = [];
  bool _isLoading = false;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  var _currentCarouselPage = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    super.dispose();
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

  Future<void> _saveDeck() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
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
            ).toMap(),
          );

      GetMessage.getGoodToastMessage("Flashcard deck added successfully!");

      Navigator.pop(context);
    } catch (e) {
      GetMessage.getToastMessage(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addUserFlashcardDeck(FlashcardDeck deck) async {
    String? userId;
    try {
      final currentDeckList = widget.loggedInUser.decks;
      currentDeckList.add(deck.id);

      await _firestore
          .collection("Users")
          .where("email", isEqualTo: widget.loggedInUser.email)
          .get()
          .then((querySnapshot) {
            userId = querySnapshot.docs[0].data()["id"];
          }, onError: (e) => print("Error completing: $e"));

      await _firestore.collection("Users").doc(userId).update({
        'decks': currentDeckList,
      });
    } catch (e) {
      GetMessage.getToastMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: Text(
          "Add Flashcard Deck",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.save, color: AppTheme.primary),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.primary,
                        width: 0.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: "Deck Title",
                    hintText: "Enter a deck title",
                    prefixIcon: Icon(Icons.title, color: AppTheme.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter deck title";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Flashcards",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addFlashcard,
                          label: Text("Add Flashcard"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CarouselSlider(
                      carouselController: _carouselController,
                      items:
                          _flashcardItems.map((i) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              child: FlipCard(
                                frontInfoController: i.frontInfoController,
                              ),
                            );
                          }).toList(),
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
                    SizedBox(height: 5),
                    Visibility(
                      visible: _flashcardItems.isNotEmpty,
                      child: Center(
                        child: Text(
                          "${_currentCarouselPage + 1}/${_flashcardItems.length}",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDeck,
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
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
    );
  }
}
