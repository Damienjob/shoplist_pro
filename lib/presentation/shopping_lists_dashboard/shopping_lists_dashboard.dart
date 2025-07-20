import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/batch_actions_toolbar_widget.dart';
import './widgets/custom_tab_bar_widget.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/shopping_list_card_widget.dart';

class ShoppingListsDashboard extends StatefulWidget {
  const ShoppingListsDashboard({Key? key}) : super(key: key);

  @override
  State<ShoppingListsDashboard> createState() => _ShoppingListsDashboardState();
}

class _ShoppingListsDashboardState extends State<ShoppingListsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMultiSelectMode = false;
  Set<int> _selectedListIds = {};
  String _searchQuery = '';
  bool _isSearchActive = false;
  List<Map<String, dynamic>> _filteredLists = [];

  // Mock data for shopping lists
  final List<Map<String, dynamic>> _shoppingLists = [
    {
      "id": 1,
      "name": "Weekly Groceries",
      "items": [
        {
          "id": 1,
          "name": "Milk",
          "quantity": 2,
          "price": 4.99,
          "isCompleted": true
        },
        {
          "id": 2,
          "name": "Bread",
          "quantity": 1,
          "price": 2.50,
          "isCompleted": true
        },
        {
          "id": 3,
          "name": "Eggs",
          "quantity": 12,
          "price": 3.99,
          "isCompleted": false
        },
        {
          "id": 4,
          "name": "Chicken Breast",
          "quantity": 2,
          "price": 12.99,
          "isCompleted": false
        },
        {
          "id": 5,
          "name": "Apples",
          "quantity": 6,
          "price": 5.99,
          "isCompleted": true
        },
      ],
      "totalCost": 30.46,
      "lastModified": DateTime.now().subtract(const Duration(hours: 2)),
      "category": "Groceries"
    },
    {
      "id": 2,
      "name": "Birthday Party Supplies",
      "items": [
        {
          "id": 6,
          "name": "Balloons",
          "quantity": 20,
          "price": 8.99,
          "isCompleted": true
        },
        {
          "id": 7,
          "name": "Cake Mix",
          "quantity": 2,
          "price": 6.50,
          "isCompleted": true
        },
        {
          "id": 8,
          "name": "Candles",
          "quantity": 1,
          "price": 3.99,
          "isCompleted": true
        },
        {
          "id": 9,
          "name": "Party Hats",
          "quantity": 10,
          "price": 12.99,
          "isCompleted": true
        },
      ],
      "totalCost": 32.47,
      "lastModified": DateTime.now().subtract(const Duration(days: 1)),
      "category": "Party"
    },
    {
      "id": 3,
      "name": "Home Improvement",
      "items": [
        {
          "id": 10,
          "name": "Paint Brushes",
          "quantity": 3,
          "price": 15.99,
          "isCompleted": false
        },
        {
          "id": 11,
          "name": "Wall Paint",
          "quantity": 2,
          "price": 45.99,
          "isCompleted": false
        },
        {
          "id": 12,
          "name": "Drop Cloth",
          "quantity": 1,
          "price": 8.99,
          "isCompleted": false
        },
      ],
      "totalCost": 70.97,
      "lastModified": DateTime.now().subtract(const Duration(days: 3)),
      "category": "Home"
    },
    {
      "id": 4,
      "name": "Office Supplies",
      "items": [
        {
          "id": 13,
          "name": "Printer Paper",
          "quantity": 1,
          "price": 12.99,
          "isCompleted": true
        },
        {
          "id": 14,
          "name": "Pens",
          "quantity": 12,
          "price": 8.99,
          "isCompleted": false
        },
        {
          "id": 15,
          "name": "Notebooks",
          "quantity": 5,
          "price": 15.99,
          "isCompleted": false
        },
      ],
      "totalCost": 37.97,
      "lastModified": DateTime.now().subtract(const Duration(hours: 6)),
      "category": "Office"
    },
  ];

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
    "memberSince": "2023",
    "totalLists": 12,
    "completedLists": 8,
  };

  final List<Map<String, String>> _tabData = [
    {"icon": "list", "label": "Lists"},
    {"icon": "inventory", "label": "Products"},
    {"icon": "person", "label": "Profile"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredLists = List.from(_shoppingLists);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterLists(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredLists = List.from(_shoppingLists);
      } else {
        _filteredLists = _shoppingLists.where((list) {
          final listName = (list['name'] as String).toLowerCase();
          final category = (list['category'] as String).toLowerCase();
          final searchLower = query.toLowerCase();
          return listName.contains(searchLower) ||
              category.contains(searchLower);
        }).toList();
      }
    });
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedListIds.clear();
      }
    });
  }

  void _toggleListSelection(int listId) {
    setState(() {
      if (_selectedListIds.contains(listId)) {
        _selectedListIds.remove(listId);
      } else {
        _selectedListIds.add(listId);
      }

      if (_selectedListIds.isEmpty && _isMultiSelectMode) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _selectAllLists() {
    setState(() {
      _selectedListIds =
          _filteredLists.map((list) => list['id'] as int).toSet();
    });
  }

  void _deselectAllLists() {
    setState(() {
      _selectedListIds.clear();
      _isMultiSelectMode = false;
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Lists',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete ${_selectedListIds.length} selected list(s)? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSelectedLists();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedLists() {
    setState(() {
      _shoppingLists
          .removeWhere((list) => _selectedListIds.contains(list['id']));
      _filteredLists
          .removeWhere((list) => _selectedListIds.contains(list['id']));
      _selectedListIds.clear();
      _isMultiSelectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lists deleted successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _duplicateSelectedLists() {
    setState(() {
      final listsToAdd = <Map<String, dynamic>>[];
      for (final listId in _selectedListIds) {
        final originalList =
            _shoppingLists.firstWhere((list) => list['id'] == listId);
        final duplicatedList = Map<String, dynamic>.from(originalList);
        duplicatedList['id'] = _shoppingLists.length + listsToAdd.length + 1;
        duplicatedList['name'] = '${duplicatedList['name']} (Copy)';
        duplicatedList['lastModified'] = DateTime.now();
        listsToAdd.add(duplicatedList);
      }
      _shoppingLists.addAll(listsToAdd);
      _filteredLists = List.from(_shoppingLists);
      _selectedListIds.clear();
      _isMultiSelectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lists duplicated successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _shareSelectedLists() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${_selectedListIds.length} list(s)...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );

    setState(() {
      _selectedListIds.clear();
      _isMultiSelectMode = false;
    });
  }

  Widget _buildListsTab() {
    return Column(
      children: [
        if (_isSearchActive)
          SearchBarWidget(
            onSearchChanged: _filterLists,
            onClear: () {
              setState(() {
                _isSearchActive = false;
                _searchQuery = '';
                _filteredLists = List.from(_shoppingLists);
              });
            },
          ),
        Expanded(
          child: _filteredLists.isEmpty
              ? _searchQuery.isNotEmpty
                  ? _buildNoResultsWidget()
                  : EmptyStateWidget(
                      onCreateList: () {
                        Navigator.pushNamed(context, '/shopping-list-detail');
                      },
                    )
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {
                      _filteredLists = List.from(_shoppingLists);
                    });
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 10.h),
                    itemCount: _filteredLists.length,
                    itemBuilder: (context, index) {
                      final list = _filteredLists[index];
                      final listId = list['id'] as int;

                      return ShoppingListCardWidget(
                        listData: list,
                        isSelected: _selectedListIds.contains(listId),
                        isMultiSelectMode: _isMultiSelectMode,
                        onTap: () {
                          if (!_isMultiSelectMode) {
                            Navigator.pushNamed(
                                context, '/shopping-list-detail');
                          }
                        },
                        onSelectionChanged: (selected) {
                          if (!_isMultiSelectMode) {
                            _toggleMultiSelectMode();
                          }
                          _toggleListSelection(listId);
                        },
                        onEdit: () {
                          Navigator.pushNamed(context, '/shopping-list-detail');
                        },
                        onDuplicate: () {
                          setState(() {
                            final duplicatedList =
                                Map<String, dynamic>.from(list);
                            duplicatedList['id'] = _shoppingLists.length + 1;
                            duplicatedList['name'] =
                                '${duplicatedList['name']} (Copy)';
                            duplicatedList['lastModified'] = DateTime.now();
                            _shoppingLists.add(duplicatedList);
                            _filteredLists = List.from(_shoppingLists);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('List duplicated successfully'),
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.tertiary,
                            ),
                          );
                        },
                        onShare: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sharing "${list['name']}"...'),
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Delete List',
                                  style:
                                      AppTheme.lightTheme.textTheme.titleLarge,
                                ),
                                content: Text(
                                  'Are you sure you want to delete "${list['name']}"? This action cannot be undone.',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        _shoppingLists.removeWhere(
                                            (item) => item['id'] == listId);
                                        _filteredLists.removeWhere(
                                            (item) => item['id'] == listId);
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('List deleted successfully'),
                                          backgroundColor: AppTheme
                                              .lightTheme.colorScheme.tertiary,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppTheme.lightTheme.colorScheme.error,
                                    ),
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Results Found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'No shopping lists match "$_searchQuery"',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'inventory_2',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Products Coming Soon',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Manage your favorite products and templates here.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CustomImageWidget(
                  imageUrl: _userData['avatar'] as String,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              _userData['name'] as String,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _userData['email'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user-profile');
              },
              child: Text('View Full Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            DashboardHeaderWidget(
              userName: _userData['name'] as String,
              userAvatar: _userData['avatar'] as String,
              onSearchTap: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                });
              },
              onProfileTap: () {
                Navigator.pushNamed(context, '/user-profile');
              },
            ),
            CustomTabBarWidget(
              tabController: _tabController,
              tabs: _tabData,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListsTab(),
                  _buildProductsTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0 && !_isMultiSelectMode
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/shopping-list-detail');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'New List',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              elevation: 6,
            )
          : null,
      bottomSheet: _isMultiSelectMode
          ? BatchActionsToolbarWidget(
              selectedCount: _selectedListIds.length,
              onSelectAll: _selectAllLists,
              onDeselectAll: _deselectAllLists,
              onDuplicate: _duplicateSelectedLists,
              onShare: _shareSelectedLists,
              onDelete: _showDeleteConfirmation,
              onCancel: () {
                setState(() {
                  _isMultiSelectMode = false;
                  _selectedListIds.clear();
                });
              },
            )
          : null,
    );
  }
}
