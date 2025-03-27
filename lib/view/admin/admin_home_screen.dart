import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/theme/theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount =
        await _firestore.collection('categories').count().get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();

    final latestQuizzes =
        await _firestore
            .collection('quizzes')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();

    final categories = await _firestore.collection('categories').get();
    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quizCount =
            await _firestore
                .collection('quizzes')
                .where('categoryId', isEqualTo: category.id)
                .count()
                .get();
        return {
          'name': category.data()['name'] as String,
          'quizzes': quizCount.count,
        };
      }),
    );

    return {
      'totalCategories': categoriesCount.count,
      'totalQuizzes': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'categoryData': categoryData,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 25),
            ),

            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: AppTheme.text2)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback ontap,
  ) {
    return Card(
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(29),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 32),
              ),

              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 1168,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred'));
          }

          final Map<String, dynamic> stats = snapshot.data!;
          final List<dynamic> categoryData = stats['categoryData'];
          final List<QueryDocumentSnapshot> latestQuizzes =
              stats['latestQuizzes'];

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Here's your quiz application overview",
                    style: TextStyle(fontSize: 16, color: AppTheme.text2),
                  ),
                  SizedBox(height: 24),
                  SizedBox(height: 200, child:Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Categories',
                          stats['totalCategories'].toString(),
                          Icons.category_rounded,
                          AppTheme.primary,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: _buildStatCard(
                          'Total Quizzes',
                          stats['totalQuizzes'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.primary,
                        ),
                      ),
                    ],
                  ),),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
