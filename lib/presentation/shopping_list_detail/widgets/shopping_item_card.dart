import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ShoppingItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onItemUpdated;
  final Function(String) onItemDeleted;
  final Function(Map<String, dynamic>) onItemToggled;
  final bool isSelected;
  final Function(String)? onItemSelected;

  const ShoppingItemCard({
    Key? key,
    required this.item,
    required this.onItemUpdated,
    required this.onItemDeleted,
    required this.onItemToggled,
    this.isSelected = false,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<ShoppingItemCard> createState() => _ShoppingItemCardState();
}

class _ShoppingItemCardState extends State<ShoppingItemCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isCompleted = false;
  int _quantity = 1;
  double _swipeOffset = 0.0;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.item['isCompleted'] ?? false;
    _quantity = widget.item['quantity'] ?? 1;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity < 1) return;

    HapticFeedback.lightImpact();
    setState(() {
      _quantity = newQuantity;
    });

    final updatedItem = Map<String, dynamic>.from(widget.item);
    updatedItem['quantity'] = newQuantity;
    widget.onItemUpdated(updatedItem);
  }

  void _toggleCompletion() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCompleted = !_isCompleted;
    });

    final updatedItem = Map<String, dynamic>.from(widget.item);
    updatedItem['isCompleted'] = _isCompleted;
    widget.onItemToggled(updatedItem);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dx;
      _swipeOffset = _swipeOffset.clamp(-80.w, 80.w);
      _showActions = _swipeOffset.abs() > 15.w;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_swipeOffset.abs() > 25.w) {
      if (_swipeOffset > 0) {
        // Swipe right - Edit/Favorite actions
        _showEditOptions();
      } else {
        // Swipe left - Delete action
        _showDeleteConfirmation();
      }
    }

    setState(() {
      _swipeOffset = 0.0;
      _showActions = false;
    });
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Edit Item',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-edit-product');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.warningLight,
                size: 24,
              ),
              title: Text(
                'Add to Favorites',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added to favorites'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Item',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete "${widget.item['name']}"?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onItemDeleted(widget.item['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Undo delete functionality
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double price = (widget.item['price'] as num?)?.toDouble() ?? 0.0;
    final double totalPrice = price * _quantity;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
        widget.onItemSelected?.call(widget.item['id']);
      },
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Stack(
                children: [
                  // Background actions
                  if (_showActions)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _swipeOffset > 0
                              ? AppTheme.successLight.withValues(alpha: 0.1)
                              : AppTheme.errorLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: _swipeOffset > 0
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            if (_swipeOffset > 0) ...[
                              SizedBox(width: 4.w),
                              CustomIconWidget(
                                iconName: 'edit',
                                color: AppTheme.successLight,
                                size: 24,
                              ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'favorite_border',
                                color: AppTheme.warningLight,
                                size: 24,
                              ),
                            ] else ...[
                              CustomIconWidget(
                                iconName: 'delete',
                                color: AppTheme.errorLight,
                                size: 24,
                              ),
                              SizedBox(width: 4.w),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // Main card
                  Transform.translate(
                    offset: Offset(_swipeOffset, 0),
                    child: Card(
                      elevation: widget.isSelected ? 8 : 2,
                      color: widget.isSelected
                          ? AppTheme.lightTheme.colorScheme.primaryContainer
                          : AppTheme.lightTheme.colorScheme.surface,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          children: [
                            // Checkbox
                            GestureDetector(
                              onTap: _toggleCompletion,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: _isCompleted
                                      ? AppTheme.successLight
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _isCompleted
                                        ? AppTheme.successLight
                                        : AppTheme
                                            .lightTheme.colorScheme.outline,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _isCompleted
                                    ? CustomIconWidget(
                                        iconName: 'check',
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),

                            SizedBox(width: 3.w),

                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomImageWidget(
                                imageUrl: widget.item['image'] ?? '',
                                width: 12.w,
                                height: 12.w,
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 3.w),

                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.item['name'] ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      decoration: _isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: _isCompleted
                                          ? AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant
                                          : AppTheme
                                              .lightTheme.colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${price.toStringAsFixed(2)}',
                                        style: AppTheme.priceTextStyle(
                                                isLight: true)
                                            .copyWith(
                                          color: _isCompleted
                                              ? AppTheme.lightTheme.colorScheme
                                                  .onSurfaceVariant
                                              : AppTheme.lightTheme.colorScheme
                                                  .primary,
                                        ),
                                      ),
                                      if (widget.item['category'] != null) ...[
                                        SizedBox(width: 2.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 0.5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.lightTheme
                                                .colorScheme.secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            widget.item['category'],
                                            style: AppTheme.lightTheme.textTheme
                                                .labelSmall,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quantity controls
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _updateQuantity(_quantity - 1),
                                    child: Container(
                                      padding: EdgeInsets.all(2.w),
                                      child: CustomIconWidget(
                                        iconName: 'remove',
                                        color: _quantity > 1
                                            ? AppTheme
                                                .lightTheme.colorScheme.primary
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurfaceVariant,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(minWidth: 8.w),
                                    child: Text(
                                      _quantity.toString(),
                                      textAlign: TextAlign.center,
                                      style: AppTheme.quantityTextStyle(
                                              isLight: true)
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _updateQuantity(_quantity + 1),
                                    child: Container(
                                      padding: EdgeInsets.all(2.w),
                                      child: CustomIconWidget(
                                        iconName: 'add',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 2.w),

                            // Total price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${totalPrice.toStringAsFixed(2)}',
                                  style: AppTheme.priceTextStyle(isLight: true)
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _isCompleted
                                        ? AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant
                                        : AppTheme
                                            .lightTheme.colorScheme.primary,
                                  ),
                                ),
                                if (_quantity > 1)
                                  Text(
                                    '${_quantity}x \$${price.toStringAsFixed(2)}',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
