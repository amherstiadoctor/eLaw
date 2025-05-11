// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/model/flashcard_deck.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/utils/widgets/circle_tab_indicator.dart';
import 'package:sp_code/view/common/manage_deck_screen.dart';
import 'package:sp_code/view/common/view_deck_screen.dart';
import 'package:sp_code/view/user/difficulty_screen.dart';

class StudyTabs extends StatefulWidget {
  StudyTabs({super.key, required this.currentUser});
  final Map<String, dynamic> currentUser;
  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<StudyTabs> createState() => _StudyTabsState();
}

class _StudyTabsState extends State<StudyTabs>
    with SingleTickerProviderStateMixin {
  List<Difficulty> _allDifficulties = [];
  List<Difficulty> _filteredDifficulties = [];
  bool isLoading = false;
  TabController? _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _tabController!.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
      });
    });
    _fetchDifficulties();
  }

  Future<void> _fetchDifficulties() async {
    setState(() {
      isLoading = true;
    });

    final snapshot =
        await FirebaseFirestore.instance
            .collection('difficulties')
            .orderBy('createdAt', descending: false)
            .get();

    setState(() {
      isLoading = false;
      _allDifficulties =
          snapshot.docs
              .map((doc) => Difficulty.fromMap(doc.id, doc.data()))
              .toList();

      _filteredDifficulties = _allDifficulties;
    });
  }

  Widget _buildDifficultyItem({
    required Difficulty difficulty,
    required int index,
  }) =>
      Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DifficultyScreen(
                          difficulty: difficulty,
                          loggedInUser: UserEntity.fromJson(widget.currentUser),
                        ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz,
                        size: 28,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      difficulty.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate(delay: Duration(milliseconds: 100 * index))
          .slideY(
            begin: 0.5,
            end: 0,
            duration: const Duration(milliseconds: 300),
          )
          .fadeIn();

  _buildDeckItem({required FlashcardDeck deck, required int index}) =>
      Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.view_carousel_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                title: Text(
                  deck.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          deck.cards.length > 1
                              ? "${deck.cards.length} Flashcards"
                              : deck.cards.isEmpty
                              ? "No Flashcards"
                              : "${deck.cards.length} Flashcard",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: "edit",
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit, color: AppTheme.primary),
                            title: Text("Edit"),
                          ),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit, color: AppTheme.red),
                            title: Text("Delete"),
                          ),
                        ),
                      ],
                  onSelected:
                      (value) => _handleDeckAction(context, value, deck),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewDeckScreen(deck: deck),
                    ),
                  );
                },
              ),
            ),
          )
          .animate(delay: Duration(milliseconds: 100 * index))
          .slideY(
            begin: 0.5,
            end: 0,
            duration: const Duration(milliseconds: 300),
          )
          .fadeIn();

  Future<void> _handleDeckAction(
    BuildContext context,
    String value,
    FlashcardDeck deck,
  ) async {
    if (value == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ManageDeckScreen(
                currentUser: widget.currentUser,
                isEdit: true,
                deck: deck,
              ),
        ),
      );
    } else if (value == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Delete Flashcard Deck"),
              content: const Text("Are you sure you want to delete this deck?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: AppTheme.red),
                  ),
                ),
              ],
            ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection("decks")
            .doc(deck.id)
            .delete();

        GetMessage.getToastMessage("Flashcard deck deleted");
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TabBar(
        controller: _tabController,
        indicator: CircleTabIndicator(color: AppTheme.primary, radius: 3),
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.grey3,
        unselectedLabelStyle: const TextStyle(color: AppTheme.grey2),
        tabs: const [Tab(text: "Quizzes"), Tab(text: "Flashcards")],
        dividerHeight: 0,
      ),
      const SizedBox(height: 10),
      Container(
        height: 550,
        decoration: const BoxDecoration(color: AppTheme.grey1),
        child: TabBarView(
          controller: _tabController,
          children: [
            isLoading
                ? const Center(
                  child: SizedBox(
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                )
                : _filteredDifficulties.isNotEmpty
                ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredDifficulties.length,
                      itemBuilder: (context, index) {
                        final difficulty = _filteredDifficulties[index];
                        return _buildDifficultyItem(
                          difficulty: difficulty,
                          index: index,
                        );
                      },
                    ),
                  ),
                )
                : const Center(child: Text("No Difficulties Found")),
            isLoading
                ? const Center(
                  child: SizedBox(
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                )
                : StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('decks')
                          .where(
                            'creatorId',
                            isEqualTo: widget.currentUser['id'],
                          )
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Error");
                    }

                    if (!snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No Flashcards Found"),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ManageDeckScreen(
                                        currentUser: widget.currentUser,
                                      ),
                                ),
                              );
                            },
                            child: const Text("Add flashcard deck"),
                          ),
                        ],
                      );
                    }

                    final allDecks =
                        snapshot.data!.docs
                            .map(
                              (doc) => FlashcardDeck.fromMap(
                                doc.id,
                                doc.data() as Map<String, dynamic>,
                              ),
                            )
                            .toList();

                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ManageDeckScreen(
                                      currentUser: widget.currentUser,
                                    ),
                              ),
                            );
                          },
                          child: const Text("Add flashcard deck"),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              left: 16,
                              top: 16,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: allDecks.length,
                              itemBuilder: (context, index) {
                                final flashcardDeck = allDecks[index];
                                return _buildDeckItem(
                                  deck: flashcardDeck,
                                  index: index,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ],
        ),
      ),
    ],
  );
}
