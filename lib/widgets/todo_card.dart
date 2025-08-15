import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(String) onStatusChange;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final todoProvider = Get.find<TodoProvider>();

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textInverse,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(AppStyles.radius12),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.spacing12),
        decoration: AppStyles.cardDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppStyles.radius16),
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppStyles.spacing8),
                  _buildContent(),
                  const SizedBox(height: AppStyles.spacing12),
                  _buildFooter(todoProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.3);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            todo.title,
            style: AppStyles.heading3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildContent() {
    if (todo.description?.isNotEmpty == true) {
      return Text(
        todo.description!,
        style: AppStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFooter(TodoProvider todoProvider) {
    return Row(
      children: [
        _buildTimerSection(todoProvider),
        const Spacer(),
        _buildPriorityChip(),
        if (_isOverdue(todoProvider)) _buildOverdueIndicator(),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing8,
        vertical: AppStyles.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(todo.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radius8),
        border: Border.all(
          color: AppColors.getStatusColor(todo.status),
          width: 1,
        ),
      ),
      child: Text(
        todo.status.replaceAll('_', ' '),
        style: AppStyles.caption.copyWith(
          color: AppColors.getStatusColor(todo.status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimerSection(TodoProvider todoProvider) {
    return Obx(() {
      final isRunning = todoProvider.runningTimers.containsKey(todo.id);
      final currentElapsed =
          isRunning ? todoProvider.runningTimers[todo.id]! : todo.elapsedTime;
      final planned = todo.duration;
      final overdue = currentElapsed > planned && planned > 0;

      return Row(
        children: [
          Icon(
            isRunning ? Icons.timer : Icons.schedule,
            size: 16,
            color: overdue
                ? AppColors.error
                : (isRunning ? AppColors.inProgress : AppColors.textSecondary),
          ),
          const SizedBox(width: AppStyles.spacing4),
          Text(
            _formatTime(currentElapsed),
            style: AppStyles.bodySmall.copyWith(
              color: overdue
                  ? AppColors.error
                  : (isRunning
                      ? AppColors.inProgress
                      : AppColors.textSecondary),
              fontWeight: isRunning ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (planned > 0) ...[
            const SizedBox(width: AppStyles.spacing4),
            Text(
              '/ ${_formatTime(planned)}',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildPriorityChip() {
    if (todo.priority == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: AppStyles.spacing8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing6,
        vertical: AppStyles.spacing2,
      ),
      decoration: BoxDecoration(
        color: todo.priority == 1
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radius4),
      ),
      child: Text(
        todo.priority == 1 ? '!' : '!!',
        style: AppStyles.caption.copyWith(
          color: todo.priority == 1 ? AppColors.warning : AppColors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOverdueIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing6,
        vertical: AppStyles.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radius4),
      ),
      child: Text(
        'Overdue',
        style: AppStyles.caption.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _isOverdue(TodoProvider todoProvider) {
    final isRunning = todoProvider.runningTimers.containsKey(todo.id);
    final currentElapsed =
        isRunning ? todoProvider.runningTimers[todo.id]! : todo.elapsedTime;
    return todo.duration > 0 && currentElapsed > todo.duration;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
