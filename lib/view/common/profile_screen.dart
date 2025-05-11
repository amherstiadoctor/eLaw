import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/auth-service/auth.dart';
import 'package:sp_code/auth-service/firebase_auth_service.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/utils/widgets/header.dart';
import 'package:sp_code/view/common/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.loggedInUser});
  final UserEntity loggedInUser;

  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
          ),
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
          const Icon(Icons.chevron_right, color: AppTheme.text2, size: 20),
        ],
      ),
    ),
  );

  handleSignOut() async {
    await widget._authService.onSignOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.grey1,
    body: StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection("Users")
              .where('email', isEqualTo: widget.loggedInUser.email)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final fetchedDocs = snapshot.data!.docs;
        final currentUser = fetchedDocs[0].data() as Map<String, dynamic>;
        if (currentUser.isEmpty) {
          return const Center(child: Text("No user found."));
        }

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
                  children: [Header(title: "Profile", color: AppTheme.white)],
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                      (route) => false,
                                    );
                                  },
                                  color: AppTheme.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 150),
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
