// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:sp_code/config/theme.dart';
import 'package:sp_code/utils/widgets/circle_tab_indicator.dart';

class StudyTabs extends StatefulWidget {
  const StudyTabs({Key? key}) : super(key: key);

  @override
  State<StudyTabs> createState() => _StudyTabsState();
}

class _StudyTabsState extends State<StudyTabs>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _tabController!.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicator: CircleTabIndicator(color: AppTheme.primary, radius: 3),
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.grey3,
          unselectedLabelStyle: const TextStyle(color: AppTheme.grey2),
          tabs: const [Tab(text: "Quizzes"), Tab(text: "Flashcards")],
          dividerHeight: 0,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          child: Container(
            height: 550,
            decoration: const BoxDecoration(color: AppTheme.white),
            child: TabBarView(
              controller: _tabController,
              children: const [
                Icon(Icons.directions_car),
                Icon(Icons.directions_transit),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
