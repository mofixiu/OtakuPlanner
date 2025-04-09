import 'package:flutter/material.dart';

typedef OnSubmit = void Function(String title, String category, String time);

Future<String?> showCreateCategoryDialog(BuildContext context) async {
  final TextEditingController categoryController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Create New Category"),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final newCategory = categoryController.text.trim();
              if (newCategory.isNotEmpty) {
                Navigator.pop(context, newCategory);
              }
            },
            child: Text("Create"),
          ),
        ],
      );
    },
  );
}

void showTaskDialog({
  required BuildContext context,
  required String dialogTitle,
  String? initialTitle,
  String? initialCategory,
  String? initialTime,
  required OnSubmit onSubmit,
}) {
  final TextEditingController titleController = TextEditingController(text: initialTitle ?? '');
  final List<String> categories = ["Work", "Study", "Coding", "Personal"]; 
  String? selectedCategory = initialCategory;
  String? selectedTime = initialTime;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(dialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Category"),
                  value: selectedCategory,
                  items: [
                    ...categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    DropdownMenuItem(
                      value: "Create New Category",
                      child: Text("Create New Category"),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == "Create New Category") {
                      final newCategory = await showCreateCategoryDialog(context);
                      if (newCategory != null && newCategory.isNotEmpty) {
                        setState(() {
                          categories.add(newCategory); // Add the new category to the list
                          selectedCategory = newCategory; // Set it as the selected category
                        });
                      }
                    } else {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text(selectedTime != null
                      ? "Time: $selectedTime"
                      : "Select Time"),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime.format(context); // Convert TimeOfDay to String
                      });
                    }
                  },
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
                  if (titleController.text.isEmpty ||
                      selectedCategory == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please fill in all the fields."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    onSubmit(
                      titleController.text,
                      selectedCategory!,
                      selectedTime!,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}
