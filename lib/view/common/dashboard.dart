import 'package:flutter/material.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/view/admin/admin_home_screen.dart';
import 'package:sp_code/view/common/user_profile_screen.dart';
import 'package:sp_code/view/user/home_screen.dart';
import 'package:sp_code/view/user/leaderboard_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.loggedInUser});

  final UserEntity loggedInUser;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String _role = "";
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _role = widget.loggedInUser.role;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      const LeaderboardScreen(),
      _role == "user"
          ? HomeScreen(loggedInUser: widget.loggedInUser)
          : AdminHomeScreen(loggedInUser: widget.loggedInUser),
      UserProfileScreen(loggedInUser: widget.loggedInUser),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          _onItemTapped(1);
        },
        child: Icon(Icons.home_rounded, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 85,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                _onItemTapped(0);
              },
              icon: Icon(
                Icons.leaderboard_rounded,
                color: _selectedIndex == 0 ? AppTheme.primary : AppTheme.black,
              ),
            ),
            IconButton(
              onPressed: () {
                _onItemTapped(2);
              },
              icon: Icon(
                Icons.account_circle_rounded,
                color: _selectedIndex == 2 ? AppTheme.primary : AppTheme.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
