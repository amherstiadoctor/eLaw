import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/view/admin/manage_difficulties_screen.dart';
import 'package:sp_code/view/admin/manage_quizzes_screen.dart';
import 'package:sp_code/view/common/splash_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  AdminHomeScreen({super.key, required this.loggedInUser});
  final UserEntity loggedInUser;

  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final difficultiesCount =
        await _firestore.collection('difficulties').count().get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();

    final latestQuizzes =
        await _firestore
            .collection('quizzes')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();

    final difficulties = await _firestore.collection('difficulties').get();
    final difficultyData = await Future.wait(
      difficulties.docs.map((difficulty) async {
        final quizCount =
            await _firestore
                .collection('quizzes')
                .where('difficultyId', isEqualTo: difficulty.id)
                .count()
                .get();
        return {
          'name': difficulty.data()['name'] as String,
          'count': quizCount.count,
        };
      }),
    );

    return {
      'totalDifficulties': difficultiesCount.count,
      'totalQuizzes': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'difficultyData': difficultyData,
    };
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 25),
          ),

          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: AppTheme.text2),
          ),
        ],
      ),
    ),
  );

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback ontap,
  ) => Card(
    child: InkWell(
      onTap: ontap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 32),
            ),

            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  handleSignOut() async {
    await widget._authService.onSignOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Admin Dashboard',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 0,
    ),
    body: FutureBuilder(
      future: _fetchStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }

        final Map<String, dynamic> stats = snapshot.data!;
        final List<dynamic> difficultyData = stats['difficultyData'];
        final List<QueryDocumentSnapshot> latestQuizzes =
            stats['latestQuizzes'];

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good ${greeting()}, ${widget.loggedInUser.firstName}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Here's your quiz application overview",
                  style: TextStyle(fontSize: 16, color: AppTheme.text2),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Difficulties',
                          stats['totalDifficulties'] == null
                              ? "0"
                              : stats['totalDifficulties'].toString(),
                          Icons.category_rounded,
                          AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildStatCard(
                          'Total Quizzes',
                          stats['totalQuizzes'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.pie_chart_rounded,
                              color: AppTheme.primary,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Difficulty Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: difficultyData.length,
                          itemBuilder: (context, index) {
                            final difficulty = difficultyData[index];
                            final totalQuizzes = difficultyData.fold<int>(
                              0,
                              (thisSum, item) =>
                                  thisSum + (item['count'] as int),
                            );

                            final percentage =
                                totalQuizzes > 0
                                    ? (difficulty['count'] as int) /
                                        totalQuizzes *
                                        100
                                    : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          difficulty['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.text,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "${difficulty['count']} ${(difficulty['count'] as int) == 1 ? 'quiz' : 'quizzes'}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.text2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: AppTheme.primary,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: latestQuizzes.length,
                          itemBuilder: (context, index) {
                            final quiz =
                                latestQuizzes[index].data()
                                    as Map<String, dynamic>;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.quiz_rounded,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quiz["title"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.text,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      quiz["updatedAt"] != null
                                          ? Text(
                                            "Updated on ${_formatDate(quiz["updatedAt"].toDate())}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.text2,
                                            ),
                                          )
                                          : Text(
                                            "Created on ${_formatDate(quiz["createdAt"].toDate())}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.text2,
                                            ),
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.speed_rounded,
                              color: AppTheme.primary,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Admin Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 12,
                          children: [
                            _buildDashboardCard(
                              context,
                              'Quizzes',
                              Icons.quiz_rounded,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ManageQuizzesScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDashboardCard(
                              context,
                              'Difficulties',
                              Icons.category_rounded,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ManageDifficultiesScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: InkWell(
                      onTap: () {
                        handleSignOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => SplashScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: AppTheme.red,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.red,
                                    ),
                                  ),
                                  Text(
                                    "Sign out of your account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.text2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppTheme.text2,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
