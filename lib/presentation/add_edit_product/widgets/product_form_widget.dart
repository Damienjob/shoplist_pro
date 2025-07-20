import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductFormWidget extends StatefulWidget {
  final Map<String, dynamic>? product;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const ProductFormWidget({
    Key? key,
    this.product,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ProductFormWidget> createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Groceries';
  int _quantity = 1;
  bool _isLoading = false;

  final List<String> _categories = [
    'Groceries',
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Health & Beauty',
    'Sports & Outdoors',
    'Books & Media',
    'Toys & Games',
    'Automotive',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _priceController.text =
          widget.product!['price']?.toString().replaceAll('\$', '') ?? '';
      _selectedCategory = widget.product!['category'] ?? 'Groceries';
      _quantity = widget.product!['quantity'] ?? 1;
      _notesController.text = widget.product!['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        double.tryParse(_priceController.text.trim()) != null;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
    HapticFeedback.lightImpact();
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _saveProduct() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate save delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final product = {
      'id': widget.product?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'price':
          '\$${double.parse(_priceController.text.trim()).toStringAsFixed(2)}',
      'category': _selectedCategory,
      'quantity': _quantity,
      'notes': _notesController.text.trim(),
      'dateAdded':
          widget.product?['dateAdded'] ?? DateTime.now().toIso8601String(),
      'dateModified': DateTime.now().toIso8601String(),
    };

    setState(() {
      _isLoading = false;
    });

    HapticFeedback.mediumImpact();
    widget.onSave(product);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name Field
          Text(
            'Product Name',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter product name',
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Product name is required';
              }
              return null;
            },
          ),

          SizedBox(height: 3.h),

          // Category Selector
          Text(
            'Category',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              border:
                  Border.all(color: AppTheme.lightTheme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Price and Quantity Row
          Row(
            children: [
              // Price Field
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixText: '\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),

              // Quantity Controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _decrementQuantity,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              child: Container(
                                height: double.infinity,
                                child: CustomIconWidget(
                                  iconName: 'remove',
                                  color: _quantity > 1
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                _quantity.toString(),
                                style:
                                    AppTheme.lightTheme.textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: _incrementQuantity,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              child: Container(
                                height: double.infinity,
                                child: CustomIconWidget(
                                  iconName: 'add',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Notes Field
          Text(
            'Notes (Optional)',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Add any additional notes...',
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),

          SizedBox(height: 4.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isFormValid && !_isLoading ? _saveProduct : null,
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      widget.product != null ? 'Update Product' : 'Add Product',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
