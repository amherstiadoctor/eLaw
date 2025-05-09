import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sp_code/config/responsive_sizer/responsive_sizer.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/widgets/header.dart';
import 'package:sp_code/utils/widgets/study_tabs.dart';

class StudyScreen extends StatefulWidget {
  final UserEntity loggedInUser;
  const StudyScreen({super.key, required this.loggedInUser});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection("Users")
                .where('email', isEqualTo: widget.loggedInUser.email)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final fetchedDocs = snapshot.data!.docs;
          final currentUser = fetchedDocs[0].data() as Map<String, dynamic>;
          if (currentUser.isEmpty) {
            return Center(child: Text("No user found."));
          }

          return Stack(
            children: [
              Header(
                title: "Study",
                hasBackButton: false,
                color: AppTheme.white,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
                child: Container(
                  height: 650.responsiveH,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: StudyTabs(currentUser: currentUser),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
