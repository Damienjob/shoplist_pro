import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_item_bottom_sheet.dart';
import './widgets/empty_list_widget.dart';
import './widgets/list_header_widget.dart';
import './widgets/shopping_item_card.dart';

class ShoppingListDetail extends StatefulWidget {
  const ShoppingListDetail({Key? key}) : super(key: key);

  @override
  State<ShoppingListDetail> createState() => _ShoppingListDetailState();
}

class _ShoppingListDetailState extends State<ShoppingListDetail>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _searchController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _searchAnimation;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();

  String _listName = 'Weekly Groceries';
  bool _showSearch = false;
  bool _isMultiSelectMode = false;
  String _searchQuery = '';
  Set<String> _selectedItems = {};

  // Mock shopping list data
  List<Map<String, dynamic>> _shoppingItems = [
    {
      'id': 'item_1',
      'name': 'Organic Bananas',
      'price': 2.99,
      'quantity': 3,
      'category': 'Fruits',
      'isCompleted': false,
      'image':
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    },
    {
      'id': 'item_2',
      'name': 'Greek Yogurt',
      'price': 4.49,
      'quantity': 2,
      'category': 'Dairy',
      'isCompleted': true,
      'image':
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop',
    },
    {
      'id': 'item_3',
      'name': 'Whole Wheat Bread',
      'price': 3.29,
      'quantity': 1,
      'category': 'Bakery',
      'isCompleted': false,
      'image':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
    },
    {
      'id': 'item_4',
      'name': 'Extra Virgin Olive Oil',
      'price': 8.99,
      'quantity': 1,
      'category': 'Pantry',
      'isCompleted': false,
      'image':
          'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop',
    },
    {
      'id': 'item_5',
      'name': 'Fresh Salmon Fillet',
      'price': 12.99,
      'quantity': 1,
      'category': 'Seafood',
      'isCompleted': false,
      'image':
          'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400&h=400&fit=crop',
    },
    {
      'id': 'item_6',
      'name': 'Organic Spinach',
      'price': 3.49,
      'quantity': 2,
      'category': 'Vegetables',
      'isCompleted': true,
      'image':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&h=400&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));

    _searchAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);
    _searchTextController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_fabController.isCompleted) {
      _fabController.forward();
    } else if (_scrollController.offset <= 100 && _fabController.isCompleted) {
      _fabController.reverse();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchTextController.text.toLowerCase();
    });
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_searchQuery.isEmpty) return _shoppingItems;

    return _shoppingItems.where((item) {
      final name = (item['name'] as String).toLowerCase();
      final category = (item['category'] as String).toLowerCase();
      return name.contains(_searchQuery) || category.contains(_searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> get _activeItems {
    return _filteredItems
        .where((item) => !(item['isCompleted'] as bool))
        .toList();
  }

  List<Map<String, dynamic>> get _completedItems {
    return _filteredItems.where((item) => item['isCompleted'] as bool).toList();
  }

  double get _totalCost {
    return _shoppingItems.fold(0.0, (sum, item) {
      final price = (item['price'] as num).toDouble();
      final quantity = item['quantity'] as int;
      return sum + (price * quantity);
    });
  }

  int get _completedCount {
    return _shoppingItems.where((item) => item['isCompleted'] as bool).length;
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });

    if (_showSearch) {
      _searchController.forward();
    } else {
      _searchController.reverse();
      _searchTextController.clear();
    }
  }

  void _onItemUpdated(Map<String, dynamic> updatedItem) {
    setState(() {
      final index =
          _shoppingItems.indexWhere((item) => item['id'] == updatedItem['id']);
      if (index != -1) {
        _shoppingItems[index] = updatedItem;
      }
    });
  }

  void _onItemDeleted(String itemId) {
    setState(() {
      _shoppingItems.removeWhere((item) => item['id'] == itemId);
    });
  }

  void _onItemToggled(Map<String, dynamic> toggledItem) {
    setState(() {
      final index =
          _shoppingItems.indexWhere((item) => item['id'] == toggledItem['id']);
      if (index != -1) {
        _shoppingItems[index] = toggledItem;
      }
    });

    HapticFeedback.mediumImpact();
  }

  void _onItemAdded(Map<String, dynamic> newItem) {
    setState(() {
      _shoppingItems.add(newItem);
    });
  }

  void _onListNameChanged(String newName) {
    setState(() {
      _listName = newName;
    });
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddItemBottomSheet(
        onItemAdded: _onItemAdded,
      ),
    );
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedItems.clear();
      }
    });
  }

  void _onItemSelected(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _deleteSelectedItems() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Items'),
        content: Text('Delete ${_selectedItems.length} selected items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _shoppingItems
                    .removeWhere((item) => _selectedItems.contains(item['id']));
                _selectedItems.clear();
                _isMultiSelectMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected items deleted')),
              );
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorLight),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Simulate refresh delay
    await Future.delayed(Duration(seconds: 1));

    // Update prices (simulate real-time price updates)
    setState(() {
      for (var item in _shoppingItems) {
        final currentPrice = (item['price'] as num).toDouble();
        final priceVariation =
            (currentPrice * 0.05) * (0.5 - (DateTime.now().millisecond / 1000));
        item['price'] =
            (currentPrice + priceVariation).clamp(0.99, currentPrice * 2);
      }
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prices updated'),
        duration: Duration(seconds: 2),
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
            // Custom app bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Shopping List',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                  ),
                  if (_isMultiSelectMode) ...[
                    Text(
                      '${_selectedItems.length} selected',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      onPressed: _deleteSelectedItems,
                      icon: CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.errorLight,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleMultiSelect,
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: _toggleSearch,
                      icon: CustomIconWidget(
                        iconName: _showSearch ? 'close' : 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleMultiSelect,
                      icon: CustomIconWidget(
                        iconName: 'checklist',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Search bar
            SlideTransition(
              position: _searchAnimation,
              child: _showSearch
                  ? Container(
                      padding: EdgeInsets.all(4.w),
                      color: AppTheme.lightTheme.colorScheme.surface,
                      child: TextField(
                        controller: _searchTextController,
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'search',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                        autofocus: true,
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            // List header
            ListHeaderWidget(
              listName: _listName,
              totalCost: _totalCost,
              totalItems: _shoppingItems.length,
              completedItems: _completedCount,
              onListNameChanged: _onListNameChanged,
              onMenuPressed: () {},
            ),

            // Content
            Expanded(
              child: _shoppingItems.isEmpty
                  ? EmptyListWidget(
                      onAddFirstItem: _showAddItemSheet,
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Active items
                          if (_activeItems.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                                child: Text(
                                  'Shopping List',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = _activeItems[index];
                                  return ShoppingItemCard(
                                    item: item,
                                    onItemUpdated: _onItemUpdated,
                                    onItemDeleted: _onItemDeleted,
                                    onItemToggled: _onItemToggled,
                                    isSelected:
                                        _selectedItems.contains(item['id']),
                                    onItemSelected: _isMultiSelectMode
                                        ? _onItemSelected
                                        : null,
                                  );
                                },
                                childCount: _activeItems.length,
                              ),
                            ),
                          ],

                          // Completed items
                          if (_completedItems.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                                child: Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'check_circle',
                                      color: AppTheme.successLight,
                                      size: 20,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Completed (${_completedItems.length})',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = _completedItems[index];
                                  return Opacity(
                                    opacity: 0.6,
                                    child: ShoppingItemCard(
                                      item: item,
                                      onItemUpdated: _onItemUpdated,
                                      onItemDeleted: _onItemDeleted,
                                      onItemToggled: _onItemToggled,
                                      isSelected:
                                          _selectedItems.contains(item['id']),
                                      onItemSelected: _isMultiSelectMode
                                          ? _onItemSelected
                                          : null,
                                    ),
                                  );
                                },
                                childCount: _completedItems.length,
                              ),
                            ),
                          ],

                          // Bottom padding
                          SliverToBoxAdapter(
                            child: SizedBox(height: 20.h),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showAddItemSheet,
          icon: CustomIconWidget(
            iconName: 'add',
            color: Colors.white,
            size: 24,
          ),
          label: Text('Add Item'),
        ),
      ),
    );
  }
}
