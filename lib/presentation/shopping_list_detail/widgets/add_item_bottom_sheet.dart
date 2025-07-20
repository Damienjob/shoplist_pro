import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/product_service.dart';

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

  List<Product> _searchResults = [];
  List<Product> _recentProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);

    // Load recent products from ProductService
    _recentProducts = ProductService.instance.getRecentProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = ProductService.instance.searchProducts(query);
    });
  }

  void _addCustomItem() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a product name')),
      );
      return;
    }

    // Only pass name and quantity - price will be looked up automatically
    final newItem = {
      'name': _nameController.text.trim(),
      'quantity': _quantity,
    };

    widget.onItemAdded(newItem);
    Navigator.pop(context);

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item added to list')),
    );
  }

  void _addProductItem(Product product) {
    // Only pass name and quantity - price will be looked up automatically
    final newItem = {
      'name': product.name,
      'quantity': 1,
    };

    widget.onItemAdded(newItem);
    Navigator.pop(context);

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to list')),
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

          // Category dropdown (optional - for better organization)
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category (Optional)',
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

  Widget _buildProductTile(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomImageWidget(
            imageUrl: product.image ?? '',
            width: 12.w,
            height: 12.w,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          product.name,
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
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
                product.category,
                style: AppTheme.lightTheme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _addProductItem(product),
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
