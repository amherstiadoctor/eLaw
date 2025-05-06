import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/model/difficulty.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/view/common/splash_screen.dart';
import 'package:sp_code/view/user/difficulty_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserEntity loggedInUser;
  HomeScreen({super.key, required this.loggedInUser});

  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Difficulty> _allDifficulties = [];
  List<Difficulty> _filteredDifficulties = [];

  handleSignOut() async {
    await widget._authService.onSignOut();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchDifficulties();
  }

  Future<void> _fetchDifficulties() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('difficulties')
            .orderBy('createdAt', descending: true)
            .get();

    setState(() {
      _allDifficulties =
          snapshot.docs
              .map((doc) => Difficulty.fromMap(doc.id, doc.data()))
              .toList();

      _filteredDifficulties = _allDifficulties;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 225,
            pinned: true,
            floating: true,
            centerTitle: false,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            leading: Positioned(
              right: 0,
              child: ElevatedButton(
                onPressed: () {
                  handleSignOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Sign Out'),
              ),
            ),
            title: Text(
              "eLaw",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: kToolbarHeight + 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, Learner!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          SizedBox(height: 8),
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
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver:
                _filteredDifficulties.isEmpty
                    ? SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "No difficulties found",
                          style: TextStyle(color: AppTheme.text2),
                        ),
                      ),
                    )
                    : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        childCount: 3,
                        (context, index) => _buildDifficultyCard(
                          _filteredDifficulties[index],
                          index,
                        ),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(Difficulty difficulty, int index) {
    return Card(
          elevation: 0,
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
                      (context) => DifficultyScreen(difficulty: difficulty),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.quiz, size: 48, color: AppTheme.primary),
                  ),
                  SizedBox(height: 10),
                  Text(
                    difficulty.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    difficulty.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
