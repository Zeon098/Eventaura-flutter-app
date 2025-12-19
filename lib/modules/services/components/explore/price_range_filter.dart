import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PriceRangeFilter extends StatelessWidget {
  final ValueNotifier<RangeValues> priceRange;
  final VoidCallback onChanged;

  const PriceRangeFilter({
    super.key,
    required this.priceRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '💰 Price Range',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: priceRange,
                builder: (_, RangeValues range, __) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.accent.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'PKR ${range.start.toStringAsFixed(0)} - ${range.end.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: priceRange,
            builder: (_, RangeValues range, __) {
              return SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.2),
                  thumbColor: AppTheme.primaryColor,
                  overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: RangeSlider(
                  values: range,
                  min: 0,
                  max: 100000,
                  divisions: 20,
                  labels: RangeLabels(
                    'PKR ${range.start.toStringAsFixed(0)}',
                    'PKR ${range.end.toStringAsFixed(0)}',
                  ),
                  onChanged: (v) {
                    priceRange.value = v;
                    onChanged();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
