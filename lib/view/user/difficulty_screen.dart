import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/view/user/quiz_play_screen.dart';

class DifficultyScreen extends StatefulWidget {
  final UserEntity loggedInUser;
  final Difficulty difficulty;
  const DifficultyScreen({
    super.key,
    required this.difficulty,
    required this.loggedInUser,
  });

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  Future<void> _addQuizzesTaken(Quiz quiz) async {
    String? userId;
    try {
      final currentTakenList = widget.loggedInUser.quizzesTaken;
      currentTakenList.add(quiz.id);

      await _firestore
          .collection("Users")
          .where("email", isEqualTo: widget.loggedInUser.email)
          .get()
          .then((querySnapshot) {
            userId = querySnapshot.docs[0].data()["id"];
          }, onError: (e) => print("Error completing: $e"));

      await _firestore.collection("Users").doc(userId).update({
        'quizzesTaken': currentTakenList,
      });
    } catch (e) {
      GetMessage.getToastMessage(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('quizzes')
              .where('difficultyId', isEqualTo: widget.difficulty.id)
              .get();

      setState(() {
        _quizzes =
            snapshot.docs
                .map((doc) => Quiz.fromMap(doc.id, doc.data()))
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load quizzes")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
              : _quizzes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined, size: 64, color: AppTheme.text2),
                    SizedBox(height: 16),
                    Text(
                      "No quizzes available for this difficulty",
                      style: TextStyle(fontSize: 16, color: AppTheme.text2),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Go Back"),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    foregroundColor: AppTheme.white,
                    backgroundColor: AppTheme.primary,
                    expandedHeight: 230,
                    floating: false,
                    pinned: true,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: AppTheme.white),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.difficulty.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      background: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 64,
                              color: AppTheme.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              widget.difficulty.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = _quizzes[index];
                          return _buildQuizCard(quiz, index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, int index) {
    return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (widget.loggedInUser.quizzesTaken.isEmpty) {
                _addQuizzesTaken(quiz);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => QuizPlayScreen(
                          quiz: quiz,
                          loggedInUser: widget.loggedInUser,
                        ),
                  ),
                );
              } else {
                for (var item in widget.loggedInUser.quizzesTaken) {
                  if (item == quiz.id) {
                    if (widget.loggedInUser.quizzesCompleted.isEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => QuizPlayScreen(
                                quiz: quiz,
                                loggedInUser: widget.loggedInUser,
                              ),
                        ),
                      );
                    } else {
                      for (var item in widget.loggedInUser.quizzesCompleted) {
                        if (item == quiz.id) {
                          GetMessage.getGoodToastMessage(
                            "You've already perfected this quiz!\nCan't get anymore points",
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => QuizPlayScreen(
                                    quiz: quiz,
                                    loggedInUser: widget.loggedInUser,
                                  ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => QuizPlayScreen(
                                    quiz: quiz,
                                    loggedInUser: widget.loggedInUser,
                                  ),
                            ),
                          );
                        }
                      }
                    }
                  } else {
                    widget.loggedInUser.quizzesTaken.add(quiz.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => QuizPlayScreen(
                              quiz: quiz,
                              loggedInUser: widget.loggedInUser,
                            ),
                      ),
                    );
                  }
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      color: AppTheme.primary,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.question_answer_outlined, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  quiz.questions.length > 1
                                      ? '${quiz.questions.length} Questions'
                                      : '${quiz.questions.length} Question',
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.timer_outlined, size: 16),
                                SizedBox(width: 4),
                                Text('${quiz.timeLimit} mins'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 30,
                    color: AppTheme.primary,
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
}
