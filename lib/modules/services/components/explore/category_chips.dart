import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final label = categories[index];
          final selected =
              (label == 'All' && selectedCategory.isEmpty) ||
              (selectedCategory == label);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: FilterChip(
              label: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textPrimaryColor,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              selected: selected,
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: selected ? AppTheme.primaryColor : AppTheme.dividerColor,
                width: selected ? 2 : 1,
              ),
              elevation: selected ? 4 : 0,
              shadowColor: AppTheme.primaryColor.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onSelected: (_) => onCategorySelected(label),
            ),
          );
        },
      ),
    );
  }
}
