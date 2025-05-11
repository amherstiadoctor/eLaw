import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/flashcard_deck.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/view/common/view_deck_screen.dart';
import 'package:sp_code/view/user/quiz_play_screen.dart';
// import 'package:sp_code/view/common/view_deck_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.loggedInUser});
  final UserEntity loggedInUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.grey1,
    body: StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection("Users")
              .where('email', isEqualTo: widget.loggedInUser.email)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final fetchedDocs = snapshot.data!.docs;
        final currentUser = fetchedDocs[0].data();
        if (currentUser.isEmpty) {
          return const Center(child: Text("No user found."));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 225,
              pinned: true,
              floating: true,
              centerTitle: false,
              backgroundColor: AppTheme.primary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: kToolbarHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Good ${greeting()}, ${widget.loggedInUser.firstName}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Let's test your knowledge today",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(left: 16, top: 20),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "Recent Quizzes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            currentUser['quizzesTaken'].isNotEmpty
                ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentUser['quizzesTaken'].length,
                      itemBuilder: (context, index) {
                        final quiz = currentUser['quizzesTaken'][index];
                        return _buildRecentQuizCard(quiz, index, currentUser);
                      },
                    ),
                  ),
                )
                : const SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: Text("No recent quizzes yet!")),
                  ),
                ),
            const SliverPadding(
              padding: EdgeInsets.only(left: 16, top: 20),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "Review Flashcards",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildDueFlashcardDeckItem(currentUser),
              ),
            ),
          ],
        );
      },
    ),
  );

  Stream<List<FlashcardDeck>> getDecks(Map<String, dynamic> currentUser) =>
      FirebaseFirestore.instance
          .collection('decks')
          .where('creatorId', isEqualTo: currentUser['id'])
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => FlashcardDeck.fromMap(doc.id, doc.data()))
                    .toList(),
          );

  Widget _buildDueFlashcardDeckItem(Map<String, dynamic> currentUser) {
    String formatDate(DateTime date) =>
        date.hour < 12
            ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute} AM'
            : '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute} PM';

    return StreamBuilder<List<FlashcardDeck>>(
      stream: getDecks(currentUser),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final decks = snapshot.data!;

        if (decks.isEmpty) {
          return const Center(child: Text("No flashcards to review yet!"));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final deck = decks[index];
            final dueCards =
                deck.cards
                    .where(
                      (card) => card.nextReviewDate.isBefore(DateTime.now()),
                    )
                    .toList();

            if (dueCards.isEmpty) {
              return const SizedBox(); // Skip decks with no due cards
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewDeckScreen(deck: deck),
                  ),
                );
              },
              child:
                  Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primary),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deck.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.text,
                                      ),
                                    ),
                                    Text(
                                      "Due on ${formatDate(dueCards[index].nextReviewDate)}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.text2,
                                      ),
                                    ),
                                  ],
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
                      .fadeIn(),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentQuizCard(
    Map<String, dynamic> recentQuiz,
    int index,
    Map<String, dynamic> currentUser,
  ) {
    Color getScoreColor(double score) {
      if (score >= 0.9) return AppTheme.green;
      if (score >= 0.5) return AppTheme.secondaryShade;
      return AppTheme.red;
    }

    String formatDate(DateTime date) =>
        '${date.day}/${date.month}/${date.year}';

    final scorePercentage = (recentQuiz['quizScore'] * 100).round();
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('quizzes')
              .doc(recentQuiz['quizId'])
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final fetchedQuiz = snapshot.data as DocumentSnapshot;
        final Map<String, dynamic> data =
            snapshot.data?.data() as Map<String, dynamic>;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => QuizPlayScreen(
                      quiz: Quiz.fromMap(recentQuiz['quizId'], data),
                      loggedInUser: UserEntity.fromJson(currentUser),
                    ),
              ),
            );
          },
          child:
              Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fetchedQuiz['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.text,
                                  ),
                                ),
                                Text(
                                  "Last Taken on ${formatDate(recentQuiz['takenAt'].toDate())}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.text2,
                                  ),
                                ),
                              ],
                            ),
                            CircularPercentIndicator(
                              radius: 30,
                              lineWidth: 10,
                              animation: true,
                              animationDuration: 1500,
                              percent: recentQuiz['quizScore'],
                              center: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$scorePercentage%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: getScoreColor(
                                        recentQuiz['quizScore'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: getScoreColor(
                                recentQuiz['quizScore'],
                              ),
                              backgroundColor: getScoreColor(
                                recentQuiz['quizScore'],
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
                  .fadeIn(),
        );
      },
    );
  }
}
