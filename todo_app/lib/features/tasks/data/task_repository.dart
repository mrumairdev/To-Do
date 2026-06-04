import 'task_item.dart';

abstract class TaskRepository {
  List<TaskItem> getAll();
  Future<void> upsert(TaskItem task);
  Future<void> delete(String id);
  Future<void> clearCompleted();
}
