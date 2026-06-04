import 'package:hive/hive.dart';

import 'task_item.dart';
import 'task_repository.dart';

class HiveTaskRepository implements TaskRepository {
  HiveTaskRepository(this._box);

  final Box<TaskItem> _box;

  @override
  List<TaskItem> getAll() {
    final tasks = _box.values.toList(growable: false);
    tasks.sort(_sortTasks);
    return tasks;
  }

  @override
  Future<void> upsert(TaskItem task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearCompleted() async {
    final completedKeys = _box.values
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList(growable: false);

    await _box.deleteAll(completedKeys);
  }

  int _sortTasks(TaskItem left, TaskItem right) {
    if (left.isCompleted != right.isCompleted) {
      return left.isCompleted ? 1 : -1;
    }

    return right.updatedAt.compareTo(left.updatedAt);
  }
}
