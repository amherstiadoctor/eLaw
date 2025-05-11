import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/model/quiz.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/view/admin/add_quiz_screen.dart';
import 'package:sp_code/view/admin/edit_quiz_screen.dart';

class ManageQuizzesScreen extends StatefulWidget {
  const ManageQuizzesScreen({
    super.key,
    this.difficultyId,
    this.difficultyName,
  });
  final String? difficultyId;
  final String? difficultyName;

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

    final String? filterDifficultyId = _selectedDifficultyId ?? widget.difficultyId;

    if (_selectedDifficultyId != null) {
      query = query.where("difficultyId", isEqualTo: filterDifficultyId);
    }

    return query.snapshots();
  }

  Widget _buildTitle() {
    final String? difficultyId = _selectedDifficultyId ?? widget.difficultyId;
    if (difficultyId == null) {
      return const Text("All Quizzes", style: TextStyle(fontWeight: FontWeight.bold));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          _firestore.collection('difficulties').doc(difficultyId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text(
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: AppTheme.white,
                hintText: "Search Quizzes",
                prefixIcon: const Icon(Icons.search),
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
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.primary, width: 0.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedDifficultyId,
              items: [
                const DropdownMenuItem(value: null, child: Text("All Difficulties")),
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
                  return const Center(child: Text("Error"));
                }

                if (!snapshot.hasData) {
                  return const Center(
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
                        const Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: AppTheme.text2,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No quizzes found",
                          style: TextStyle(color: AppTheme.text2, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
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
                          child: const Text("Add Quiz"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final Quiz quiz = quizzes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: Text(
                          quiz.title,
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
                                const Icon(Icons.question_answer_outlined, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  quiz.questions.length > 1
                                      ? "${quiz.questions.length} Questions"
                                      : "${quiz.questions.length} Question",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.timer_outlined, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${quiz.timeLimit} mins",
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
                                    leading: Icon(
                                      Icons.edit,
                                      color: AppTheme.primary,
                                    ),
                                    title: Text("Edit"),
                                  ),
                                ),
                                const PopupMenuItem(
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
              title: const Text("Delete Quiz"),
              content: const Text("Are you sure you want to delete this quiz?"),
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
                  child: const Text("Delete", style: TextStyle(color: AppTheme.red)),
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
