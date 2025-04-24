import 'package:flutter/material.dart';

typedef OnSubmit = void Function(String title, String category, String time);

void showTaskDialog({
  required BuildContext context,
  required String dialogTitle,
  String? initialTitle,
  String? initialCategory,
  String? initialTime,
  required OnSubmit onSubmit,
}) {
  final TextEditingController titleController = TextEditingController(text: initialTitle ?? '');
  final TextEditingController categoryController = TextEditingController(text: initialCategory ?? '');
  final TextEditingController timeController = TextEditingController(text: initialTime ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(dialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final category = categoryController.text.trim();
              final time = timeController.text.trim();

              if (title.isNotEmpty && category.isNotEmpty && time.isNotEmpty) {
                onSubmit(title, category, time);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}
