// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:provider/provider.dart';

typedef OnSubmit = void Function(String title, String category, String time);

Future<String?> showCreateCategoryDialog(BuildContext context) async {
  final TextEditingController categoryController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      // Get theme colors
      final cardColor = OtakuPlannerTheme.getCardColor(dialogContext);
      final textColor = OtakuPlannerTheme.getTextColor(dialogContext);
      
      return AlertDialog(
        backgroundColor: cardColor,
        title: Text("Create New Category", style: TextStyle(color: textColor)),
        content: TextField(
          controller: categoryController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: "Category Name",
            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final newCategory = categoryController.text.trim();
              if (newCategory.isNotEmpty) {
                final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                
                // Add and save category
                final success = await categoryProvider.addAndSaveCategory(newCategory, userProvider.userId);
                
                if (success) {
                  // Force a complete refresh of the category provider
                  await categoryProvider.loadCategoriesFromDatabase(userProvider.userId);
                  Navigator.pop(dialogContext, newCategory);
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to create category or category already exists"),
                    ),
                  );
                }
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
          return Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              final categories = categoryProvider.categoriesForDropdown;
              
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
                      dropdownColor: OtakuPlannerTheme.getDropdownBackgroundColor(context),
                      style: TextStyle(
                        color: OtakuPlannerTheme.getDropdownItemColor(context),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: OtakuPlannerTheme.getDropdownIconColor(context),
                      ),
                      items: [
                        // Create dropdown items from current categories
                        ...categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }),
                        // Add "Create New Category" option
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
                        TimeOfDay? pickedTime = await showTimePicker(
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
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          selectedCategory != null &&
                          selectedTime != null) {
                        onSubmit(titleController.text, selectedCategory!, selectedTime!);
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Save"),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
