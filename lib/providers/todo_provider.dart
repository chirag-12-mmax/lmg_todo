import 'dart:async';
import 'package:get/get.dart';
import '../models/todo_model.dart';
import '../data/database_helper.dart';

class TodoProvider extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Observable variables
  final RxList<Todo> _todos = <Todo>[].obs;
  final RxList<Todo> _filteredTodos = <Todo>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _currentFilter = 'All'.obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final RxList<Todo> filteredTodosRx = <Todo>[].obs;

  Timer? _timer;
  final RxMap<int, int> _runningTimers = <int, int>{}.obs;

  // Getters
  List<Todo> get todos => _todos;
  List<Todo> get filteredTodos => _filteredTodos;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get currentFilter => _currentFilter.value;
  var selectedDate = DateTime.now().obs;
  Map<int, int> get runningTimers => _runningTimers;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> initialize() async {
    await loadTodos();
    startTimerUpdates();
  }

  Future<void> loadTodos() async {
    _isLoading.value = true;
    try {
      final todos = await _databaseHelper.getAllTodos();
      _todos.assignAll(todos);
      _filteredTodos.assignAll(todos);
    } catch (e) {
      print('Error loading todos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final id = await _databaseHelper.insertTodo(todo);
      final newTodo = todo.copyWith(id: id);
      _todos.add(newTodo);
      _filteredTodos.add(newTodo);
      _applyFilters();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _databaseHelper.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        final filteredIndex = _filteredTodos.indexWhere((t) => t.id == todo.id);
        if (filteredIndex != -1) {
          _filteredTodos[filteredIndex] = todo;
        }
        _todos.refresh();
        _filteredTodos.refresh();
        _applyFilters();
      }
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _databaseHelper.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      _filteredTodos.removeWhere((todo) => todo.id == id);
      _runningTimers.remove(id);
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  void searchTodos(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void filterTodos(String filter) {
    _currentFilter.value = filter;
    _applyFilters();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate.value = date;
    // update();
    _applyFilters();
  }

  void _applyFilters() {
    List<Todo> filtered = List.from(_todos);

    // Apply status filter
    if (_currentFilter.value != 'All') {
      String status = _currentFilter.value == 'To Do'
          ? 'TODO'
          : _currentFilter.value == 'In Progress'
              ? 'IN_PROGRESS'
              : 'DONE';
      filtered = filtered.where((todo) => todo.status == status).toList();
    }

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((todo) =>
              todo.title
                  .toLowerCase()
                  .contains(_searchQuery.value.toLowerCase()) ||
              (todo.description
                      ?.toLowerCase()
                      .contains(_searchQuery.value.toLowerCase()) ??
                  false))
          .toList();
    }

    // Apply date filter
    filtered = filtered.where((todo) {
      if (todo.dueDate != null) {
        final dueDate = todo.dueDate!;
        final selectedDate = _selectedDate.value;
        return dueDate.year == selectedDate.year &&
            dueDate.month == selectedDate.month &&
            dueDate.day == selectedDate.day;
      }
      return true;
    }).toList();

    _filteredTodos.assignAll(filtered);
  }

  Future<void> startTimer(int todoId) async {
    final todo = _todos.firstWhere((t) => t.id == todoId);
    final updatedTodo = todo.copyWith(
      status: 'IN_PROGRESS',
      startTime: DateTime.now(),
    );
    await updateTodo(updatedTodo);
    _runningTimers[todoId] = todo.elapsedTime;
  }

  Future<void> pauseTimer(int todoId) async {
    final todo = _todos.firstWhere((t) => t.id == todoId);
    final elapsedTime = _runningTimers[todoId] ?? 0;
    final updatedTodo = todo.copyWith(
      elapsedTime: elapsedTime,
      startTime: null,
    );
    await updateTodo(updatedTodo);
    _runningTimers.remove(todoId);
  }

  Future<void> stopTimer(int todoId) async {
    final todoIndex = _todos.indexWhere((t) => t.id == todoId);
    if (todoIndex == -1) return;

    final todo = _todos[todoIndex];
    final currentElapsed = _runningTimers[todoId] ?? 0;

    final totalElapsed =
        (todo.elapsedTime + currentElapsed).clamp(0, todo.duration);

    final updatedTodo = todo.copyWith(
      status: 'DONE', // ✅ Always mark as done
      elapsedTime: totalElapsed,
      startTime: null,
      endTime: DateTime.now(),
    );

    await updateTodo(updatedTodo);
    _runningTimers.remove(todoId);
  }

    int getElapsed(int todoId) {
    if (runningTimers.containsKey(todoId)) {
      return runningTimers[todoId]!;
    }
    final todo = todos.firstWhereOrNull((t) => t.id == todoId);
    return todo?.elapsedTime ?? 0;
  }

  void startTimerUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _runningTimers.forEach((todoId, elapsedTime) {
        _runningTimers[todoId] = elapsedTime + 1;
      });
    });
  }

  void updateTodoStatus(int todoId, String status) async {
    final todo = _todos.firstWhere((t) => t.id == todoId);
    final updatedTodo = todo.copyWith(status: status);
    if (status == 'DONE') {
      updatedTodo.copyWith(
        endTime: DateTime.now(),
        elapsedTime: todo.duration,
      );
    }
    await updateTodo(updatedTodo);
  }

  List<Todo> getTodosByStatus(String status) {
    return _todos.where((todo) => todo.status == status).toList();
  }

  List<Todo> getTodosByDate(DateTime date) {
    return _todos.where((todo) {
      if (todo.dueDate != null) {
        final dueDate = todo.dueDate!;
        return dueDate.year == date.year &&
            dueDate.month == date.month &&
            dueDate.day == date.day;
      }
      return false;
    }).toList();
  }

  Map<String, int> getStatistics() {
    final total = _todos.length;
    final todo = _todos.where((t) => t.status == 'TODO').length;
    final inProgress = _todos.where((t) => t.status == 'IN_PROGRESS').length;
    final done = _todos.where((t) => t.status == 'DONE').length;

    return {
      'total': total,
      'todo': todo,
      'inProgress': inProgress,
      'done': done,
    };
  }
}
