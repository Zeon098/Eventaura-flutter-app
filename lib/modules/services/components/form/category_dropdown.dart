import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final List<Map<String, dynamic>> categories;
  final Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: 'Service Category',
          hintText: 'Select a category',
          labelStyle: TextStyle(color: AppTheme.textSecondaryColor),
          hintStyle: TextStyle(
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category['value'],
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  category['label'],
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }
}
