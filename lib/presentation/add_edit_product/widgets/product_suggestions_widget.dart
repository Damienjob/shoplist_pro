import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductSuggestionsWidget extends StatelessWidget {
  final String searchQuery;
  final Function(Map<String, dynamic>) onSuggestionSelected;

  const ProductSuggestionsWidget({
    Key? key,
    required this.searchQuery,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) return const SizedBox.shrink();

    final List<Map<String, dynamic>> allSuggestions = [
      {
        "name": "Apple iPhone 15",
        "category": "Electronics",
        "price": "\$799.00",
        "image":
            "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=400&fit=crop",
      },
      {
        "name": "Apple MacBook Air",
        "category": "Electronics",
        "price": "\$999.00",
        "image":
            "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400&h=400&fit=crop",
      },
      {
        "name": "Organic Apples",
        "category": "Groceries",
        "price": "\$4.99",
        "image":
            "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=400&fit=crop",
      },
      {
        "name": "Banana Bread Mix",
        "category": "Groceries",
        "price": "\$3.49",
        "image":
            "https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=400&fit=crop",
      },
      {
        "name": "Milk Chocolate Bar",
        "category": "Groceries",
        "price": "\$2.99",
        "image":
            "https://images.unsplash.com/photo-1511381939415-e44015466834?w=400&h=400&fit=crop",
      },
      {
        "name": "Wireless Headphones",
        "category": "Electronics",
        "price": "\$149.99",
        "image":
            "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop",
      },
      {
        "name": "Cotton T-Shirt",
        "category": "Clothing",
        "price": "\$19.99",
        "image":
            "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop",
      },
      {
        "name": "Running Shoes",
        "category": "Sports & Outdoors",
        "price": "\$89.99",
        "image":
            "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop",
      },
      {
        "name": "Coffee Beans",
        "category": "Groceries",
        "price": "\$12.99",
        "image":
            "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop",
      },
      {
        "name": "Notebook Set",
        "category": "Books & Media",
        "price": "\$15.99",
        "image":
            "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop",
      },
    ];

    final filteredSuggestions = (allSuggestions as List)
        .where((dynamic product) {
          final productMap = product as Map<String, dynamic>;
          final name = (productMap['name'] as String).toLowerCase();
          final category = (productMap['category'] as String).toLowerCase();
          final query = searchQuery.toLowerCase();
          return name.contains(query) || category.contains(query);
        })
        .take(5)
        .toList();

    if (filteredSuggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Suggestions',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredSuggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
            itemBuilder: (context, index) {
              final suggestion =
                  filteredSuggestions[index] as Map<String, dynamic>;
              return _buildSuggestionItem(suggestion);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    return InkWell(
      onTap: () => onSuggestionSelected(suggestion),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CustomImageWidget(
                  imageUrl: suggestion['image'] ?? '',
                  width: 10.w,
                  height: 10.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['name'] ?? '',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        suggestion['category'] ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        suggestion['price'] ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add Icon
            CustomIconWidget(
              iconName: 'add_circle_outline',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
