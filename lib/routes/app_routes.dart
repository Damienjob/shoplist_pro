import 'package:flutter/material.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/shopping_lists_dashboard/shopping_lists_dashboard.dart';
import '../presentation/add_edit_product/add_edit_product.dart';
import '../presentation/shopping_list_detail/shopping_list_detail.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String onboardingFlow = '/onboarding-flow';
  static const String userProfile = '/user-profile';
  static const String loginScreen = '/login-screen';
  static const String shoppingListsDashboard = '/shopping-lists-dashboard';
  static const String addEditProduct = '/add-edit-product';
  static const String shoppingListDetail = '/shopping-list-detail';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingFlow(),
    onboardingFlow: (context) => const OnboardingFlow(),
    userProfile: (context) => UserProfile(),
    loginScreen: (context) => const LoginScreen(),
    shoppingListsDashboard: (context) => const ShoppingListsDashboard(),
    addEditProduct: (context) => const AddEditProduct(),
    shoppingListDetail: (context) => const ShoppingListDetail(),
    // TODO: Add your other routes here
  };
}
