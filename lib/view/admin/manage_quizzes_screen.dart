import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/view/admin/add_quiz_screen.dart';
import 'package:sp_code/view/admin/edit_quiz_screen.dart';

class ManageQuizzesScreen extends StatefulWidget {
  final String? difficultyId;
  final String? difficultyName;
  const ManageQuizzesScreen({
    super.key,
    this.difficultyId,
    this.difficultyName,
  });

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String? _selectedDifficultyId;
  List<Difficulty> _difficulties = [];
  Difficulty? _initialDifficulty;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchDifficulties();
  }

  Future<void> _fetchDifficulties() async {
    try {
      final querySnapshot = await _firestore.collection("difficulties").get();
      final difficulties =
          querySnapshot.docs
              .map((doc) => Difficulty.fromMap(doc.id, doc.data()))
              .toList();
      setState(() {
        _difficulties = difficulties;
        if (widget.difficultyId != null) {
          _initialDifficulty = _difficulties.firstWhere(
            (element) => element.id == widget.difficultyId,
            orElse:
                () => Difficulty(
                  id: widget.difficultyId!,
                  name: "Unknown",
                  description: '',
                ),
          );

          _selectedDifficultyId = _initialDifficulty!.id;
        }
      });
    } catch (e) {
      print("Error Fetching Difficulties: $e");
    }
  }

  Stream<QuerySnapshot> _getQuizzesStream() {
    Query query = _firestore.collection("quizzes");

    String? filterDifficultyId = _selectedDifficultyId ?? widget.difficultyId;

    if (_selectedDifficultyId != null) {
      query = query.where("difficultyId", isEqualTo: filterDifficultyId);
    }

    return query.snapshots();
  }

  Widget _buildTitle() {
    String? difficultyId = _selectedDifficultyId ?? widget.difficultyId;
    if (difficultyId == null) {
      return Text("All Quizzes", style: TextStyle(fontWeight: FontWeight.bold));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          _firestore.collection('difficulties').doc(difficultyId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "Loading...",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }
        final difficulty = Difficulty.fromMap(
          difficultyId,
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Text(
          difficulty.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: _buildTitle(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          AddQuizScreen(difficultyId: widget.difficultyId),
                ),
              );
            },
            icon: Icon(Icons.add_circle_outline, color: AppTheme.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: AppTheme.white,
                hintText: "Search Quizzes",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedDifficultyId,
              items: [
                DropdownMenuItem(value: null, child: Text("All Difficulties")),
                if (_initialDifficulty != null &&
                    _difficulties.every((c) => c.id != _initialDifficulty!.id))
                  DropdownMenuItem(
                    value: _initialDifficulty!.id,
                    child: Text(_initialDifficulty!.name),
                  ),
                ..._difficulties.map(
                  (difficulty) => DropdownMenuItem(
                    value: difficulty.id,
                    child: Text(difficulty.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDifficultyId = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getQuizzesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error"));
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                final quizzes =
                    snapshot.data!.docs
                        .map(
                          (doc) => Quiz.fromMap(
                            doc.id,
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .where(
                          (quiz) =>
                              _searchQuery.isEmpty ||
                              quiz.title.toLowerCase().contains(_searchQuery),
                        )
                        .toList();

                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: AppTheme.text2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No quizzes found",
                          style: TextStyle(color: AppTheme.text2, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddQuizScreen(
                                      difficultyId: widget.difficultyId,
                                      difficultyName: widget.difficultyName,
                                    ),
                              ),
                            );
                          },
                          child: Text("Add Quiz"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final Quiz quiz = quizzes[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.quiz_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: Text(
                          quiz.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.question_answer_outlined, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  quiz.questions.length > 1
                                      ? "${quiz.questions.length} Questions"
                                      : "${quiz.questions.length} Question",
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.timer_outlined, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "${quiz.timeLimit} mins",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: "edit",
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.edit,
                                      color: AppTheme.primary,
                                    ),
                                    title: Text("Edit"),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.edit,
                                      color: AppTheme.red,
                                    ),
                                    title: Text("Delete"),
                                  ),
                                ),
                              ],
                          onSelected:
                              (value) =>
                                  _handleQuizAction(context, value, quiz),
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizAction(
    BuildContext context,
    String value,
    Quiz quiz,
  ) async {
    if (value == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditQuizScreen(quiz: quiz)),
      );
    } else if (value == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Delete Quiz"),
              content: Text("Are you sure you want to delete this quiz?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text("Delete", style: TextStyle(color: AppTheme.red)),
                ),
              ],
            ),
      );

      if (confirm == true) {
        await _firestore.collection("quizzes").doc(quiz.id).delete();
      }
    }
  }
}
