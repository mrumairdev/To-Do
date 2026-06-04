import 'package:flutter/foundation.dart';

import '../data/task_item.dart';
import '../data/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository) {
    _tasks = _repository.getAll();
  }

  final TaskRepository _repository;
  List<TaskItem> _tasks = <TaskItem>[];
  String _searchQuery = '';
  String? _selectedCategory;

  static const List<String> _defaultCategories = <String>[
    'Work',
    'Personal',
    'Home',
    'Health',
    'Study',
  ];

  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  List<TaskItem> get visibleTasks {
    final query = _searchQuery.trim().toLowerCase();
    final category = _selectedCategory;

    final filtered = _tasks
        .where((task) {
          final matchesQuery =
              query.isEmpty || task.title.toLowerCase().contains(query);
          final matchesCategory = category == null || task.category == category;
          return matchesQuery && matchesCategory;
        })
        .toList(growable: false);

    filtered.sort(_compareTasks);
    return filtered;
  }

  List<String> get categories {
    final values = <String>{
      ..._defaultCategories,
      ..._tasks
          .map((task) => task.category)
          .where((category) => category.trim().isNotEmpty),
    };

    final result = values.toList()..sort();
    return result;
  }

  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  int get activeCount => _tasks.where((task) => !task.isCompleted).length;
  int get completedCount => _tasks.where((task) => task.isCompleted).length;

  void setSearchQuery(String value) {
    if (_searchQuery == value) {
      return;
    }

    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    if (_selectedCategory == value) {
      return;
    }

    _selectedCategory = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  Future<void> saveTask({TaskItem? existing, required TaskDraft draft}) async {
    final normalizedTitle = draft.title.trim();
    final normalizedDetails = draft.details.trim();
    final normalizedCategory = draft.category.trim().isEmpty
        ? 'General'
        : draft.category.trim();
    final now = DateTime.now();

    final task = existing == null
        ? TaskItem.create(
            title: normalizedTitle,
            details: normalizedDetails,
            category: normalizedCategory,
          )
        : existing.copyWith(
            title: normalizedTitle,
            details: normalizedDetails,
            category: normalizedCategory,
            updatedAt: now,
          );

    await _repository.upsert(task);
    _replaceTask(task);
  }

  Future<void> toggleTask(TaskItem task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _repository.upsert(updated);
    _replaceTask(updated);
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Future<void> clearCompleted() async {
    await _repository.clearCompleted();
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
  }

  void _replaceTask(TaskItem task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      _tasks = <TaskItem>[task, ..._tasks];
    } else {
      _tasks[index] = task;
    }
    _tasks.sort(_compareTasks);
    notifyListeners();
  }

  int _compareTasks(TaskItem left, TaskItem right) {
    if (left.isCompleted != right.isCompleted) {
      return left.isCompleted ? 1 : -1;
    }

    return right.updatedAt.compareTo(left.updatedAt);
  }
}
