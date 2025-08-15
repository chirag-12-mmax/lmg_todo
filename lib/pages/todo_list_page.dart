import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lmg_todo_app/widgets/calender.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../widgets/search_bar.dart';
import '../widgets/status_filter.dart';
import '../widgets/add_todo_bottom_sheet.dart';
import 'todo_details_page.dart';
import 'calendar_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late TodoProvider _todoProvider;

  /// Store paused elapsed durations for each todo
  final Map<int, Duration> _pausedElapsed = {};

  /// Store start times when a todo is running
  final Map<int, DateTime> _runningSince = {};

  /// Store timers for running tasks
  final Map<int, Timer> _timers = {};

  @override
  void initState() {
    super.initState();
    _todoProvider = Get.find<TodoProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLiveTimers();
    });
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  /// Store elapsed time in seconds directly
  final Map<int, Duration> _elapsedMap = {};

  /// Store timers for running tasks

  void _initLiveTimers() {
    for (final todo in _todoProvider.filteredTodos) {
      if (todo.id != null) {
        _elapsedMap[todo.id!] = Duration(seconds: todo.elapsedTime ?? 0);
      }
    }

    // Start timers for todos already in progress
    for (final todo in _todoProvider.filteredTodos) {
      if (todo.status == 'IN_PROGRESS') {
        _startLiveTimer(todo);
      }
    }

    // Listen for changes in the list
    ever<List<Todo>>(_todoProvider.filteredTodosRx, (todos) {
      final runningIds = todos
          .where((t) => t.status == 'IN_PROGRESS')
          .map((t) => t.id)
          .whereType<int>()
          .toSet();

      final existingIds = _timers.keys.toSet();

      // Stop timers for tasks no longer running
      for (final id in existingIds.difference(runningIds)) {
        _stopLiveTimer(id);
      }

      // Start timers for new running tasks
      for (final todo in todos) {
        if (todo.id != null && !_elapsedMap.containsKey(todo.id)) {
          _elapsedMap[todo.id!] = Duration(seconds: todo.elapsedTime ?? 0);
        }
        if (todo.status == 'IN_PROGRESS' && !_timers.containsKey(todo.id)) {
          _startLiveTimer(todo);
        }
      }
    });
  }

  void _startLiveTimer(Todo todo) {
    if (todo.id == null) return;
    final id = todo.id!;

    _timers[id]?.cancel(); // cancel old timer if any

    _timers[id] = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedMap[id] =
            (_elapsedMap[id] ?? Duration.zero) + const Duration(seconds: 1);
      });

      // Optional: persist to DB so it's saved even if app closes
      // _todoProvider.updateElapsedTime(id, _elapsedMap[id]!.inSeconds);
    });
  }

  void _stopLiveTimer(int id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  Duration _getElapsed(int id) {
    return _elapsedMap[id] ?? Duration.zero;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDateSelector(),
            _buildSearchAndFilter(),
            Expanded(
              child: Obx(() => _buildTimelineView()),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateString =
        '${now.day} ${_getDayAbbreviation(now.weekday)} ${_getMonthAbbreviation(now.month)} ${now.year}';

    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateString,
              style: AppStyles.heading1.copyWith(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.spacing16,
              vertical: AppStyles.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppStyles.radius20),
            ),
            child: Text(
              'Today',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppStyles.spacing12),
          IconButton(
            onPressed: () => Get.to(() => const CalendarPage()),
            icon: Container(
              padding: const EdgeInsets.all(AppStyles.spacing8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppStyles.radius8),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: AppColors.textInverse,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildDateSelector() {
    return Obx(
      () => HorizontalCalendar(
        selectedDate: _todoProvider.selectedDate.value,
        onDateSelected: (date) => _todoProvider.setSelectedDate(date),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing16),
      child: Column(
        children: [
          CustomSearchBar(
            onChanged: (query) => _todoProvider.searchTodos(query),
          ),
          const SizedBox(height: AppStyles.spacing12),
          StatusFilter(
            onFilterChanged: (filter) => _todoProvider.filterTodos(filter),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: -0.2, end: 0);
  }

  Widget _buildTimelineView() {
    if (_todoProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_todoProvider.filteredTodos.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppStyles.spacing16),
        itemCount: _todoProvider.filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = _todoProvider.filteredTodos[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: 600.ms,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildTimelineItem(todo, index),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDurationReadable(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final parts = <String>[];

    if (hours > 0) {
      parts.add('$hours hr${hours > 1 ? 's' : ''}');
    }
    if (minutes > 0) {
      parts.add('$minutes min${minutes > 1 ? 's' : ''}');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds sec${seconds > 1 ? 's' : ''}');
    }

    return parts.join(' ');
  }

  Widget _buildTimelineItem(Todo todo, int index) {
    final timeString = _formatTime(todo.createdDate);
    final cardColor = AppColors.getStatusColor(todo.status).withOpacity(0.18);
    int time = todo.elapsedTime ?? 0;

    final isRunning = _todoProvider.runningTimers.containsKey(todo.id);
    final currentElapsed =
        isRunning ? _todoProvider.runningTimers[todo.id]! : todo.elapsedTime;

    //  _getElapsed(todo.id!);

    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacing16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppStyles.spacing16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(AppStyles.radius12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.getStatusColor(todo.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppStyles.radius8),
                    ),
                    child: Icon(
                      _getTaskIcon(todo.title),
                      color: AppColors.getStatusColor(todo.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: AppStyles.heading3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppStyles.spacing4),
                        Text(
                          todo.description ?? 'No description',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppStyles.spacing4),
                        if (todo.status == 'IN_PROGRESS')
                          Text(
                            isRunning
                                ? "Running: ${_formatDurationReadable(Duration(seconds: currentElapsed))}"
                                : "Stop: ${_formatDurationReadable(Duration(seconds: todo.elapsedTime ?? 0))}",
                            style: AppStyles.caption.copyWith(
                              color: AppColors.getStatusColor(todo.status),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            timeString,
                            style: AppStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _showTaskOptions(todo),
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.textPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _navigateToDetails(todo),
                          icon: const Icon(
                            Icons.add,
                            color: AppColors.textInverse,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.schedule,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppStyles.spacing16),
          Text(
            'No tasks for today',
            style: AppStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppStyles.spacing8),
          Text(
            'Add a new task to get started',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 800.ms);
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddTodoSheet,
      backgroundColor: AppColors.textPrimary,
      foregroundColor: AppColors.textInverse,
      child: const Icon(Icons.add),
    ).animate().scale(delay: 600.ms, duration: 400.ms);
  }

  void _showAddTodoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTodoBottomSheet(),
    );
  }

  void _navigateToDetails(Todo todo) {
    Get.to(() => TodoDetailsPage(todo: todo));
  }

  void _showTaskOptions(Todo todo) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppStyles.spacing20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppStyles.radius20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Task'),
              onTap: () {
                Get.back();
                _editTask(todo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Task'),
              onTap: () {
                Get.back();
                _deleteTodo(todo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTodoBottomSheet(todo: todo),
    );
  }

  void _deleteTodo(Todo todo) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _todoProvider.deleteTodo(todo.id!);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getTaskIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('wake') || lowerTitle.contains('bed')) {
      return Icons.bedtime;
    } else if (lowerTitle.contains('exercise') ||
        lowerTitle.contains('workout')) {
      return Icons.fitness_center;
    } else if (lowerTitle.contains('meeting') || lowerTitle.contains('call')) {
      return Icons.video_call;
    } else if (lowerTitle.contains('interview')) {
      return Icons.people;
    } else if (lowerTitle.contains('breakfast') ||
        lowerTitle.contains('food')) {
      return Icons.restaurant;
    } else if (lowerTitle.contains('read') || lowerTitle.contains('book')) {
      return Icons.book;
    } else if (lowerTitle.contains('paint')) {
      return Icons.palette;
    } else {
      return Icons.task_alt;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
