import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ListHeaderWidget extends StatefulWidget {
  final String listName;
  final double totalCost;
  final int totalItems;
  final int completedItems;
  final Function(String) onListNameChanged;
  final VoidCallback onMenuPressed;

  const ListHeaderWidget({
    Key? key,
    required this.listName,
    required this.totalCost,
    required this.totalItems,
    required this.completedItems,
    required this.onListNameChanged,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  State<ListHeaderWidget> createState() => _ListHeaderWidgetState();
}

class _ListHeaderWidgetState extends State<ListHeaderWidget>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late AnimationController _countController;
  late Animation<double> _countAnimation;

  bool _isEditing = false;
  double _animatedTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listName);
    _animatedTotal = widget.totalCost;

    _countController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _countAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(ListHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalCost != widget.totalCost) {
      _animateTotal(oldWidget.totalCost, widget.totalCost);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _animateTotal(double from, double to) {
    final animation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
    );

    animation.addListener(() {
      setState(() {
        _animatedTotal = animation.value;
      });
    });

    _countController.reset();
    _countController.forward();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });

    // Focus and select all text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  void _finishEditing() {
    setState(() {
      _isEditing = false;
    });

    if (_nameController.text.trim().isNotEmpty) {
      widget.onListNameChanged(_nameController.text.trim());
      HapticFeedback.lightImpact();
    } else {
      _nameController.text = widget.listName;
    }
  }

  void _showListMenu() {
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
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Share List',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _shareList();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Duplicate List',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _duplicateList();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Export as PDF',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'clear_all',
                color: AppTheme.warningLight,
                size: 24,
              ),
              title: Text(
                'Clear Completed',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _clearCompleted();
              },
            ),
            Divider(),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: Text(
                'Delete List',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.errorLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _shareList() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _duplicateList() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('List duplicated successfully!')),
    );
  }

  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF export functionality coming soon!')),
    );
  }

  void _clearCompleted() {
    if (widget.completedItems > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Clear Completed Items'),
          content: Text('Remove all completed items from this list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Completed items cleared')),
                );
              },
              child: Text('Clear'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No completed items to clear')),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete List',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete "${widget.listName}"? This action cannot be undone.',
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
              Navigator.pop(context); // Go back to dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('List deleted'),
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
    final completionPercentage = widget.totalItems > 0
        ? (widget.completedItems / widget.totalItems)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List name and menu
          Row(
            children: [
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _nameController,
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _finishEditing(),
                        onTapOutside: (_) => _finishEditing(),
                        autofocus: true,
                      )
                    : GestureDetector(
                        onTap: _startEditing,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.listName,
                                style:
                                    AppTheme.lightTheme.textTheme.headlineSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName: 'edit',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
              ),
              IconButton(
                onPressed: _showListMenu,
                icon: CustomIconWidget(
                  iconName: 'more_vert',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Total cost
          Row(
            children: [
              Text(
                'Total: ',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              AnimatedBuilder(
                animation: _countAnimation,
                builder: (context, child) {
                  return Text(
                    '\$${_animatedTotal.toStringAsFixed(2)}',
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Progress info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.completedItems} of ${widget.totalItems} items completed',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Progress bar
                    Container(
                      height: 0.8.h,
                      decoration: BoxDecoration(
                        color: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: completionPercentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: completionPercentage == 1.0
                                ? AppTheme.successLight
                                : AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Completion percentage
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: completionPercentage == 1.0
                      ? AppTheme.successLight.withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (completionPercentage == 1.0)
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.successLight,
                        size: 16,
                      ),
                    if (completionPercentage == 1.0) SizedBox(width: 1.w),
                    Text(
                      '${(completionPercentage * 100).round()}%',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: completionPercentage == 1.0
                            ? AppTheme.successLight
                            : AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
