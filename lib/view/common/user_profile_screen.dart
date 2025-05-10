import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/friend_request.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/utils/widgets/header.dart';

class UserProfileScreen extends StatefulWidget {
  final String friendId;
  final Map<String, dynamic> currentUser;
  const UserProfileScreen({
    super.key,
    required this.friendId,
    required this.currentUser,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool requestSent = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getFriendRequestData() {
    return FirebaseFirestore.instance
        .collection('friendRequests')
        .where('senderId', isEqualTo: widget.currentUser['id'])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child:
          Container(
            height: 125,
            padding: EdgeInsets.all(12),
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
            child: Column(
              children: [
                Icon(icon, color: color),
                SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: AppTheme.text2),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 100)).fadeIn(),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
        ).animate(delay: Duration(milliseconds: 100)).fadeIn(),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: items),
        ).animate(delay: Duration(milliseconds: 100)).fadeIn(),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
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
            SizedBox(width: 16),
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
                    style: TextStyle(
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
  }

  Future<void> _removeFriend({
    required Map<String, dynamic> currentUser,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete Friend"),
            content: Text("Are you sure you want to delete this friend?"),
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
      currentUser['friends'].remove(widget.friendId);
      await _firestore.collection("Users").doc(currentUser['id']).update({
        'friends': currentUser['friends'],
      });

      Navigator.pop(context);
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc()
          .set(
            FriendRequest(
              id: _firestore.collection("friendRequest").doc().id,
              receiverId: widget.friendId,
              senderId: widget.currentUser['id'],
              status: "pending",
              createdAt: DateTime.now(),
            ).toMap(),
          );
    } catch (e) {
    } finally {
      setState(() {
        requestSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey1,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("Users").doc(widget.friendId).snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No user found."));
          }

          final currentUser = snapshot.data as DocumentSnapshot;

          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
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
                  child: Stack(
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
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_circle_outlined,
                                color: AppTheme.primary,
                                size: 100,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "${currentUser["firstName"]} ${currentUser["lastName"]}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.text,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                currentUser["email"],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.text2,
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: Duration(milliseconds: 100)).fadeIn(),
                        SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
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
                              SizedBox(width: 12),
                              _buildActionCard(
                                icon: Icons.favorite_outline_outlined,
                                title: 'Points',
                                value: currentUser["totalPoints"].toString(),
                                color: AppTheme.secondary,
                              ),
                              SizedBox(width: 12),
                              _buildActionCard(
                                icon: Icons.group_outlined,
                                title: 'Friends',
                                value: currentUser["friends"].length.toString(),
                                color: AppTheme.tertiary,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              StreamBuilder(
                                stream: getFriendRequestData(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
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

                                  return _buildSection(
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
                                                currentUser: widget.currentUser,
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
}
