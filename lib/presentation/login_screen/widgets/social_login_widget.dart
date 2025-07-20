import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatefulWidget {
  final Function(String provider) onSocialLogin;
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    required this.onSocialLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget>
    with TickerProviderStateMixin {
  late AnimationController _googleController;
  late AnimationController _appleController;
  late Animation<double> _googleScaleAnimation;
  late Animation<double> _appleScaleAnimation;
  String? _loadingProvider;

  @override
  void initState() {
    super.initState();
    _googleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _appleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _googleScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _googleController,
      curve: Curves.easeInOut,
    ));

    _appleScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _appleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _googleController.dispose();
    _appleController.dispose();
    super.dispose();
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (widget.isLoading) return;

    setState(() {
      _loadingProvider = provider;
    });

    // Animate button press
    if (provider == 'google') {
      _googleController.forward().then((_) => _googleController.reverse());
    } else {
      _appleController.forward().then((_) => _appleController.reverse());
    }

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      widget.onSocialLogin(provider);
    } finally {
      if (mounted) {
        setState(() {
          _loadingProvider = null;
        });
      }
    }
  }

  Widget _buildSocialButton({
    required String provider,
    required String iconName,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required AnimationController controller,
    required Animation<double> scaleAnimation,
  }) {
    final isLoading = _loadingProvider == provider;

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 6.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed:
                  widget.isLoading ? null : () => _handleSocialLogin(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                side: BorderSide(color: borderColor, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: iconName,
                          color: textColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          label,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Google Login Button
        _buildSocialButton(
          provider: 'google',
          iconName: 'g_translate',
          label: 'Continue with Google',
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          textColor: AppTheme.lightTheme.colorScheme.onSurface,
          borderColor:
              AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          controller: _googleController,
          scaleAnimation: _googleScaleAnimation,
        ),

        SizedBox(height: 2.h),

        // Apple Login Button
        _buildSocialButton(
          provider: 'apple',
          iconName: 'apple',
          label: 'Continue with Apple',
          backgroundColor: AppTheme.lightTheme.colorScheme.onSurface,
          textColor: AppTheme.lightTheme.colorScheme.surface,
          borderColor: AppTheme.lightTheme.colorScheme.onSurface,
          controller: _appleController,
          scaleAnimation: _appleScaleAnimation,
        ),

        SizedBox(height: 3.h),

        // Sign Up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New user? ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
            ),
            TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/onboarding-flow');
                    },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sign Up',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
