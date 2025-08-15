import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> initialize() async {
    await _createDatabase();
    await _insertSampleData();
  }

  Future<void> _createDatabase() async {
    await database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        duration INTEGER NOT NULL,
        elapsedTime INTEGER DEFAULT 0,
        startTime TEXT,
        endTime TEXT,
        createdDate TEXT NOT NULL,
        dueDate TEXT,
        priority INTEGER DEFAULT 0,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  // Insert a new todo
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  // Get all todos
  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Get todos by status
  Future<List<Todo>> getTodosByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Get todos by date
  Future<List<Todo>> getTodosByDate(DateTime date) async {
    final db = await database;
    final String dateStr = _formatDate(date);
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'DATE(createdDate) = ?',
      whereArgs: [dateStr],
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Get todo by id
  Future<Todo?> getTodoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  // Update todo
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      {
        'id': todo.id,
        'title': todo.title,
        'description': todo.description,
        'status': todo.status,
        'duration': todo.duration,
        'elapsedTime': todo.elapsedTime,
        'startTime': todo.startTime?.toIso8601String(),
        'endTime': todo.endTime?.toIso8601String(),
        'createdDate': todo.createdDate.toIso8601String(),
        'dueDate': todo.dueDate?.toIso8601String(),
        // REMOVE 'date': todo.date,
        'priority': todo.priority,
        'isCompleted': todo.isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete todo
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search todos by title
  Future<List<Todo>> searchTodos(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Get todos with running timers
  Future<List<Todo>> getRunningTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'status = ? AND startTime IS NOT NULL',
      whereArgs: ['IN_PROGRESS'],
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // Get completed todos count
  Future<int> getCompletedTodosCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM todos WHERE status = ?', ['DONE']);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total todos count
  Future<int> getTotalTodosCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM todos');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get todos statistics
  Future<Map<String, int>> getTodosStatistics() async {
    final db = await database;
    final todoCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM todos WHERE status = ?', ['TODO']);
    final inProgressCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM todos WHERE status = ?',
        ['IN_PROGRESS']);
    final doneCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM todos WHERE status = ?', ['DONE']);

    return {
      'TODO': Sqflite.firstIntValue(todoCount) ?? 0,
      'IN_PROGRESS': Sqflite.firstIntValue(inProgressCount) ?? 0,
      'DONE': Sqflite.firstIntValue(doneCount) ?? 0,
    };
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> _insertSampleData() async {
    final db = await database;

    // Sample todos for different dates
    final sampleTodos = [
      {
        'title': 'Wakeup',
        'description': 'Early Wakeup from bed',
        'status': 'DONE',
        'duration': 300,
        'elapsedTime': 300,
        'startTime': DateTime.now()
            .subtract(const Duration(days: 2, hours: 8))
            .toIso8601String(),
        'endTime': DateTime.now()
            .subtract(const Duration(days: 2, hours: 7, minutes: 55))
            .toIso8601String(),
        'createdDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'dueDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'priority': 1,
        'isCompleted': 1,
      },
      {
        'title': 'Morning Exercise',
        'description': '4 types of exercises',
        'status': 'DONE',
        'duration': 1800,
        'elapsedTime': 1800,
        'startTime': DateTime.now()
            .subtract(const Duration(days: 2, hours: 7))
            .toIso8601String(),
        'endTime': DateTime.now()
            .subtract(const Duration(days: 2, hours: 6, minutes: 30))
            .toIso8601String(),
        'createdDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'dueDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'priority': 2,
        'isCompleted': 1,
      },
      {
        'title': 'Meeting',
        'description': 'Zoom call',
        'status': 'DONE',
        'duration': 3600,
        'elapsedTime': 3600,
        'startTime': DateTime.now()
            .subtract(const Duration(days: 2, hours: 6))
            .toIso8601String(),
        'endTime': DateTime.now()
            .subtract(const Duration(days: 2, hours: 5))
            .toIso8601String(),
        'createdDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'dueDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'priority': 2,
        'isCompleted': 1,
      },
      {
        'title': 'Interviews',
        'description': 'Room 6-205',
        'status': 'IN_PROGRESS',
        'duration': 7200,
        'elapsedTime': 3600,
        'startTime': DateTime.now()
            .subtract(const Duration(days: 1, hours: 5))
            .toIso8601String(),
        'endTime': null,
        'createdDate':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'dueDate':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'priority': 2,
        'isCompleted': 0,
      },
      {
        'title': 'Breakfast',
        'description': 'Morning breakfast + soaked nuts + egg',
        'status': 'TODO',
        'duration': 1800,
        'elapsedTime': 0,
        'startTime': null,
        'endTime': null,
        'createdDate':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'dueDate':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'priority': 1,
        'isCompleted': 0,
      },
      {
        'title': 'Reading Books',
        'description': 'Read every day',
        'status': 'DONE',
        'duration': 1800,
        'elapsedTime': 1800,
        'startTime':
            DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'endTime': DateTime.now()
            .subtract(const Duration(hours: 2, minutes: 30))
            .toIso8601String(),
        'createdDate': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 1,
        'isCompleted': 1,
      },
      {
        'title': 'Painting',
        'description': 'Half an hour a day',
        'status': 'TODO',
        'duration': 1800,
        'elapsedTime': 0,
        'startTime': null,
        'endTime': null,
        'createdDate': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 1,
        'isCompleted': 0,
      },
      {
        'title': 'Save Money',
        'description': 'Five dollars a day',
        'status': 'TODO',
        'duration': 300,
        'elapsedTime': 0,
        'startTime': null,
        'endTime': null,
        'createdDate': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 2,
        'isCompleted': 0,
      },
    ];

    for (final todo in sampleTodos) {
      await db.insert('todos', todo);
    }
  }
}
