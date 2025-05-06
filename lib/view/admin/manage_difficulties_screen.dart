import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/view/admin/add_difficulty_screen.dart';
import 'package:sp_code/view/admin/manage_quizzes_screen.dart';

class ManageDifficultiesScreen extends StatefulWidget {
  const ManageDifficultiesScreen({super.key});

  @override
  State<ManageDifficultiesScreen> createState() =>
      _ManageDifficultiesScreenState();
}

class _ManageDifficultiesScreenState extends State<ManageDifficultiesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: Text(
          'Manage Difficulties',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddDifficultyScreen()),
              );
            },
            icon: Icon(Icons.add_circle_outline),
            color: AppTheme.primary,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection("difficulties").orderBy('name').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No difficulties found"));
          }

          final difficulties =
              snapshot.data!.docs
                  .map(
                    (doc) => Difficulty.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList();

          if (difficulties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AppTheme.text2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No difficulties found",
                    style: TextStyle(color: AppTheme.text2, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDifficultyScreen(),
                        ),
                      );
                    },
                    child: Text("Add Difficulty"),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: difficulties.length,
            itemBuilder: (BuildContext context, int index) {
              final Difficulty difficulty = difficulties[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    difficulty.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(difficulty.description),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: "edit",
                            child: ListTile(
                              leading: Icon(
                                Icons.edit,
                                color: AppTheme.primary,
                              ),
                              title: Text("Edit"),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: "delete",
                            child: ListTile(
                              leading: Icon(Icons.edit, color: AppTheme.red),
                              title: Text("Delete"),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      _handleDifficultyAction(context, value, difficulty);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ManageQuizzesScreen(
                              difficultyId: difficulty.id,
                              difficultyName: difficulty.name,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleDifficultyAction(
    BuildContext context,
    String action,
    Difficulty difficulty,
  ) async {
    if (action == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddDifficultyScreen(difficulty: difficulty),
        ),
      );
    } else if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Delete Difficulty"),
              content: Text("Are you sure you want to delete this difficulty?"),
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
        await _firestore.collection("difficulties").doc(difficulty.id).delete();
      }
    }
  }
}
