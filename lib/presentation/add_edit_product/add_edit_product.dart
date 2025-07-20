import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/barcode_scanner_widget.dart';
import './widgets/product_form_widget.dart';
import './widgets/product_suggestions_widget.dart';
import './widgets/recent_products_widget.dart';

class AddEditProduct extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddEditProduct({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<AddEditProduct> createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  bool _showScanner = false;
  bool _showSuggestions = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();

    // Initialize search controller if editing
    if (widget.product != null) {
      _searchController.text = widget.product!['name'] ?? '';
    }

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _showSuggestions = _searchQuery.isNotEmpty;
    });
  }

  void _onProductSaved(Map<String, dynamic> product) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(product);
  }

  void _onCancel() {
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _showBarcodeScanner() {
    setState(() {
      _showScanner = true;
    });
  }

  void _hideBarcodeScanner() {
    setState(() {
      _showScanner = false;
    });
  }

  void _onBarcodeScanned(String barcode) {
    _hideBarcodeScanner();

    // Mock product data based on barcode
    final mockProduct = {
      'name': 'Product ${barcode.substring(0, 4)}',
      'category': 'Groceries',
      'price':
          '${(double.parse(barcode.substring(0, 2)) / 10 + 5).toStringAsFixed(2)}',
      'barcode': barcode,
    };

    _onSuggestionSelected(mockProduct);
  }

  void _onRecentProductSelected(Map<String, dynamic> product) {
    _searchController.text = product['name'] ?? '';
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) {
    _searchController.text = suggestion['name'] ?? '';
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: GestureDetector(
        onTap: () => _onCancel(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Main Modal
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap through
                      child: Container(
                        height: 85.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildHeader(),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSearchSection(),
                                    if (_showSuggestions) ...[
                                      ProductSuggestionsWidget(
                                        searchQuery: _searchQuery,
                                        onSuggestionSelected:
                                            _onSuggestionSelected,
                                      ),
                                      SizedBox(height: 3.h),
                                    ],
                                    if (!_showSuggestions) ...[
                                      RecentProductsWidget(
                                        onProductSelected:
                                            _onRecentProductSelected,
                                      ),
                                      SizedBox(height: 3.h),
                                    ],
                                    ProductFormWidget(
                                      product: widget.product != null
                                          ? {
                                              ...widget.product!,
                                              'name': _searchController
                                                      .text.isNotEmpty
                                                  ? _searchController.text
                                                  : widget.product!['name'],
                                            }
                                          : _searchController.text.isNotEmpty
                                              ? {'name': _searchController.text}
                                              : null,
                                      onSave: _onProductSaved,
                                      onCancel: _onCancel,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Barcode Scanner Overlay
              if (_showScanner)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.8),
                    child: BarcodeScannerWidget(
                      onBarcodeScanned: _onBarcodeScanned,
                      onClose: _hideBarcodeScanner,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            TextButton(
              onPressed: _onCancel,
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            Expanded(
              child: Text(
                widget.product != null ? 'Edit Product' : 'Add Product',
                style: AppTheme.lightTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),

            // Barcode Scanner Button
            IconButton(
              onPressed: _showBarcodeScanner,
              icon: CustomIconWidget(
                iconName: 'qr_code_scanner',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              tooltip: 'Scan Barcode',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Name',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search or enter product name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _showSuggestions = false;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  )
                : null,
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            _onSearchChanged();
          },
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
