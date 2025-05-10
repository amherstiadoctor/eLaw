import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/utils/widgets/friend_request_tabs.dart';
import 'package:sp_code/utils/widgets/header.dart';

class FriendRequestsScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const FriendRequestsScreen({super.key, required this.currentUser});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  Stream<List<Map<String, dynamic>>> getFriendRequestsData() {
    return FirebaseFirestore.instance
        .collection('friendRequests')
        .where('senderId', isEqualTo: widget.currentUser['id'])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          Header(
            title: "Friend Requests",
            hasBackButton: true,
            color: AppTheme.white,
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
              child: Container(
                height: 750.responsiveH,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.grey1,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: FriendRequestTabs(currentUser: widget.currentUser),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
