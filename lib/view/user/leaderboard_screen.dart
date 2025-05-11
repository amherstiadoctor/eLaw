import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/taken_quiz.dart';
import 'package:sp_code/model/user_entity.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.loggedInUser});
  final UserEntity loggedInUser;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  UserEntity? _currentUser;
  List<Map<String, dynamic>>? userFriends;
  int selectedIndex = 0;
  final List<String> tabs = ['All Time', 'Friends'];
  Stream<List<Map<String, dynamic>>> getLeaderboardData() => FirebaseFirestore
      .instance
      .collection("Users")
      .orderBy('totalPoints', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Future<UserEntity?> fetchCurrentUserFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: widget.loggedInUser.email)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();

    return UserEntity(
      id: snapshot.docs.first.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      quizzesTaken:
          (data['quizzesTaken'] as List?)
              ?.map((quizData) => TakenQuiz.fromMap(quizData))
              .toList(),
      quizzesCompleted:
          (data['quizzesCompleted'] as List?)
              ?.map((e) => e.toString())
              .toList(),
      totalPoints: data['totalPoints'] ?? 0,
      friends:
          (data['friends'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            user['id'] == _currentUser!.id
                                ? AppTheme.green
                                : AppTheme.text,
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
          color:
              user['email'] == _currentUser!.email
                  ? AppTheme.secondary
                  : AppTheme.white,
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
          style: TextStyle(
            fontSize: 28,
            color:
                user['email'] == _currentUser!.email
                    ? AppTheme.secondary
                    : AppTheme.white,
          ),
        ),
        Text(
          user['firstName'],
          style: TextStyle(
            fontSize: 12,
            color:
                user['email'] == _currentUser!.email
                    ? AppTheme.secondary
                    : AppTheme.white,
          ),
        ),
        Text(
          user['lastName'],
          style: TextStyle(
            fontSize: 12,
            color:
                user['email'] == _currentUser!.email
                    ? AppTheme.secondary
                    : AppTheme.white,
          ),
        ),
      ],
    ),
  ).animate().scale(
    delay: const Duration(milliseconds: 200),
    curve: Curves.elasticOut,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCurrentUser();
  }

  void fetchCurrentUser() async {
    final user = await fetchCurrentUserFromFirestore();
    setState(() {
      _currentUser = user;
    });
  }

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

        final List<Map<String, dynamic>> userFriends;
        if (_currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          userFriends =
              users
                  .where((user) => _currentUser!.friends.contains(user['id']))
                  .toList()
                ..add(_currentUser!.toJson())
                ..sort(
                  (a, b) =>
                      (b['totalPoints'] ?? 0).compareTo(a['totalPoints'] ?? 0),
                );
        }

        final topThree = users.take(3).toList();
        final remainingUsers = users.skip(3).toList();

        final topThreeFriends = userFriends.take(3).toList();
        final remainingFriends = userFriends.skip(3).toList();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
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
                  topThree.isNotEmpty
                      ? FlexibleSpaceBar(
                        background: Container(
                          margin: const EdgeInsets.only(top: 90),

                          child: Column(
                            children: [
                              Container(
                                width: 200.responsiveW,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryTint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(tabs.length, (index) {
                                    final isSelected = index == selectedIndex;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? AppTheme.secondaryShade
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          tabs[index],
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? AppTheme.white
                                                    : Colors.brown[300],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              selectedIndex == 0
                                  ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildTopUser(topThree[1], 2, context),
                                      _buildTopUser(topThree[0], 1, context),
                                      _buildTopUser(topThree[2], 3, context),
                                    ],
                                  )
                                  : topThreeFriends.length == 1
                                  ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildTopUser(
                                        topThreeFriends[0],
                                        1,
                                        context,
                                      ),
                                    ],
                                  )
                                  : topThreeFriends.length == 2
                                  ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildTopUser(
                                        topThreeFriends[1],
                                        2,
                                        context,
                                      ),
                                      _buildTopUser(
                                        topThreeFriends[0],
                                        1,
                                        context,
                                      ),
                                    ],
                                  )
                                  : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildTopUser(
                                        topThreeFriends[1],
                                        2,
                                        context,
                                      ),
                                      _buildTopUser(
                                        topThreeFriends[0],
                                        1,
                                        context,
                                      ),
                                      _buildTopUser(
                                        topThreeFriends[2],
                                        3,
                                        context,
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      )
                      : FlexibleSpaceBar(
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Center(
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
            remainingUsers.isNotEmpty
                ? selectedIndex == 1
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
                    : userFriends.isNotEmpty
                    ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: remainingFriends.length,
                          itemBuilder: (context, index) {
                            final remainingFriend = remainingFriends[index];
                            return _buildUserItem(
                              user: remainingFriend,
                              color: AppTheme.primary,
                              index: index,
                            );
                          },
                        ),
                      ),
                    )
                    : const SliverToBoxAdapter()
                : const SliverToBoxAdapter(),
          ],
        );
      },
    ),
  );
}
