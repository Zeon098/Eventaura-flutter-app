import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryMultiSelect extends GetView {
  final Set<String> selectedCategories;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<String> onToggle;
  final String title;

  const CategoryMultiSelect({
    super.key,
    required this.selectedCategories,
    required this.categories,
    required this.onToggle,
    this.title = 'Service Categories',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((category) {
              final value = category['value'] as String;
              final label = category['label'] as String;

              final selected = selectedCategories.contains(value);
              return FilterChip(
                selected: selected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                selectedColor: AppTheme.primaryColor,
                backgroundColor: AppTheme.surfaceColor,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: selected
                      ? AppTheme.primaryColor
                      : AppTheme.dividerColor,
                ),
                onSelected: (_) => onToggle(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick all categories that describe your service',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}
