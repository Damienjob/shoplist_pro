
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/image_picker_bottom_sheet.dart';
import './widgets/logout_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "profileImage":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "isPremium": true,
    "memberSince": "January 2023",
    "totalLists": 24,
    "completedItems": 156
  };

  // Settings state
  bool _biometricEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkModeEnabled = false;
  bool _dataSync = true;
  String _selectedCurrency = "USD";
  String _selectedLanguage = "English";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerBottomSheet(
        onCameraPressed: _pickImageFromCamera,
        onGalleryPressed: _pickImageFromGallery,
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.camera.request();
        if (!permission.isGranted) {
          _showErrorSnackBar('Camera permission denied');
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          userData["profileImage"] = image.path;
        });
        _showSuccessSnackBar('Profile picture updated successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          userData["profileImage"] = image.path;
        });
        _showSuccessSnackBar('Profile picture updated successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

  void _navigateToEditProfile() {
    _showErrorSnackBar('Edit profile feature coming soon');
  }

  List<SettingsItem> _getAccountSettingsItems() {
    return [
      SettingsItem(
        iconName: 'person',
        title: 'Personal Information',
        subtitle: 'Name, email, phone number',
        onTap: () =>
            _showErrorSnackBar('Personal information editing coming soon'),
      ),
      SettingsItem(
        iconName: 'lock',
        title: 'Password & Security',
        subtitle: 'Change password, two-factor auth',
        onTap: () => _showErrorSnackBar('Security settings coming soon'),
      ),
      SettingsItem(
        iconName: 'fingerprint',
        title: 'Biometric Authentication',
        subtitle: 'Use fingerprint or face ID',
        hasSwitch: true,
        switchValue: _biometricEnabled,
        onSwitchChanged: (value) {
          setState(() {
            _biometricEnabled = value;
          });
          _showSuccessSnackBar(
              'Biometric authentication ${value ? 'enabled' : 'disabled'}');
        },
      ),
    ];
  }

  List<SettingsItem> _getShoppingPreferencesItems() {
    return [
      SettingsItem(
        iconName: 'attach_money',
        title: 'Default Currency',
        trailingText: _selectedCurrency,
        onTap: () => _showCurrencyPicker(),
      ),
      SettingsItem(
        iconName: 'calculate',
        title: 'Tax Settings',
        subtitle: 'Configure tax calculations',
        onTap: () => _showErrorSnackBar('Tax settings coming soon'),
      ),
      SettingsItem(
        iconName: 'store',
        title: 'Favorite Stores',
        subtitle: 'Manage your preferred stores',
        onTap: () => _showErrorSnackBar('Favorite stores coming soon'),
      ),
      SettingsItem(
        iconName: 'language',
        title: 'Language',
        trailingText: _selectedLanguage,
        onTap: () => _showLanguagePicker(),
      ),
    ];
  }

  List<SettingsItem> _getNotificationItems() {
    return [
      SettingsItem(
        iconName: 'notifications',
        title: 'Push Notifications',
        subtitle: 'Shopping reminders and updates',
        hasSwitch: true,
        switchValue: _pushNotifications,
        onSwitchChanged: (value) {
          setState(() {
            _pushNotifications = value;
          });
          _showSuccessSnackBar(
              'Push notifications ${value ? 'enabled' : 'disabled'}');
        },
      ),
      SettingsItem(
        iconName: 'email',
        title: 'Email Notifications',
        subtitle: 'Weekly summaries and tips',
        hasSwitch: true,
        switchValue: _emailNotifications,
        onSwitchChanged: (value) {
          setState(() {
            _emailNotifications = value;
          });
          _showSuccessSnackBar(
              'Email notifications ${value ? 'enabled' : 'disabled'}');
        },
      ),
    ];
  }

  List<SettingsItem> _getPrivacyItems() {
    return [
      SettingsItem(
        iconName: 'cloud_sync',
        title: 'Data Sync',
        subtitle: 'Sync data across devices',
        hasSwitch: true,
        switchValue: _dataSync,
        onSwitchChanged: (value) {
          setState(() {
            _dataSync = value;
          });
          _showSuccessSnackBar('Data sync ${value ? 'enabled' : 'disabled'}');
        },
      ),
      SettingsItem(
        iconName: 'download',
        title: 'Export Data',
        subtitle: 'Download your shopping data',
        onTap: () => _showErrorSnackBar('Data export coming soon'),
      ),
      SettingsItem(
        iconName: 'delete_forever',
        title: 'Delete Account',
        subtitle: 'Permanently delete your account',
        iconColor: AppTheme.errorLight,
        iconBackgroundColor: AppTheme.errorLight.withValues(alpha: 0.1),
        onTap: () => _showDeleteAccountDialog(),
      ),
    ];
  }

  List<SettingsItem> _getSupportItems() {
    return [
      SettingsItem(
        iconName: 'help_center',
        title: 'Help Center',
        subtitle: 'FAQs and tutorials',
        onTap: () => _showErrorSnackBar('Help center coming soon'),
      ),
      SettingsItem(
        iconName: 'contact_support',
        title: 'Contact Support',
        subtitle: 'Get help from our team',
        onTap: () => _showErrorSnackBar('Contact support coming soon'),
      ),
      SettingsItem(
        iconName: 'info',
        title: 'App Version',
        trailingText: '1.2.0',
        onTap: () => _showErrorSnackBar('Version information displayed'),
      ),
      SettingsItem(
        iconName: 'dark_mode',
        title: 'Dark Mode',
        subtitle: 'Switch to dark theme',
        hasSwitch: true,
        switchValue: _darkModeEnabled,
        onSwitchChanged: (value) {
          setState(() {
            _darkModeEnabled = value;
          });
          _showSuccessSnackBar('Dark mode ${value ? 'enabled' : 'disabled'}');
        },
      ),
    ];
  }

  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Currency',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ...currencies.map((currency) => ListTile(
                  title: Text(currency),
                  trailing: _selectedCurrency == currency
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                    Navigator.pop(context);
                    _showSuccessSnackBar('Currency changed to $currency');
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Italian'];
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ...languages.map((language) => ListTile(
                  title: Text(language),
                  trailing: _selectedLanguage == language
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                    _showSuccessSnackBar('Language changed to $language');
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
                iconName: 'warning', color: AppTheme.errorLight, size: 24),
            SizedBox(width: 2.w),
            Text('Delete Account'),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your shopping lists and data will be permanently deleted.',
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
              _showErrorSnackBar('Account deletion cancelled');
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorLight),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
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
            ProfileHeaderWidget(
              userName: userData["name"] as String,
              userEmail: userData["email"] as String,
              profileImageUrl: userData["profileImage"] as String,
              isPremium: userData["isPremium"] as bool,
              onEditPressed: _navigateToEditProfile,
              onImageTap: _handleImageSelection,
            ),
            SizedBox(height: 2.h),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Profile'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        SettingsSectionWidget(
                          title: 'Account Settings',
                          items: _getAccountSettingsItems(),
                        ),
                        SettingsSectionWidget(
                          title: 'Shopping Preferences',
                          items: _getShoppingPreferencesItems(),
                        ),
                        SettingsSectionWidget(
                          title: 'Notifications',
                          items: _getNotificationItems(),
                        ),
                        SettingsSectionWidget(
                          title: 'Privacy',
                          items: _getPrivacyItems(),
                        ),
                        SettingsSectionWidget(
                          title: 'Support',
                          items: _getSupportItems(),
                        ),
                        LogoutButtonWidget(
                          onLogoutPressed: _handleLogout,
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
