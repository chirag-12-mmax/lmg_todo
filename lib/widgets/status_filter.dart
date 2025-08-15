import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class StatusFilter extends StatelessWidget {
  final Function(String) onFilterChanged;

  const StatusFilter({super.key, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Get.find<TodoProvider>();

    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                'All',
                'All',
                todoProvider.currentFilter == 'All',
                AppColors.primary,
                () => onFilterChanged('All'),
              ),
              const SizedBox(width: AppStyles.spacing8),
              _buildFilterChip(
                context,
                'To Do',
                'To Do',
                todoProvider.currentFilter == 'To Do',
                AppColors.todo,
                () => onFilterChanged('To Do'),
              ),
              const SizedBox(width: AppStyles.spacing8),
              _buildFilterChip(
                context,
                'In Progress',
                'In Progress',
                todoProvider.currentFilter == 'In Progress',
                AppColors.inProgress,
                () => onFilterChanged('In Progress'),
              ),
              const SizedBox(width: AppStyles.spacing8),
              _buildFilterChip(
                context,
                'Done',
                'Done',
                todoProvider.currentFilter == 'Done',
                AppColors.done,
                () => onFilterChanged('Done'),
              ),
            ],
          ),
        )).animate().fadeIn().slideY(begin: -0.2, delay: 200.ms);
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.spacing16,
          vertical: AppStyles.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyles.radius20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    )
        .animate(target: isSelected ? 1 : 0)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0))
        .then()
        .shimmer(duration: 600.ms, color: color.withOpacity(0.3));
  }
}
