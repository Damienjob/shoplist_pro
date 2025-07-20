import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentProductsWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onProductSelected;

  const RecentProductsWidget({
    Key? key,
    required this.onProductSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recentProducts = [
      {
        "id": 1,
        "name": "Organic Bananas",
        "category": "Groceries",
        "price": "\$3.99",
        "quantity": 1,
        "image":
            "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop",
        "lastUsed": DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        "id": 2,
        "name": "Greek Yogurt",
        "category": "Groceries",
        "price": "\$5.49",
        "quantity": 2,
        "image":
            "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop",
        "lastUsed": DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        "id": 3,
        "name": "Whole Wheat Bread",
        "category": "Groceries",
        "price": "\$2.99",
        "quantity": 1,
        "image":
            "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop",
        "lastUsed": DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        "id": 4,
        "name": "Almond Milk",
        "category": "Groceries",
        "price": "\$4.29",
        "quantity": 1,
        "image":
            "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop",
        "lastUsed": DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        "id": 5,
        "name": "Chicken Breast",
        "category": "Groceries",
        "price": "\$8.99",
        "quantity": 1,
        "image":
            "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&h=400&fit=crop",
        "lastUsed": DateTime.now().subtract(const Duration(days: 5)),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Recent Products',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: recentProducts.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final product = recentProducts[index];
              return _buildRecentProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProductCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () => onProductSelected(product),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 25.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: product['image'] ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      product['price'] ?? '',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
