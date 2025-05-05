import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/model/question.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/theme/theme.dart';

class EditQuizScreen extends StatefulWidget {
  final Quiz quiz;
  const EditQuizScreen({super.key, required this.quiz});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class QuestionFromItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionsController;
  int correctOptionIndex;

  QuestionFromItem({
    required this.questionController,
    required this.optionsController,
    required this.correctOptionIndex,
  });

  void dispose() {
    questionController.dispose();
    optionsController.forEach((element) {
      element.dispose();
    });
  }
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedCategoryId;
  late List<QuestionFromItem> _questionsItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _initData() {
    _titleController = TextEditingController(text: widget.quiz.title);
    _timeLimitController = TextEditingController(
      text: widget.quiz.timeLimit.toString(),
    );

    _questionsItems =
        widget.quiz.questions.map((question) {
          return QuestionFromItem(
            questionController: TextEditingController(text: question.text),
            optionsController:
                question.options
                    .map((option) => TextEditingController(text: option))
                    .toList(),
            correctOptionIndex: question.correctOptionIndex,
          );
        }).toList();
  }

  void _addQuestion() {
    setState(() {
      _questionsItems.add(
        QuestionFromItem(
          questionController: TextEditingController(),
          optionsController: List.generate(4, (e) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      if (_questionsItems.length > 1) {
        _questionsItems[index].dispose();
        _questionsItems.removeAt(index);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Quiz must have at least one question")),
        );
      }
    });
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questions =
          _questionsItems
              .map(
                (item) => Question(
                  text: item.questionController.text.trim(),
                  options:
                      item.optionsController.map((e) => e.text.trim()).toList(),
                  correctOptionIndex: item.correctOptionIndex,
                ),
              )
              .toList();

      final updateQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        timeLimit: int.parse(_timeLimitController.text),
        questions: questions,
        createdAt: widget.quiz.createdAt,
      );

      await _firestore
          .collection("quizzes")
          .doc(widget.quiz.id)
          .update(updateQuiz.toMap(isUpdate: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Quiz updated successfully",
            style: TextStyle(color: AppTheme.white),
          ),
          backgroundColor: AppTheme.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update quiz",
            style: TextStyle(color: AppTheme.white),
          ),
          backgroundColor: AppTheme.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: Text("Edit Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateQuiz,
            icon: Icon(Icons.save, color: AppTheme.primary),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Text(
              "Quiz Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Quiz Title",
                hintText: "Enter a quiz title",
                prefixIcon: Icon(Icons.title, color: AppTheme.primary),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter quiz title";
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _timeLimitController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Time Limit (in minutes)",
                hintText: "Enter time limit",
                prefixIcon: Icon(Icons.timer, color: AppTheme.primary),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter time limit";
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return "Please enter a valid time limit";
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
                      "Questions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      label: Text("Add Question"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ..._questionsItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final QuestionFromItem question = entry.value;

                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Question ${index + 1}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              if (_questionsItems.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _removeQuestion(index);
                                  },
                                  icon: Icon(Icons.delete, color: AppTheme.red),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: question.questionController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.primary,
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: "Question",
                              hintText: "Enter question",
                              prefixIcon: Icon(
                                Icons.question_answer,
                                color: AppTheme.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter question";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          ...question.optionsController.asMap().entries.map((
                            entry,
                          ) {
                            final optionIndex = entry.key;
                            final controller = entry.value;

                            return Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    activeColor: AppTheme.primary,

                                    value: optionIndex,
                                    groupValue: question.correctOptionIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        question.correctOptionIndex = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppTheme.primary,
                                            width: 0.0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        labelText: "Option ${optionIndex + 1}",
                                        hintText: "Enter option",
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter option";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateQuiz,
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
                                "Update Quiz",
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
