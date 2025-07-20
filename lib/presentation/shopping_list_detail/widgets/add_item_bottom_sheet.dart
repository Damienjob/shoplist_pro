import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddItemBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onItemAdded;

  const AddItemBottomSheet({
    Key? key,
    required this.onItemAdded,
  }) : super(key: key);

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String _selectedCategory = 'Groceries';
  int _quantity = 1;
  bool _isSearching = false;

  final List<String> _categories = [
    'Groceries',
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Health & Beauty',
    'Sports & Outdoors',
    'Books & Media',
    'Other'
  ];

  final List<Map<String, dynamic>> _recentProducts = [
    {
      'id': 'recent_1',
      'name': 'Organic Bananas',
      'price': 2.99,
      'category': 'Groceries',
      'image':
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
    },
    {
      'id': 'recent_2',
      'name': 'Greek Yogurt',
      'price': 4.49,
      'category': 'Groceries',
      'image':
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop',
    },
    {
      'id': 'recent_3',
      'name': 'Whole Wheat Bread',
      'price': 3.29,
      'category': 'Groceries',
      'image':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
    },
    {
      'id': 'recent_4',
      'name': 'Olive Oil',
      'price': 8.99,
      'category': 'Groceries',
      'image':
          'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop',
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _recentProducts
          .where((product) =>
              (product['name'] as String).toLowerCase().contains(query) ||
              (product['category'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  void _addCustomItem() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a product name')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;

    final newItem = {
      'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
      'name': _nameController.text.trim(),
      'price': price,
      'category': _selectedCategory,
      'quantity': _quantity,
      'isCompleted': false,
      'image':
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=400&h=400&fit=crop',
    };

    widget.onItemAdded(newItem);
    Navigator.pop(context);

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item added to list')),
    );
  }

  void _addRecentItem(Map<String, dynamic> item) {
    final newItem = Map<String, dynamic>.from(item);
    newItem['quantity'] = 1;
    newItem['isCompleted'] = false;

    widget.onItemAdded(newItem);
    Navigator.pop(context);

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} added to list')),
    );
  }

  void _openBarcodeScanner() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barcode scanner feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Item',
                    style: AppTheme.lightTheme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: _openBarcodeScanner,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'qr_code_scanner',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Search'),
              Tab(text: 'Recent'),
              Tab(text: 'Custom'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Search tab
                _buildSearchTab(),

                // Recent tab
                _buildRecentTab(),

                // Custom tab
                _buildCustomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: _isSearching
          ? _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'search_off',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No products found',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                      Text(
                        'Try a different search term',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return _buildProductTile(product);
                  },
                )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Search for products',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  Text(
                    'Type in the search bar above',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRecentTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently Added',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.builder(
              itemCount: _recentProducts.length,
              itemBuilder: (context, index) {
                final product = _recentProducts[index];
                return _buildProductTile(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Custom Item',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 3.h),

          // Product name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Product Name',
              hintText: 'Enter product name',
            ),
          ),

          SizedBox(height: 2.h),

          // Price
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Price',
              hintText: '0.00',
              prefixText: '\$ ',
            ),
          ),

          SizedBox(height: 2.h),

          // Category dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),

          SizedBox(height: 2.h),

          // Quantity
          Row(
            children: [
              Text(
                'Quantity:',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'remove',
                          color: _quantity > 1
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(minWidth: 10.w),
                      child: Text(
                        _quantity.toString(),
                        textAlign: TextAlign.center,
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addCustomItem,
              child: Text('Add to List'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(Map<String, dynamic> product) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomImageWidget(
            imageUrl: product['image'] ?? '',
            width: 12.w,
            height: 12.w,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          product['name'] ?? '',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            Text(
              '\$${(product['price'] as num).toStringAsFixed(2)}',
              style: AppTheme.priceTextStyle(isLight: true),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product['category'] ?? '',
                style: AppTheme.lightTheme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _addRecentItem(product),
          icon: CustomIconWidget(
            iconName: 'add_circle',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
