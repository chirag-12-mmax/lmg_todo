import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../widgets/add_todo_bottom_sheet.dart';

class TodoDetailsPage extends StatefulWidget {
  final Todo todo;

  const TodoDetailsPage({super.key, required this.todo});

  @override
  State<TodoDetailsPage> createState() => _TodoDetailsPageState();
}

class _TodoDetailsPageState extends State<TodoDetailsPage> {
  late TodoProvider _todoProvider;

  @override
  void initState() {
    super.initState();
    _todoProvider = Get.find<TodoProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: _editTodo,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodoInfo(),
            const SizedBox(height: AppStyles.spacing24),
            _buildTimerSection(),
            const SizedBox(height: AppStyles.spacing24),
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoInfo() {
    return GetX<TodoProvider>(builder: (todoProvider) {
      final todo =
          todoProvider.todos.firstWhereOrNull((t) => t.id == widget.todo.id) ??
              widget.todo;

      return Container(
        padding: const EdgeInsets.all(AppStyles.spacing20),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: AppStyles.heading2,
                  ),
                ),
                _buildStatusChip(todo.status),
              ],
            ),
            if (todo.description?.isNotEmpty == true) ...[
              const SizedBox(height: AppStyles.spacing12),
              Text(
                todo.description!,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppStyles.spacing16),
            Row(
              children: [
                _buildPriorityChip(todo),
                if (todo.isOverdue) ...[
                  const SizedBox(width: AppStyles.spacing8),
                  _buildOverdueChip(),
                ],
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
    });
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timer', style: AppStyles.heading3),
          const SizedBox(height: AppStyles.spacing16),
          GetX<TodoProvider>(builder: (todoProvider) {
            final todo = todoProvider.todos
                    .firstWhereOrNull((t) => t.id == widget.todo.id) ??
                widget.todo;
            final isRunning = todoProvider.runningTimers.containsKey(todo.id);
            final currentElapsed = isRunning
                ? todoProvider.runningTimers[todo.id]!
                : todo.elapsedTime;

            // Mark done if elapsed >= duration
            if (todo.status != 'DONE' &&
                currentElapsed >= todo.duration &&
                todo.duration > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                todoProvider.updateTodo(
                  todo.copyWith(
                    status: 'DONE',
                    elapsedTime: todo.duration,
                  ),
                );
              });
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacing20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppStyles.radius16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        formatDuration(currentElapsed),
                        style: AppStyles.heading1.copyWith(
                          color: AppColors.textInverse,
                          fontSize: 48,
                        ),
                      ),
                      const SizedBox(height: AppStyles.spacing8),
                      Text(
                        '${formatDuration(currentElapsed)} / ${formatDuration(todo.duration)}',
                        style: AppStyles.bodyLarge.copyWith(
                          color: AppColors.textInverse.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.spacing16),
                LinearProgressIndicator(
                  value: todo.duration > 0
                      ? (currentElapsed / todo.duration).clamp(0.0, 1.0)
                      : 0.0,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
                const SizedBox(height: AppStyles.spacing20),
                if (todo.status != 'DONE')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.play_arrow,
                        label: 'Start',
                        color: AppColors.secondary,
                        onPressed: isRunning ? null : _startTimer,
                      ),
                      _buildControlButton(
                        icon: Icons.pause,
                        label: 'Pause',
                        color: AppColors.warning,
                        onPressed: isRunning ? _pauseTimer : null,
                      ),
                      _buildControlButton(
                        icon: Icons.stop,
                        label: 'Stop',
                        color: AppColors.error,
                        onPressed: _stopTimer,
                      ),
                    ],
                  ),
              ],
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: -0.2, end: 0);
  }

  Widget _buildDetailsSection() {
    return GetX<TodoProvider>(builder: (todoProvider) {
      final todo =
          todoProvider.todos.firstWhereOrNull((t) => t.id == widget.todo.id) ??
              widget.todo;

      return Container(
        padding: const EdgeInsets.all(AppStyles.spacing20),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: AppStyles.heading3),
            const SizedBox(height: AppStyles.spacing16),
            _buildDetailItem('Created', todo.formattedCreatedDate),
            _buildDetailItem('Due Date', todo.formattedDueDate),
            _buildDetailItem('Duration', todo.formattedDuration),
            _buildDetailItem('Elapsed', todo.formattedElapsedTime),
            _buildDetailItem('Remaining', todo.formattedRemainingTime),
            _buildDetailItem(
                'Progress', '${(todo.progressPercentage * 100).toInt()}%'),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 400.ms, duration: 600.ms)
          .slideY(begin: -0.2, end: 0);
    });
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing12,
        vertical: AppStyles.spacing6,
      ),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radius8),
        border: Border.all(
          color: AppColors.getStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: AppStyles.bodySmall.copyWith(
          color: AppColors.getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(Todo todo) {
    if (todo.priority == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing8,
        vertical: AppStyles.spacing4,
      ),
      decoration: BoxDecoration(
        color: todo.priority == 1
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radius6),
      ),
      child: Text(
        todo.priority == 1 ? 'Low Priority' : 'High Priority',
        style: AppStyles.caption.copyWith(
          color: todo.priority == 1 ? AppColors.warning : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOverdueChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing8,
        vertical: AppStyles.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppStyles.radius6),
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

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: onPressed != null ? color : AppColors.border,
            borderRadius: BorderRadius.circular(AppStyles.radius12),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: onPressed != null
                  ? AppColors.textInverse
                  : AppColors.textTertiary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: AppStyles.spacing8),
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            color: onPressed != null
                ? AppColors.textPrimary
                : AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.spacing12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(': ',
              style: AppStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startTimer() => _todoProvider.startTimer(widget.todo.id!);
  void _pauseTimer() => _todoProvider.pauseTimer(widget.todo.id!);

  void _stopTimer() {
    _todoProvider.stopTimer(widget.todo.id!);
  }

  void _editTodo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTodoBottomSheet(todo: widget.todo),
    );
  }
}
