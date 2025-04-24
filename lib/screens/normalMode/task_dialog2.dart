import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/theme.dart'; // Add this import

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
  final TextEditingController titleController = TextEditingController(
    text: initialTitle ?? '',
  );
  final List<String> categories = ["Work", "Study", "Coding", "Personal"];
  String? selectedCategory = initialCategory;
  String? selectedTime = initialTime;

  showDialog(
    context: context,
    builder: (context) {
      // Get theme colors
      final cardColor = OtakuPlannerTheme.getCardColor(context);
      final textColor = OtakuPlannerTheme.getTextColor(context);
      final borderColor = OtakuPlannerTheme.getBorderColor(context);
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: cardColor,
            title: Text(dialogTitle, style: TextStyle(color: textColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.lightBlue : Colors.blue,
                      ),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Category",
                    labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.lightBlue : Colors.blue,
                      ),
                    ),
                  ),
                  value: selectedCategory,
                  dropdownColor: OtakuPlannerTheme.getDropdownBackgroundColor(
                    context,
                  ),
                  style: TextStyle(
                    color: OtakuPlannerTheme.getDropdownItemColor(context),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: OtakuPlannerTheme.getDropdownIconColor(context),
                  ),
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
                      final newCategory = await showCreateCategoryDialog(
                        context,
                      );
                      if (newCategory != null && newCategory.isNotEmpty) {
                        setState(() {
                          categories.add(newCategory);
                          selectedCategory = newCategory;
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
                  leading: Icon(Icons.access_time, color: textColor),
                  title: Text(
                    selectedTime != null
                        ? "Time: $selectedTime"
                        : "Select Time",
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime.format(context);
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkMode ? Colors.lightBlue : Colors.blue,
                  ),
                ),
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
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: isDarkMode ? Colors.lightBlue : Colors.blue,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
