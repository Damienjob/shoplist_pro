import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BatchActionsToolbarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const BatchActionsToolbarWidget({
    Key? key,
    required this.selectedCount,
    this.onSelectAll,
    this.onDeselectAll,
    this.onDuplicate,
    this.onShare,
    this.onDelete,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(2.w),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                '$selectedCount selected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  icon: 'select_all',
                  onTap: onSelectAll,
                  tooltip: 'Select All',
                ),
                SizedBox(width: 2.w),
                _buildActionButton(
                  icon: 'content_copy',
                  onTap: selectedCount > 0 ? onDuplicate : null,
                  tooltip: 'Duplicate',
                  isEnabled: selectedCount > 0,
                ),
                SizedBox(width: 2.w),
                _buildActionButton(
                  icon: 'share',
                  onTap: selectedCount > 0 ? onShare : null,
                  tooltip: 'Share',
                  isEnabled: selectedCount > 0,
                ),
                SizedBox(width: 2.w),
                _buildActionButton(
                  icon: 'delete',
                  onTap: selectedCount > 0 ? onDelete : null,
                  tooltip: 'Delete',
                  isEnabled: selectedCount > 0,
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback? onTap,
    required String tooltip,
    bool isEnabled = true,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(2.w),
          child: CustomIconWidget(
            iconName: icon,
            color: !isEnabled
                ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4)
                : isDestructive
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
