import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sp_code/model/category.dart';
import 'package:sp_code/theme/theme.dart';
import 'package:sp_code/view/user/category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];

  List<String> _categoryFilters = ['All'];
  String _selectedFilter = "All";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            .orderBy('createdAt', descending: true)
            .get();

    setState(() {
      _allCategories =
          snapshot.docs
              .map((doc) => Category.fromMap(doc.id, doc.data()))
              .toList();

      _categoryFilters =
          ['All'] +
          _allCategories.map((category) => category.name).toSet().toList();

      _filteredCategories = _allCategories;
    });
  }

  void _filterCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories =
          _allCategories.where((category) {
            final matchesSearch =
                category.name.toLowerCase().contains(query.toLowerCase()) ||
                category.description.toLowerCase().contains(
                  query.toLowerCase(),
                );

            final matchesCategory =
                categoryFilter == null ||
                categoryFilter == "All" ||
                category.name.toLowerCase() == categoryFilter.toLowerCase();

            return matchesSearch && matchesCategory;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 225,
            pinned: true,
            floating: true,
            centerTitle: false,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: Text(
              "eLaw",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: kToolbarHeight + 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, Learner!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Let's test your knowledge today",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white.withOpacity(0.8),
                            ),
                          ),
                          // SizedBox(height: 16),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: AppTheme.white,
                          //     borderRadius: BorderRadius.circular(8),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black.withOpacity(0.1),
                          //         blurRadius: 4,
                          //         offset: Offset(0, 2),
                          //       ),
                          //     ],
                          //   ),
                          //   child: TextField(
                          //     controller: _searchController,
                          //     onChanged: (value) => _filterCategories(value),
                          //     decoration: InputDecoration(
                          //       hintText: "Search categories...",
                          //       prefixIcon: Icon(
                          //         Icons.search,
                          //         color: AppTheme.primary,
                          //       ),
                          //       suffixIcon:
                          //           _searchController.text.isNotEmpty
                          //               ? IconButton(
                          //                 onPressed: () {
                          //                   _searchController.clear();
                          //                   _filterCategories('');
                          //                 },
                          //                 icon: Icon(
                          //                   Icons.clear,
                          //                   color: AppTheme.primary,
                          //                 ),
                          //               )
                          //               : null,
                          //       border: InputBorder.none,
                          //       contentPadding: EdgeInsets.symmetric(
                          //         horizontal: 16,
                          //         vertical: 12,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: Container(
          //     margin: EdgeInsets.all(16),
          //     height: 40,
          //     child: ListView.builder(
          //       scrollDirection: Axis.horizontal,
          //       itemCount: _categoryFilters.length,
          //       itemBuilder: (context, index) {
          //         final filter = _categoryFilters[index];
          //         return Padding(
          //           padding: EdgeInsets.only(right: 8),
          //           child: ChoiceChip(
          //             label: Text(
          //               filter,
          //               style: TextStyle(
          //                 color:
          //                     _selectedFilter == filter
          //                         ? AppTheme.white
          //                         : AppTheme.text,
          //               ),
          //             ),
          //             selected: _selectedFilter == filter,
          //             selectedColor: AppTheme.primary,
          //             backgroundColor: AppTheme.white,
          //             onSelected: (bool selected) {
          //               setState(() {
          //                 _selectedFilter = filter;
          //                 _filterCategories(
          //                   _searchController.text,
          //                   categoryFilter: filter,
          //                 );
          //               });
          //             },
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver:
                _filteredCategories.isEmpty
                    ? SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "No categories found",
                          style: TextStyle(color: AppTheme.text2),
                        ),
                      ),
                    )
                    : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        childCount: 3,
                        (context, index) => _buildCategoryCard(
                          _filteredCategories[index],
                          index,
                        ),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(category: category),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.quiz, size: 48, color: AppTheme.primary),
                  ),
                  SizedBox(height: 10),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }
}
