import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/config/theme.dart';

class AddDifficultyScreen extends StatefulWidget {
  const AddDifficultyScreen({super.key, this.difficulty});
  final Difficulty? difficulty;

  @override
  State<AddDifficultyScreen> createState() => _AddDifficultyScreenState();
}

class _AddDifficultyScreenState extends State<AddDifficultyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController(text: widget.difficulty?.name);
    _descriptionController = TextEditingController(
      text: widget.difficulty?.description,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDifficulty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.difficulty != null) {
        final updatedDifficulty = widget.difficulty!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        await _firestore
            .collection("difficulties")
            .doc(widget.difficulty!.id)
            .update(updatedDifficulty.toMap());

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Difficulty updated successfully")),
        );
      } else {
        final docDifficulties = FirebaseFirestore.instance
            .collection('difficulties')
            .doc(_nameController.text.trim());

        await docDifficulties.set(
          Difficulty(
            id: _firestore.collection("difficulties").doc().id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            createdAt: DateTime.now(),
          ).toMap(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Difficulty added successfully")),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      final confirm =
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Discard Changes"),
                  content: const Text(
                    "Are you sure you want to discard changes?",
                  ),
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
                      child: const Text(
                        "Discard",
                        style: TextStyle(color: AppTheme.red),
                      ),
                    ),
                  ],
                ),
          ) ??
          false;
      return confirm;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: _onWillPop,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: Text(
          widget.difficulty != null ? "Edit Difficulty" : "Add Difficulty",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Difficulty Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create a new difficulty for organizing your quizzes",
                  style: TextStyle(fontSize: 14, color: AppTheme.text2),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 0.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: "Difficulty Name",
                    hintText: "Enter difficulty name",
                    prefixIcon: const Icon(
                      Icons.category_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Enter difficulty name" : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 0.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: "Description",
                    hintText: "Enter description",
                    prefixIcon: const Icon(
                      Icons.description_rounded,
                      color: AppTheme.primary,
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator:
                      (value) => value!.isEmpty ? "Enter description" : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveDifficulty,
                    child:
                        _isLoading
                            ? const SizedBox(
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
                              widget.difficulty != null
                                  ? "Update Difficulty"
                                  : "Add Difficulty",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
