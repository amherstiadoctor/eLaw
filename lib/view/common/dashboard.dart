import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sp_code/config/svg_images.dart';
import 'package:sp_code/model/user_entity.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/view/admin/admin_home_screen.dart';
import 'package:sp_code/view/common/friendslist_screen.dart';
import 'package:sp_code/view/common/study_screen.dart';
import 'package:sp_code/view/common/profile_screen.dart';
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
  int _selectedIndex = 2;

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
    final List<Widget> widgetOptions = <Widget>[
      StudyScreen(loggedInUser: widget.loggedInUser),
      LeaderboardScreen(loggedInUser: widget.loggedInUser),
      _role == "user"
          ? HomeScreen(loggedInUser: widget.loggedInUser)
          : AdminHomeScreen(loggedInUser: widget.loggedInUser),
      FriendslistScreen(loggedInUser: widget.loggedInUser),
      ProfileScreen(loggedInUser: widget.loggedInUser),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: AppTheme.primary,
        onPressed: () {
          _onItemTapped(2);
        },
        child: SvgPicture.string(
          homeIcon,
          colorFilter:
              _selectedIndex == 2
                  ? const ColorFilter.mode(AppTheme.white, BlendMode.srcIn)
                  : const ColorFilter.mode(AppTheme.black, BlendMode.srcIn),
          height: 30,
          width: 30,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.white,
        height: 70,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                _onItemTapped(0);
              },
              icon: SvgPicture.string(
                studyIcon,
                width: 32,
                height: 32,
                colorFilter:
                    _selectedIndex == 0
                        ? const ColorFilter.mode(
                          AppTheme.primary,
                          BlendMode.srcIn,
                        )
                        : const ColorFilter.mode(
                          AppTheme.black,
                          BlendMode.srcIn,
                        ),
              ),
            ),
            IconButton(
              onPressed: () {
                _onItemTapped(1);
              },
              icon: SvgPicture.string(
                leaderboardsIcon,
                width: 32,
                height: 32,
                colorFilter:
                    _selectedIndex == 1
                        ? const ColorFilter.mode(
                          AppTheme.primary,
                          BlendMode.srcIn,
                        )
                        : const ColorFilter.mode(
                          AppTheme.black,
                          BlendMode.srcIn,
                        ),
              ),
            ),
            IconButton(
              onPressed: () {
                _onItemTapped(3);
              },
              icon: SvgPicture.string(
                friendsIcon,
                width: 32,
                height: 32,
                colorFilter:
                    _selectedIndex == 3
                        ? const ColorFilter.mode(
                          AppTheme.primary,
                          BlendMode.srcIn,
                        )
                        : const ColorFilter.mode(
                          AppTheme.black,
                          BlendMode.srcIn,
                        ),
              ),
            ),
            IconButton(
              onPressed: () {
                _onItemTapped(4);
              },
              icon: SvgPicture.string(
                profileIcon,
                width: 32,
                height: 32,
                colorFilter:
                    _selectedIndex == 4
                        ? const ColorFilter.mode(
                          AppTheme.primary,
                          BlendMode.srcIn,
                        )
                        : const ColorFilter.mode(
                          AppTheme.black,
                          BlendMode.srcIn,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
