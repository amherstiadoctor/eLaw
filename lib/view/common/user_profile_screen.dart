import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/friend_request.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/utils/widgets/header.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    required this.friendId,
    required this.currentUser,
    this.isReceived = false,
  });
  final String friendId;
  final Map<String, dynamic> currentUser;
  final bool isReceived;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool requestSent = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getFriendRequestData() => _firestore
      .collection('friendRequests')
      .where('senderId', isEqualTo: widget.currentUser['id'])
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) => Expanded(
    child:
        Container(
          height: 125,
          padding: const EdgeInsets.all(12),
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
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppTheme.text2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate(delay: const Duration(milliseconds: 100)).fadeIn(),
  );

  Widget _buildSection({required String title, required List<Widget> items}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
          ).animate(delay: const Duration(milliseconds: 100)).fadeIn(),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(children: items),
          ).animate(delay: const Duration(milliseconds: 100)).fadeIn(),
        ],
      );

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color:
                  isDestructive
                      ? AppTheme.red.withOpacity(0.1)
                      : color.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: isDestructive ? AppTheme.red : color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? AppTheme.red : AppTheme.text,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.text2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _removeFriend({
    required Map<String, dynamic> currentUser,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Friend"),
            content: const Text("Are you sure you want to delete this friend?"),
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
                  "Delete",
                  style: TextStyle(color: AppTheme.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      currentUser['friends'].remove(widget.friendId);
      await _firestore.collection("Users").doc(currentUser['id']).update({
        'friends': currentUser['friends'],
      });

      if (!mounted) return;

      Navigator.of(context).pop();
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      final newDocRef =
          FirebaseFirestore.instance.collection('friendRequests').doc();
      await newDocRef.set(
        FriendRequest(
          id: newDocRef.id,
          receiverId: widget.friendId,
          senderId: widget.currentUser['id'],
          status: "pending",
          createdAt: DateTime.now(),
        ).toMap(),
      );
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        requestSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.grey1,
    body: StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection("Users").doc(widget.friendId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No user found."));
        }

        final currentUser = snapshot.data as DocumentSnapshot;

        return SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryTint],
                    end: Alignment.bottomRight,
                    begin: Alignment.topLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: const Stack(
                  children: [
                    Header(
                      title: "User Profile",
                      color: AppTheme.white,
                      hasBackButton: true,
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              color: AppTheme.primary,
                              size: 100,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${currentUser["firstName"]} ${currentUser["lastName"]}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentUser["email"],
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.text2,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: const Duration(milliseconds: 100)).fadeIn(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            _buildActionCard(
                              icon: Icons.quiz_outlined,
                              title: 'Completed Quizzes',
                              value:
                                  currentUser["quizzesCompleted"].length
                                      .toString(),
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 12),
                            _buildActionCard(
                              icon: Icons.favorite_outline_outlined,
                              title: 'Points',
                              value: currentUser["totalPoints"].toString(),
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            _buildActionCard(
                              icon: Icons.group_outlined,
                              title: 'Friends',
                              value: currentUser["friends"].length.toString(),
                              color: AppTheme.tertiary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            StreamBuilder(
                              stream: getFriendRequestData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final requests = snapshot.data;
                                if (requests!.isEmpty) {
                                  GetMessage.getErrorMessage(
                                    "No requests found",
                                  );
                                }
                                var alreadySent = false;
                                for (Map<String, dynamic> item in requests) {
                                  if (item['receiverId'] == widget.friendId) {
                                    alreadySent = true;
                                  }
                                }

                                return widget.isReceived
                                    ? _buildSection(
                                      title: "Information",
                                      items: [
                                        _buildMenuItem(
                                          icon: Icons.hourglass_empty_outlined,
                                          title:
                                              'This user sent you a friend request!',
                                          subtitle: 'Waiting for your response',
                                          onTap: () {},
                                          color: AppTheme.secondary,
                                        ),
                                      ],
                                    )
                                    : _buildSection(
                                      title: 'Actions',
                                      items: [
                                        currentUser['friends'].contains(
                                                  widget.friendId,
                                                ) ||
                                                alreadySent
                                            ? Container()
                                            : _buildMenuItem(
                                              icon: Icons.add_reaction_outlined,
                                              title: 'Add Friend',
                                              subtitle: 'Send a friend request',
                                              onTap: () {
                                                _sendFriendRequest();
                                              },
                                              color: AppTheme.primary,
                                            ),
                                        currentUser['friends'].contains(
                                              widget.friendId,
                                            )
                                            ? _buildMenuItem(
                                              icon:
                                                  Icons
                                                      .sentiment_dissatisfied_outlined,
                                              title: 'Delete Friend',
                                              subtitle:
                                                  'Remove friend from friends list',
                                              onTap: () {
                                                _removeFriend(
                                                  currentUser:
                                                      widget.currentUser,
                                                );
                                              },
                                              color: AppTheme.red,
                                            )
                                            : Container(),
                                        alreadySent
                                            ? _buildMenuItem(
                                              icon:
                                                  Icons
                                                      .check_circle_outline_outlined,
                                              title: 'Friend Request Sent!',
                                              subtitle:
                                                  'Waiting for their response',
                                              onTap: () {},
                                              color: AppTheme.secondary,
                                            )
                                            : Container(),
                                      ],
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
