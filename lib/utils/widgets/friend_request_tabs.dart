// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/friend_request.dart';
import 'package:sp_code/utils/get_message.dart';
import 'package:sp_code/utils/widgets/circle_tab_indicator.dart';
import 'package:sp_code/view/common/user_profile_screen.dart';

class FriendRequestTabs extends StatefulWidget {
  const FriendRequestTabs({super.key, required this.currentUser});
  final Map<String, dynamic> currentUser;

  @override
  State<FriendRequestTabs> createState() => _FriendRequestTabsState();
}

class _FriendRequestTabsState extends State<FriendRequestTabs>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  TabController? _tabController;
  int _selectedIndex = 0;

  Stream<List<Map<String, dynamic>>> getSentFriendRequestsData() => FirebaseFirestore.instance
        .collection('friendRequests')
        .where('senderId', isEqualTo: widget.currentUser['id'])
        .where('status', isEqualTo: "pending")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Stream<List<Map<String, dynamic>>> getReceivedFriendRequestsData() => FirebaseFirestore.instance
        .collection('friendRequests')
        .where('receiverId', isEqualTo: widget.currentUser['id'])
        .where('status', isEqualTo: "pending")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Future<void> _handleRequestAction(
    String action,
    Map<String, dynamic> friendRequest,
    BuildContext context,
    DocumentSnapshot foundUser,
  ) async {
    if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Cancel Friend Request"),
              content: const Text(
                "Are you sure you want to cancel this friend request?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Yes", style: TextStyle(color: AppTheme.red)),
                ),
              ],
            ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection("friendRequests")
            .doc(friendRequest['id'])
            .delete();

        GetMessage.getToastMessage("Friend request deleted");
      }
    } else if (action == "accept") {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Accept Friend Request"),
              content: const Text(
                "Are you sure you want to accept this friend request?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Yes", style: TextStyle(color: AppTheme.red)),
                ),
              ],
            ),
      );

      final FriendRequest updateRequest = FriendRequest(
        id: friendRequest['id'],
        receiverId: friendRequest['receiverId'],
        senderId: friendRequest['senderId'],
        status: "accepted",
        createdAt: friendRequest['createdAt'].toDate(),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection("friendRequests")
            .doc(updateRequest.id)
            .update(updateRequest.toMap(isUpdate: true));

        final currentUserFriends = widget.currentUser['friends'];
        currentUserFriends.add(updateRequest.senderId);

        final foundUserFriends = foundUser['friends'];
        foundUserFriends.add(updateRequest.receiverId);

        await FirebaseFirestore.instance
            .collection("Users")
            .doc(updateRequest.receiverId)
            .update({'friends': currentUserFriends});
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(updateRequest.senderId)
            .update({'friends': foundUserFriends});

        GetMessage.getGoodToastMessage("Friend request accepted");
      }
    }
  }

  _buildRequestItem({
    required int index,
    required Map<String, dynamic> friendRequest,
    required bool isReceived,
  }) => StreamBuilder(
      stream:
          isReceived
              ? FirebaseFirestore.instance
                  .collection("Users")
                  .doc(friendRequest['senderId'])
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection("Users")
                  .doc(friendRequest['receiverId'])
                  .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final foundUser = snapshot.data as DocumentSnapshot;

        return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    "${foundUser['firstName']} ${foundUser['lastName']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            friendRequest['status'] == "pending"
                                ? "Friend request pending"
                                : "",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          isReceived
                              ? const PopupMenuItem(
                                value: "accept",
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.check_circle_outline,
                                    color: AppTheme.green,
                                  ),
                                  title: Text("Accept"),
                                ),
                              )
                              : PopupMenuItem(child: Container()),
                          PopupMenuItem(
                            value: "delete",
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.delete, color: AppTheme.red),
                              title:
                                  isReceived ? const Text("Reject") : const Text("Cancel"),
                            ),
                          ),
                        ],
                    onSelected:
                        (value) => _handleRequestAction(
                          value,
                          friendRequest,
                          context,
                          foundUser,
                        ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => UserProfileScreen(
                              friendId:
                                  isReceived
                                      ? friendRequest['senderId']
                                      : friendRequest['receiverId'],
                              currentUser: widget.currentUser,
                              isReceived: isReceived,
                            ),
                      ),
                    );
                  },
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: 100 * index))
            .slideY(begin: 0.5, end: 0, duration: const Duration(milliseconds: 300))
            .fadeIn();
      },
    );

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _tabController!.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Column(
      children: [
        TabBar(
          controller: _tabController,
          indicator: CircleTabIndicator(color: AppTheme.primary, radius: 3),
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.grey3,
          unselectedLabelStyle: const TextStyle(color: AppTheme.grey2),
          tabs: const [Tab(text: "Received"), Tab(text: "Sent")],
          dividerHeight: 0,
        ),
        const SizedBox(height: 10),
        Container(
          height: 600,
          decoration: const BoxDecoration(color: AppTheme.grey1),
          child: TabBarView(
            controller: _tabController,
            children: [
              isLoading
                  ? const Center(
                    child: SizedBox(
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : StreamBuilder(
                    stream: getReceivedFriendRequestsData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final requests = snapshot.data;
                      if (requests!.isEmpty) {
                        return const Center(child: Text("No requests found"));
                      }
                      return Column(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                                left: 16,
                                top: 16,
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final friendRequest = requests[index];
                                  return _buildRequestItem(
                                    friendRequest: friendRequest,
                                    index: index,
                                    isReceived: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              isLoading
                  ? const Center(
                    child: SizedBox(
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : StreamBuilder(
                    stream: getSentFriendRequestsData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final requests = snapshot.data;
                      if (requests!.isEmpty) {
                        return const Center(child: Text("No requests found"));
                      }
                      return Column(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                                left: 16,
                                top: 16,
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final friendRequest = requests[index];
                                  return _buildRequestItem(
                                    friendRequest: friendRequest,
                                    index: index,
                                    isReceived: false,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ],
          ),
        ),
      ],
    );
}
