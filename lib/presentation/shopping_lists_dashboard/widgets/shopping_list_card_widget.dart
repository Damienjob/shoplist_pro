import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ShoppingListCardWidget extends StatelessWidget {
  final Map<String, dynamic> listData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool isMultiSelectMode;
  final ValueChanged<bool?>? onSelectionChanged;

  const ShoppingListCardWidget({
    Key? key,
    required this.listData,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onShare,
    this.onDelete,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemCount = (listData['items'] as List?)?.length ?? 0;
    final totalCost = (listData['totalCost'] as double?) ?? 0.0;
    final completedItems = ((listData['items'] as List?)
            ?.where((item) => item['isCompleted'] == true)
            .length ??
        0);
    final progress = itemCount > 0 ? completedItems / itemCount : 0.0;
    final lastModified = listData['lastModified'] as DateTime?;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        elevation: 2,
        shadowColor: AppTheme.lightTheme.colorScheme.shadow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isMultiSelectMode
              ? () => onSelectionChanged?.call(!isSelected)
              : onTap,
          onLongPress: () => onSelectionChanged?.call(!isSelected),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.lightTheme.primaryColor, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isMultiSelectMode) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: onSelectionChanged,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      SizedBox(width: 2.w),
                    ],
                    Expanded(
                      child: Text(
                        listData['name'] as String? ?? 'Untitled List',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'shopping_cart',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$itemCount items',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '\$${totalCost.toStringAsFixed(2)}',
                          style:
                              AppTheme.priceTextStyle(isLight: true).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          lastModified != null
                              ? _formatDate(lastModified)
                              : 'Just now',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${(progress * 100).toInt()}% complete',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: progress == 1.0
                                ? AppTheme.lightTheme.colorScheme.tertiary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: progress == 1.0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0
                          ? AppTheme.lightTheme.colorScheme.tertiary
                          : AppTheme.lightTheme.colorScheme.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                if (!isMultiSelectMode) ...[
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        icon: 'edit',
                        onTap: onEdit,
                        tooltip: 'Edit',
                      ),
                      SizedBox(width: 2.w),
                      _buildActionButton(
                        icon: 'content_copy',
                        onTap: onDuplicate,
                        tooltip: 'Duplicate',
                      ),
                      SizedBox(width: 2.w),
                      _buildActionButton(
                        icon: 'share',
                        onTap: onShare,
                        tooltip: 'Share',
                      ),
                      SizedBox(width: 2.w),
                      _buildActionButton(
                        icon: 'delete',
                        onTap: onDelete,
                        tooltip: 'Delete',
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback? onTap,
    required String tooltip,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(2.w),
          child: CustomIconWidget(
            iconName: icon,
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
