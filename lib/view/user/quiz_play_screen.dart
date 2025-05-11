import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/model/question.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/taken_quiz.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/view/user/quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({
    super.key,
    required this.quiz,
    required this.loggedInUser,
  });
  final UserEntity loggedInUser;
  final Quiz quiz;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late PageController _pageController;

  int _currentQuestionIndex = 0;
  final Map<int, int?> _selectedAnswers = {};

  int _totalMinutes = 0;
  int _remainingMinutes = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool isOptionSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _totalMinutes = widget.quiz.timeLimit;
    _remainingMinutes = _totalMinutes;
    _remainingSeconds = 0;

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          if (_remainingMinutes > 0) {
            _remainingMinutes--;
            _remainingSeconds = 59;
          } else {
            _timer?.cancel();
            _completeQuiz();
          }
        }
      });
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedAnswers[_currentQuestionIndex] == null) {
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = optionIndex;
        isOptionSelected = true;
      });
    }
  }

  Future<void> _addQuizzesTaken({required double quizScore}) async {
    String? userId;
    try {
      final TakenQuiz? foundQuiz = widget.loggedInUser.quizzesTaken?.firstWhere(
        (quiz) => quiz.quizId == widget.quiz.id,
      );
      if (foundQuiz != null) {
        final index = widget.loggedInUser.quizzesTaken!.indexWhere(
          (quiz) => quiz.quizId == widget.quiz.id,
        );

        widget.loggedInUser.quizzesTaken![index].quizScore = quizScore;

        final List<Map<String, dynamic>> quizzesMap =
            widget.loggedInUser.quizzesTaken!
                .map((quiz) => quiz.toMap(isUpdate: true))
                .toList();

        await _firestore
            .collection("Users")
            .where("email", isEqualTo: widget.loggedInUser.email)
            .get()
            .then((querySnapshot) {
              userId = querySnapshot.docs[0].data()["id"];
            }, onError: (e) => print("Error completing: $e"));

        await _firestore.collection("Users").doc(userId).update({
          'quizzesTaken': quizzesMap,
        });
      } else {
        final TakenQuiz quiz = TakenQuiz(
          quizId: widget.quiz.id,
          quizScore: quizScore,
        );

        await _firestore
            .collection("Users")
            .where("email", isEqualTo: widget.loggedInUser.email)
            .get()
            .then((querySnapshot) {
              userId = querySnapshot.docs[0].data()["id"];
            }, onError: (e) => print("Error completing: $e"));

        await _firestore.collection("Users").doc(userId).update({
          'quizzesTaken': FieldValue.arrayUnion([quiz.toMap(isUpdate: true)]),
        });
      }
    } catch (e) {
      GetMessage.getToastMessage(e.toString());
    }
  }

  Future<void> _addQuizzesCompleted(Quiz quiz) async {
    String? userId;
    try {
      if (widget.loggedInUser.quizzesCompleted!.contains(widget.quiz.id)) {
      } else {
        final currentCompletedList = widget.loggedInUser.quizzesCompleted;
        currentCompletedList!.add(quiz.id);

        await _firestore
            .collection("Users")
            .where("email", isEqualTo: widget.loggedInUser.email)
            .get()
            .then((querySnapshot) {
              userId = querySnapshot.docs[0].data()["id"];
            }, onError: (e) => print("Error completing: $e"));

        await _firestore.collection("Users").doc(userId).update({
          'quizzesCompleted': currentCompletedList,
        });
      }
    } catch (e) {
      GetMessage.getToastMessage(e.toString());
    }
  }

  Future<void> _calculatePoints(int correctAnswers) async {
    String? userId;
    int? calculatedPoints;
    if (widget.quiz.difficultyId == "Easy") {
      await _firestore
          .collection("Users")
          .where("email", isEqualTo: widget.loggedInUser.email)
          .get()
          .then((querySnapshot) {
            userId = querySnapshot.docs[0].data()["id"];
            calculatedPoints = querySnapshot.docs[0].data()["totalPoints"];
          }, onError: (e) => print("Error completing: $e"));

      await _firestore.collection("Users").doc(userId).update({
        'totalPoints': calculatedPoints! + 5,
      });
    } else if (widget.quiz.difficultyId == "Medium") {
      await _firestore
          .collection("Users")
          .where("email", isEqualTo: widget.loggedInUser.email)
          .get()
          .then((querySnapshot) {
            userId = querySnapshot.docs[0].data()["id"];
            calculatedPoints = querySnapshot.docs[0].data()["totalPoints"];
          }, onError: (e) => print("Error completing: $e"));

      await _firestore.collection("Users").doc(userId).update({
        'totalPoints': calculatedPoints! + 15,
      });
    } else {
      await _firestore
          .collection("Users")
          .where("email", isEqualTo: widget.loggedInUser.email)
          .get()
          .then((querySnapshot) {
            userId = querySnapshot.docs[0].data()["id"];
            calculatedPoints = querySnapshot.docs[0].data()["totalPoints"];
          }, onError: (e) => print("Error completing: $e"));

      await _firestore.collection("Users").doc(userId).update({
        'totalPoints': calculatedPoints! + 50,
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        isOptionSelected = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    _timer?.cancel();

    final int correctAnswers = _calculateScore();
    final score = correctAnswers / widget.quiz.questions.length;

    if (widget.loggedInUser.quizzesCompleted!.contains(widget.quiz.id)) {
      GetMessage.getGoodToastMessage(
        "You've already perfected this quiz!\nCan't get anymore points",
      );
    } else {
      _addQuizzesTaken(quizScore: score);
      if (score == 1) {
        _addQuizzesCompleted(widget.quiz);
        _calculatePoints(correctAnswers);
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultScreen(
              quiz: widget.quiz,
              totalQuestions: widget.quiz.questions.length,
              correctAnswers: correctAnswers,
              selectedAnswers: _selectedAnswers,
              loggedInUser: widget.loggedInUser,
            ),
      ),
    );
  }

  int _calculateScore() {
    int correctAnswers = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final selectedAnswer = _selectedAnswers[i];
      if (selectedAnswer != null &&
          selectedAnswer == widget.quiz.questions[i].correctOptionIndex) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  Color _getTimerColor() {
    final double timeProgress =
        1 -
        ((_remainingMinutes * 60 + _remainingSeconds) / (_totalMinutes * 60));
    if (timeProgress < 0.4) return AppTheme.green;
    if (timeProgress < 0.6) return AppTheme.secondary;
    if (timeProgress < 0.8) return AppTheme.tertiary;
    return AppTheme.red;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.primary,
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      color: AppTheme.text,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 55,
                          width: 55,
                          child: CircularProgressIndicator(
                            value:
                                (_remainingMinutes * 60 + _remainingSeconds) /
                                (_totalMinutes * 60),
                            strokeWidth: 5,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getTimerColor(),
                            ),
                          ),
                        ),
                        Text(
                          '$_remainingMinutes:${_remainingSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getTimerColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end:
                        (_currentQuestionIndex + 1) /
                        widget.quiz.questions.length,
                  ),
                  duration: const Duration(milliseconds: 300),
                  builder:
                      (context, progress, child) => LinearProgressIndicator(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10),
                          right: Radius.circular(10),
                        ),
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                        minHeight: 6,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.quiz.questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final question = widget.quiz.questions[index];
                return _buildQuestionCard(question, index);
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildQuestionCard(Question question, int index) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: const TextStyle(fontSize: 16, color: AppTheme.text2),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 24),
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswers[index] == optionIndex;
              final isCorrect =
                  _selectedAnswers[index] == question.correctOptionIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? isCorrect
                                ? AppTheme.green.withOpacity(0.1)
                                : AppTheme.red.withOpacity(0.1)
                            : AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? isCorrect
                                  ? AppTheme.green
                                  : AppTheme.red
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: ListTile(
                    onTap:
                        _selectedAnswers[index] == null
                            ? () => _selectAnswer(optionIndex)
                            : null,
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? isCorrect
                                    ? AppTheme.green
                                    : AppTheme.red
                                : _selectedAnswers[index] != null
                                ? Colors.grey.shade500
                                : AppTheme.text,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? isCorrect
                                ? const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppTheme.green,
                                )
                                : const Icon(Icons.close, color: AppTheme.red)
                            : null,
                  ),
                ),
              );
            }),
            const Spacer(),
            Visibility(
              visible: isOptionSelected,
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    _selectedAnswers[index] != null ? _nextQuestion() : null;
                  },
                  child: Text(
                    index == widget.quiz.questions.length - 1
                        ? 'Finish Quiz'
                        : 'Next Question',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(duration: const Duration(milliseconds: 350))
      .slideY(begin: 0.1, end: 0);
}
