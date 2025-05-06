import 'package:flutter/material.dart';
import 'package:sp_code/model/user_entity.dart';

class UserProfileScreen extends StatefulWidget {
  final UserEntity loggedInUser;
  const UserProfileScreen({super.key, required this.loggedInUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
