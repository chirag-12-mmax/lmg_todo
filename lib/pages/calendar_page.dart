import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lmg_todo_app/pages/todo_details_page.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import 'todo_list_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late TodoProvider _todoProvider;
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _todoProvider = Get.find<TodoProvider>();
    _focusedMonth = DateTime.now();
    _selectedDate = _todoProvider.selectedDate.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync selected date when returning to this page
    setState(() {
      _selectedDate = _todoProvider.selectedDate.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${_getMonthName(_focusedMonth.month)}, ${_focusedMonth.year}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month - 1);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.today, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime.now();
                _selectedDate = DateTime.now();
                _todoProvider.setSelectedDate(DateTime.now());
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month + 1);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          Expanded(
            child: _buildCalendarGrid(),
          ),
          Expanded(
            child: _buildSelectedDateTasks(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map((day) => Text(
                  day,
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ))
            .toList(),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysFromPreviousMonth = firstDayWeekday - 1;

    final totalDays = daysInMonth + daysFromPreviousMonth;
    final weeks = (totalDays / 7).ceil();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacing16),
      itemCount: weeks,
      itemBuilder: (context, weekIndex) {
        return _buildWeekRow(weekIndex, daysInMonth, daysFromPreviousMonth);
      },
    );
  }

  Widget _buildWeekRow(
      int weekIndex, int daysInMonth, int daysFromPreviousMonth) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (dayIndex) {
          final dayNumber =
              weekIndex * 7 + dayIndex + 1 - daysFromPreviousMonth;
          final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
          final date = isCurrentMonth
              ? DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber)
              : null;

          return _buildDayCell(date, dayNumber, isCurrentMonth);
        }),
      ),
    ).animate().fadeIn(delay: (weekIndex * 100).ms, duration: 400.ms);
  }

  Widget _buildDayCell(DateTime? date, int dayNumber, bool isCurrentMonth) {
    if (!isCurrentMonth || date == null) {
      return Container(
        width: 45,
        height: 45,
        margin: const EdgeInsets.all(2),
      );
    }

    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final todosForDay = _todoProvider.getTodosByDate(date);
    final completedTodos =
        todosForDay.where((todo) => todo.status == 'DONE').length;
    final hasTodos = todosForDay.isNotEmpty;
    final hasCompletedTodos = completedTodos > 0;
    final allCompleted = hasTodos && completedTodos == todosForDay.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _todoProvider.setSelectedDate(date);
        });
      },
      child: Container(
        width: 45,
        height: 45,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.secondary.withOpacity(0.2)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyles.radius8),
          border:
              isToday ? Border.all(color: AppColors.secondary, width: 2) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: AppStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            // Todo indicators
            if (hasTodos) ...[
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: allCompleted
                        ? AppColors.done
                        : hasCompletedTodos
                            ? AppColors.todo
                            : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            // Today indicator
            if (isToday && !isSelected)
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateTasks() {
    return Obx(() {
      final todosForSelectedDate = _todoProvider.todos
          .where((todo) =>
              _isSameDay(todo.dueDate ?? DateTime.now(), _selectedDate))
          .toList();

      if (todosForSelectedDate.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(AppStyles.spacing20),
          child: Text(
            'No tasks for ${_getFormattedDate(_selectedDate)}',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(AppStyles.spacing16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppStyles.radius20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getFormattedDate(_selectedDate),
                    style: AppStyles.heading3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${todosForSelectedDate.length} tasks',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.spacing12),
              ...todosForSelectedDate.map((todo) => _buildTaskItem(todo)),
              const SizedBox(height: AppStyles.spacing16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => const TodoListPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverse,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppStyles.spacing12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.radius12),
                    ),
                  ),
                  child: const Text('View All Tasks'),
                ),
              ),
            ],
          ),
        ),
      );
    }).animate().slideY(begin: 0.5, end: 0, duration: 400.ms);
  }

  Widget _buildTaskItem(Todo todo) {
    return GestureDetector(
      onTap: () {
        Get.to(() => TodoDetailsPage(todo: todo));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.spacing8),
        padding: const EdgeInsets.all(AppStyles.spacing12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppStyles.radius8),
          border: Border.all(
            color: todo.status == 'DONE' ? AppColors.done : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(todo.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppStyles.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: todo.status == 'DONE'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (todo.description != null) ...[
                    const SizedBox(height: AppStyles.spacing4),
                    Text(
                      todo.description!,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _getStatusText(todo.status),
              style: AppStyles.caption.copyWith(
                color: _getStatusColor(todo.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'TODO':
        return AppColors.todo;
      case 'IN_PROGRESS':
        return AppColors.inProgress;
      case 'DONE':
        return AppColors.done;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'TODO':
        return 'To Do';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'DONE':
        return 'Done';
      default:
        return status;
    }
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == today) {
      return 'Today';
    } else if (selectedDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }
}
