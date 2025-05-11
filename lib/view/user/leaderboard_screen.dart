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
  Stream<List<Map<String, dynamic>>> getLeaderboardData() => FirebaseFirestore
      .instance
      .collection("Users")
      .orderBy('totalPoints', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Widget _buildUserItem({
    required Map<String, dynamic> user,
    required Color color,
    required int index,
  }) =>
      Container(
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Text(
                    (index + 4).toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.text2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${user['firstName']} ${user['lastName']}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.text,
                      ),
                    ),
                  ),
                  Text(
                    user['totalPoints'].toString(),
                    style: const TextStyle(
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
          .slideY(
            begin: 0.5,
            end: 0,
            duration: const Duration(milliseconds: 300),
          )
          .fadeIn();

  Widget _buildTopUser(
    Map<String, dynamic> user,
    int rank,
    BuildContext context,
  ) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
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
        const SizedBox(height: 5),
        Text(
          user['totalPoints'].toString(),
          style: const TextStyle(fontSize: 28, color: AppTheme.white),
        ),
        Text(
          // "${user['firstName']} ${user['lastName']}",
          user['firstName'],
          style: const TextStyle(fontSize: 12, color: AppTheme.white),
        ),
        Text(
          // "${user['firstName']} ${user['lastName']}",
          user['lastName'],
          style: const TextStyle(fontSize: 12, color: AppTheme.white),
        ),
      ],
    ),
  ).animate().scale(
    delay: const Duration(milliseconds: 200),
    curve: Curves.elasticOut,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.grey1,
    body: StreamBuilder(
      stream: getLeaderboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data;
        if (users!.isEmpty) {
          return const Center(child: Text("No users found."));
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              title: const Text(
                "Leaderboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              flexibleSpace:
                  users.isNotEmpty && topThree.length > 3
                      ? FlexibleSpaceBar(
                        background: Container(
                          margin: const EdgeInsets.only(top: 90),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTopUser(topThree[1], 2, context),
                              _buildTopUser(topThree[0], 1, context),
                              _buildTopUser(topThree[2], 3, context),
                            ],
                          ),
                        ),
                      )
                      : FlexibleSpaceBar(
                        background: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: Text(
                              "No Rankings Yet!\nGo Rack Up Your Points!",
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
            ),
            users.isNotEmpty && remainingUsers.isNotEmpty
                ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                )
                : const SliverToBoxAdapter(),
          ],
        );
      },
    ),
  );
}
