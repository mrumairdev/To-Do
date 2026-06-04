import 'package:flutter/material.dart';

import '../data/task_item.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    super.key,
    this.initialTask,
    required this.categories,
  });

  final TaskItem? initialTask;
  final List<String> categories;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );
    _detailsController = TextEditingController(
      text: widget.initialTask?.details ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.initialTask?.category ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.initialTask == null ? 'Add task' : 'Edit task',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Plan quarterly review',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please add a title.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailsController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Details',
                hintText: 'Optional notes, context, or next steps',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Work, Personal, Home...',
              ),
            ),
            if (widget.categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Quick picks',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.categories
                    .take(6)
                    .map(
                      (category) => ChoiceChip(
                        label: Text(category),
                        selected: _categoryController.text == category,
                        onSelected: (_) {
                          setState(() {
                            _categoryController.text = category;
                          });
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(
                      widget.initialTask == null
                          ? 'Create task'
                          : 'Save changes',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      TaskDraft(
        title: _titleController.text,
        details: _detailsController.text,
        category: _categoryController.text,
      ),
    );
  }
}
