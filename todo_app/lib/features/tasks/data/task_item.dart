import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.details,
    required this.category,
  });

  final String title;
  final String details;
  final String category;
}

@immutable
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.details,
    required this.category,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  static const int typeId = 1;

  final String id;
  final String title;
  final String details;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TaskItem.create({
    required String title,
    required String details,
    required String category,
  }) {
    final now = DateTime.now();
    return TaskItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      details: details,
      category: category,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  TaskItem copyWith({
    String? title,
    String? details,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      details: details ?? this.details,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final int typeId = TaskItem.typeId;

  @override
  TaskItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };

    return TaskItem(
      id: fields[0] as String,
      title: fields[1] as String,
      details: fields[2] as String,
      category: fields[3] as String,
      isCompleted: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }
}
