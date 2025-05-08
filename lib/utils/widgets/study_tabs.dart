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
import 'package:sp_code/utils/get_user.dart';
import 'package:sp_code/utils/widgets/circle_tab_indicator.dart';
import 'package:sp_code/view/common/add_deck_screen.dart';
import 'package:sp_code/view/common/view_deck_screen.dart';
import 'package:sp_code/view/user/difficulty_screen.dart';

class StudyTabs extends StatefulWidget {
  StudyTabs({Key? key}) : super(key: key);
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
  List<FlashcardDeck> _allDecks = [];
  bool isLoading = false;
  TabController? _tabController;
  int _selectedIndex = 0;
  UserEntity loggedInUser = UserEntity.empty();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _tabController!.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
      });
    });
    checkUser();
    _fetchDifficulties();
    _fetchFlashcardDecks();
  }

  checkUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await widget._authService
          .googleRoles(
            user: FirebaseAuth.instance.currentUser!,
            register: false,
          )
          .then((result) {
            setState(() {
              loggedInUser = getUser.getLoggedInUser(result);
            });
          });
    }
  }

  Future<void> _fetchFlashcardDecks() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await FirebaseFirestore.instance.collection('decks').get();

    setState(() {
      isLoading = false;
      _allDecks =
          snapshot.docs
              .map((doc) => FlashcardDeck.fromMap(doc.id, doc.data()))
              .toList();
    });
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
  }) {
    return Card(
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
                        loggedInUser: loggedInUser,
                      ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.quiz, size: 28, color: AppTheme.primary),
                  ),
                  SizedBox(width: 10),
                  Text(
                    difficulty.name,
                    style: TextStyle(
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
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }

  _buildDeckItem({required FlashcardDeck deck, required int index}) {
    return Card(
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
                  builder: (context) => ViewDeckScreen(deckId: deck.id),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.view_carousel,
                      size: 28,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    deck.title,
                    style: TextStyle(
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
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          decoration: const BoxDecoration(color: AppTheme.white),
          child: TabBarView(
            controller: _tabController,
            children: [
              isLoading
                  ? Center(
                    child: SizedBox(
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : _filteredDifficulties.isNotEmpty
                  ? SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
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
                  : Center(child: Text("No Difficulties Found")),
              isLoading
                  ? Center(
                    child: SizedBox(
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : _allDecks.isNotEmpty
                  ? SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _allDecks.length,
                        itemBuilder: (context, index) {
                          final flashcardDeck = _allDecks[index];
                          return _buildDeckItem(
                            deck: flashcardDeck,
                            index: index,
                          );
                        },
                      ),
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("No Flashcards Found"),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AddDeckScreen(loggedInUser: loggedInUser),
                            ),
                          );
                        },
                        child: Text("Add flashcard deck"),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
