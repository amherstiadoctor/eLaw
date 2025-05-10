import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/view/common/splash_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserEntity loggedInUser;
  UserProfileScreen({super.key, required this.loggedInUser});

  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
              )
              .animate(delay: Duration(milliseconds: 100))
              .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
              .fadeIn(),
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
        ),
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
            )
            .animate(delay: Duration(milliseconds: 100))
            .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
            .fadeIn(),
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
            Icon(Icons.chevron_right, color: AppTheme.text2, size: 20),
          ],
        ),
      ),
    );
  }

  handleSignOut() async {
    await widget._authService.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey1,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection("Users")
                .where('email', isEqualTo: widget.loggedInUser.email)
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final fetchedDocs = snapshot.data!.docs;
          final currentUser = fetchedDocs[0].data() as Map<String, dynamic>;
          if (currentUser.isEmpty) {
            return Center(child: Text("No user found."));
          }

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
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: AppTheme.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.more_vert,
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
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
                        ),
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildSection(
                                title: '',
                                items: [
                                  _buildMenuItem(
                                    icon: Icons.logout_outlined,
                                    title: 'Sign Out',
                                    subtitle: 'Sign out from your account',
                                    onTap: () {
                                      handleSignOut();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => SplashScreen(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    color: AppTheme.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 150),
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
