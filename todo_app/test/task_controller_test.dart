import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/features/tasks/data/task_item.dart';
import 'package:todo_app/features/tasks/data/task_repository.dart';
import 'package:todo_app/features/tasks/presentation/task_controller.dart';

class InMemoryTaskRepository implements TaskRepository {
  final List<TaskItem> _tasks = <TaskItem>[];

  @override
  List<TaskItem> getAll() => List<TaskItem>.from(_tasks);

  @override
  Future<void> clearCompleted() async {
    _tasks.removeWhere((task) => task.isCompleted);
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<void> upsert(TaskItem task) async {
    final index = _tasks.indexWhere((existing) => existing.id == task.id);
    if (index == -1) {
      _tasks.add(task);
    } else {
      _tasks[index] = task;
    }
  }
}

void main() {
  test('saves, searches, and filters tasks', () async {
    final repository = InMemoryTaskRepository();
    final controller = TaskController(repository);

    await controller.saveTask(
      draft: const TaskDraft(
        title: 'Pay rent',
        details: 'Due on Friday',
        category: 'Home',
      ),
    );

    await controller.saveTask(
      draft: const TaskDraft(
        title: 'Read docs',
        details: '',
        category: 'Study',
      ),
    );

    expect(controller.tasks, hasLength(2));

    controller.setSearchQuery('rent');
    expect(controller.visibleTasks, hasLength(1));
    expect(controller.visibleTasks.single.title, 'Pay rent');

    controller.clearFilters();
    controller.setCategoryFilter('Study');
    expect(controller.visibleTasks, hasLength(1));
    expect(controller.visibleTasks.single.title, 'Read docs');
  });

  test('toggles task completion and clears completed tasks', () async {
    final repository = InMemoryTaskRepository();
    final controller = TaskController(repository);

    await controller.saveTask(
      draft: const TaskDraft(
        title: 'Walk the dog',
        details: '',
        category: 'Personal',
      ),
    );

    final task = controller.tasks.single;
    await controller.toggleTask(task);

    expect(controller.tasks.single.isCompleted, isTrue);

    await controller.clearCompleted();
    expect(controller.tasks, isEmpty);
  });
}
