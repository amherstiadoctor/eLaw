import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/svg_images.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/widgets/header.dart';
import 'package:sp_code/view/common/friend_requests_screen.dart';
import 'package:sp_code/view/common/user_profile_screen.dart';

class FriendslistScreen extends StatefulWidget {
  const FriendslistScreen({super.key, required this.loggedInUser});
  final UserEntity loggedInUser;

  @override
  State<FriendslistScreen> createState() => _FriendslistScreenState();
}

class _FriendslistScreenState extends State<FriendslistScreen> {
  final TextEditingController _searchController = TextEditingController();
  var searchUser = "";
  Map<String, dynamic> useThis = {};
  Map<String, dynamic> useThat = {};

  Future<void> fetchCurrentUserFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: widget.loggedInUser.email)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return;

    final data = snapshot.docs.first.data();
    setState(() {
      useThat = data;
    });
  }

  _buildFriendItem({
    required String friendId,
    required int index,
    required Map<String, dynamic> currentUser,
  }) => StreamBuilder<DocumentSnapshot>(
    stream:
        FirebaseFirestore.instance
            .collection("Users")
            .doc(friendId)
            .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Text("User Not Found");
      }

      final friend = snapshot.data as DocumentSnapshot;

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
                  "${friend['firstName']} ${friend['lastName']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Points: ${friend['totalPoints'].toString()}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UserProfileScreen(
                            friendId: friendId,
                            currentUser: currentUser,
                          ),
                    ),
                  );
                },
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
    },
  );

  _buildSearchItem({
    required String friendId,
    required int index,
    required Map<String, dynamic> currentUser,
  }) => StreamBuilder<DocumentSnapshot>(
    stream:
        FirebaseFirestore.instance
            .collection("Users")
            .doc(friendId)
            .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Container();
      }

      final friend = snapshot.data as DocumentSnapshot;

      return currentUser['id'] == friendId
          ? const Center(child: CircularProgressIndicator())
          : Card(
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
                      "${friend['firstName']} ${friend['lastName']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              friend['email'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UserProfileScreen(
                                friendId: friendId,
                                currentUser: currentUser,
                              ),
                        ),
                      );
                    },
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
    },
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCurrentUserFromFirestore();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.primary,
    body: Stack(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('friendRequests')
              .where('receiverId', isEqualTo: useThis['id'])
              .where('status', isEqualTo: "pending")
              .snapshots()
              .map(
                (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final requests = snapshot.data;
            if (requests!.isEmpty) {
              return Header(
                title: "Friends List",
                color: AppTheme.white,
                has3rdIcon: true,
                onButtonPress: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              FriendRequestsScreen(currentUser: useThis),
                    ),
                  );
                },
              );
            }
            return Header(
              title: "Friends List",
              color: AppTheme.white,
              has3rdIcon: true,
              hasRequests: true,
              onButtonPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => FriendRequestsScreen(currentUser: useThis),
                  ),
                );
              },
            );
          },
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 110.responsiveW, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 60,
            decoration: const BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.string(
                  searchIcon,
                  height: 30,
                  width: 30,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  width: 250.responsiveW,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      fillColor: AppTheme.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primary),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryShade),
                      ),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.red),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.red),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: "Enter email to search",
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        height: 20 / 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.grey3,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear, size: 28),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchUser = "";
                                  }); // Update UI
                                },
                              )
                              : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchUser = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 190.responsiveW),
          child: Container(
            height: 750.responsiveW,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.grey1,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("Users")
                      .where('email', isEqualTo: widget.loggedInUser.email)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final fetchedDocs = snapshot.data!.docs;
                final currentUser =
                    fetchedDocs[0].data() as Map<String, dynamic>;
                useThis = currentUser;
                final friendsList = currentUser['friends'];
                if (friendsList.isEmpty && searchUser == "") {
                  return const Center(child: Text("No friends yet!"));
                }

                return searchUser == ""
                    ? Container(
                      padding: const EdgeInsets.only(
                        right: 20,
                        left: 20,
                        top: 20,
                      ),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: friendsList.length,
                          itemBuilder:
                              (context, index) => _buildFriendItem(
                                friendId: friendsList[index],
                                index: index,
                                currentUser: currentUser,
                              ),
                        ),
                      ),
                    )
                    : Container(
                      padding: const EdgeInsets.only(
                        right: 20,
                        left: 20,
                        top: 20,
                      ),
                      child: SingleChildScrollView(
                        child: StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .orderBy('email')
                                  .startAt([searchUser])
                                  .endAt(["$searchUser\uf8ff"])
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text("Something went wrong"),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text("No User found with that email"),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final listItem = snapshot.data!.docs[index];
                                return _buildSearchItem(
                                  friendId: listItem['id'],
                                  index: index,
                                  currentUser: currentUser,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
