import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/view/user/quiz_play_screen.dart';

class DifficultyScreen extends StatefulWidget {
  const DifficultyScreen({
    super.key,
    required this.difficulty,
    required this.loggedInUser,
  });
  final UserEntity loggedInUser;
  final Difficulty difficulty;

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load quizzes")));
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
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
      final currentUser = fetchedDocs[0].data() as Map<String, dynamic>;
      if (currentUser.isEmpty) {
        return const Center(child: Text("No user found."));
      }
      return Scaffold(
        body:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                )
                : _quizzes.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: AppTheme.text2,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No quizzes available for this difficulty",
                        style: TextStyle(fontSize: 16, color: AppTheme.text2),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Go Back"),
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.white,
                        ),
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
                              const Icon(
                                Icons.category_rounded,
                                size: 64,
                                color: AppTheme.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.difficulty.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = _quizzes[index];
                            return _buildQuizCard(quiz, index, currentUser);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      );
    },
  );

  Widget _buildQuizCard(
    Quiz quiz,
    int index,
    Map<String, dynamic> currentUser,
  ) =>
      Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
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
                        (context) => QuizPlayScreen(
                          quiz: quiz,
                          loggedInUser: UserEntity.fromJson(currentUser),
                        ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: AppTheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.text,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.question_answer_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    quiz.questions.length > 1
                                        ? '${quiz.questions.length} Questions'
                                        : '${quiz.questions.length} Question',
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.timer_outlined, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${quiz.timeLimit} mins'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
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
          .slideY(
            begin: 0.5,
            end: 0,
            duration: const Duration(milliseconds: 300),
          )
          .fadeIn();
}
