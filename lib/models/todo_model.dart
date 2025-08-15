class Todo {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final int duration; // in seconds
  final int elapsedTime; // in seconds
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdDate;
  final DateTime? dueDate;
  final int priority;
  final bool isCompleted;
    final DateTime date; 


  Todo({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.duration,
    this.elapsedTime = 0,
    this.startTime,
        required this.date, 

    this.endTime,
    required this.createdDate,
    this.dueDate,
    this.priority = 0,
    this.isCompleted = false,
  });

  // Create a copy of the todo with updated values
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    int? duration,
    int? elapsedTime,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdDate,
    DateTime? dueDate,
    int? priority,
    bool? isCompleted,
    DateTime? date,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert todo to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'duration': duration,
      'elapsedTime': elapsedTime,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'date': date.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Create todo from map (from database)
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      status: map['status'],
      duration: map['duration'],
      elapsedTime: map['elapsedTime'] ?? 0,
      startTime:
          map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      createdDate: DateTime.parse(map['createdDate']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: map['priority'] ?? 0,
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Get formatted duration string
  String get formattedDuration {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get formatted elapsed time string
  String get formattedElapsedTime {
    int minutes = elapsedTime ~/ 60;
    int seconds = elapsedTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get remaining time
  int get remainingTime {
    return duration - elapsedTime;
  }

  // Get formatted remaining time string
  String get formattedRemainingTime {
    int remaining = remainingTime;
    if (remaining < 0) remaining = 0;
    int minutes = remaining ~/ 60;
    int seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Check if timer is running
  bool get isRunning {
    return status == 'IN_PROGRESS' && startTime != null && endTime == null;
  }

  // Check if timer is paused
  bool get isPaused {
    return status == 'IN_PROGRESS' && startTime != null && endTime != null;
  }

  // Check if timer is completed
  bool get isTimerCompleted {
    return elapsedTime >= duration;
  }

  // Get progress percentage
  double get progressPercentage {
    if (duration == 0) return 0.0;
    return (elapsedTime / duration).clamp(0.0, 1.0);
  }

  // Get status display text
  String get statusDisplayText {
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

  // Get priority display text
  String get priorityDisplayText {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Low';
    }
  }

  // Get formatted created date
  String get formattedCreatedDate {
    return '${createdDate.day}/${createdDate.month}/${createdDate.year}';
  }

  // Get formatted due date
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  // Check if todo is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != 'DONE';
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, status: $status, duration: $duration, elapsedTime: $elapsedTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
