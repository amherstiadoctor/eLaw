import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.selectedAnswers,
    required this.loggedInUser,
  });
  final UserEntity loggedInUser;
  final Quiz quiz;
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, int?> selectedAnswers;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.text2,
            ),
          ),
        ],
      ),
    ).animate().scale(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 300),
    );

  Widget _buildAnswerRow(String label, String answer, Color answerColor) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.text2),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: answerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            answer,
            style: TextStyle(color: answerColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );

  IconData _getPerformanceIcon(double score) {
    if (score >= 0.9) return Icons.emoji_events;
    if (score >= 0.8) return Icons.star;
    if (score >= 0.6) return Icons.thumb_up;
    if (score >= 0.4) return Icons.trending_up;
    return Icons.refresh;
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return AppTheme.green;
    if (score >= 0.5) return AppTheme.secondaryShade;
    return AppTheme.red;
  }

  String _getPerformanceMessage(double score) {
    if (score >= 0.9) return "Outstanding!";
    if (score >= 0.8) return "Great Job!";
    if (score >= 0.6) return "Good Effort!";
    if (score >= 0.4) return "Keep Practicing!";
    return "Try Again!";
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.correctAnswers / widget.totalQuestions;
    final scorePercentage = (score * 100).round();
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryTint],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppTheme.white,
                          ),
                        ),
                        const Text(
                          'Quiz Result',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircularPercentIndicator(
                          radius: 100,
                          lineWidth: 15,
                          animation: true,
                          animationDuration: 1500,
                          percent: score,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$scorePercentage%',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.white,
                                ),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: AppTheme.white,
                          backgroundColor: AppTheme.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ).animate().scale(
                    delay: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPerformanceIcon(score),
                          color: _getScoreColor(score),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPerformanceMessage(score),
                          style: TextStyle(
                            color: _getScoreColor(score),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Correct",
                      widget.correctAnswers.toString(),
                      Icons.check_circle,
                      AppTheme.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      "Incorrect",
                      (widget.totalQuestions - widget.correctAnswers)
                          .toString(),
                      Icons.cancel,
                      AppTheme.red,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        "Detailed Analysis",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.quiz.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final selectedAnswer = widget.selectedAnswers[index];
                    final isCorrect =
                        selectedAnswer != null &&
                        selectedAnswer == question.correctOptionIndex;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isCorrect
                                      ? AppTheme.green.withOpacity(0.1)
                                      : AppTheme.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect
                                  ? Icons.check_circle_outline
                                  : Icons.close,
                              color: isCorrect ? AppTheme.green : AppTheme.red,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Question ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.text,
                            ),
                          ),
                          subtitle: Text(
                            question.text,
                            style: const TextStyle(
                              color: AppTheme.text2,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                                right: 5,
                                left: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.text,
                                    style: const TextStyle(
                                      color: AppTheme.text,
                                      fontSize: 18,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildAnswerRow(
                                    "Your Answer: ",
                                    selectedAnswer != null
                                        ? question.options[selectedAnswer]
                                        : "Not Answered",
                                    isCorrect ? AppTheme.green : AppTheme.red,
                                  ),
                                  const SizedBox(height: 12),
                                  Visibility(
                                    visible: !isCorrect,
                                    child: _buildAnswerRow(
                                      "CorrectAnswer: ",
                                      question.options[question
                                          .correctOptionIndex],
                                      AppTheme.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideX(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 300),
                      delay: Duration(milliseconds: 100 * index),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      label: const Text(
                        "Back to Quizzes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
