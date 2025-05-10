import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/config/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Stream<List<Map<String, dynamic>>> getLeaderboardData() {
    return FirebaseFirestore.instance
        .collection("Users")
        .orderBy('totalPoints', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Widget _buildUserItem({
    required Map<String, dynamic> user,
    required Color color,
    required int index,
  }) {
    return Container(
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Text(
                  (index + 4).toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.text2,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: color.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.account_circle_outlined,
                    color: color,
                    size: 16,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "${user['firstName']} ${user['lastName']}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                Text(
                  user['totalPoints'].toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.text2,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }

  Widget _buildTopUser(
    Map<String, dynamic> user,
    int rank,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(
            rank == 1
                ? Icons.celebration_outlined
                : rank == 2
                ? Icons.looks_two_outlined
                : Icons.looks_3_outlined,
            color: rank == 1 ? AppTheme.secondary : AppTheme.white,
            size: rank == 1 ? 50 : 30,
          ),
          Icon(
            Icons.account_circle_outlined,
            color: AppTheme.white,
            size:
                rank == 1
                    ? 100
                    : rank == 2
                    ? 80
                    : 60,
          ),
          SizedBox(height: 5),
          Text(
            user['totalPoints'].toString(),
            style: TextStyle(fontSize: 28, color: AppTheme.white),
          ),
          Text(
            // "${user['firstName']} ${user['lastName']}",
            user['firstName'],
            style: TextStyle(fontSize: 12, color: AppTheme.white),
          ),
          Text(
            // "${user['firstName']} ${user['lastName']}",
            user['lastName'],
            style: TextStyle(fontSize: 12, color: AppTheme.white),
          ),
        ],
      ),
    ).animate().scale(
      delay: Duration(milliseconds: 200),
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey1,
      body: StreamBuilder(
        stream: getLeaderboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data;
          if (users!.isEmpty) {
            return Center(child: Text("No users found."));
          }

          final topThree = users.take(3).toList();
          final remainingUsers = users.skip(3).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                floating: true,
                centerTitle: true,
                backgroundColor: AppTheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                title: Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    margin: EdgeInsets.only(top: 90),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTopUser(topThree[1], 2, context),
                        _buildTopUser(topThree[0], 1, context),
                        _buildTopUser(topThree[2], 3, context),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: remainingUsers.length,
                    itemBuilder: (context, index) {
                      final remainingUser = remainingUsers[index];
                      return _buildUserItem(
                        user: remainingUser,
                        color: AppTheme.primary,
                        index: index,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
