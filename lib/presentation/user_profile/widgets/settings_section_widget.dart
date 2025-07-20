import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              indent: 4.w,
              endIndent: 4.w,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                leading: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: item.iconBackgroundColor ??
                        AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: item.iconName,
                    color: item.iconColor ??
                        AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                trailing: item.hasSwitch
                    ? Switch(
                        value: item.switchValue ?? false,
                        onChanged: item.onSwitchChanged,
                      )
                    : item.trailingText != null
                        ? Text(
                            item.trailingText!,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'chevron_right',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                onTap: item.onTap,
              );
            },
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}

class SettingsItem {
  final String iconName;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final bool hasSwitch;
  final bool? switchValue;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwitchChanged;

  SettingsItem({
    required this.iconName,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.hasSwitch = false,
    this.switchValue,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
    this.onSwitchChanged,
  });
}
