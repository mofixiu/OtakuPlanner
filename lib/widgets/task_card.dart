import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/themes/theme.dart'; // Add theme import

class TaskCard extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final IconData? icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  // Add theme color parameters
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const TaskCard({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.isChecked,
    required this.onChanged,
    this.icon,
    required this.onEdit,
    required this.onDelete,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get theme colors if not provided
    final cardBgColor = backgroundColor ?? 
        (isDarkMode ? OtakuPlannerTheme.darkCardBackground : Colors.white);
    final cardTextColor = textColor ?? 
        (isDarkMode ? Colors.white : Colors.black);
    final cardBorderColor = borderColor ?? 
        (isDarkMode ? OtakuPlannerTheme.darkBorderColor : Colors.grey.shade300);
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cardBorderColor.withOpacity(0.5),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Theme(
                data: ThemeData(
                  checkboxTheme: CheckboxThemeData(
                    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return isDarkMode ? Colors.lightBlue : Colors.blue;
                      }
                      return isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
                    }),
                    checkColor: MaterialStateProperty.all(Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                child: Checkbox(value: isChecked, onChanged: onChanged),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isChecked 
                        ? cardTextColor.withOpacity(0.6) 
                        : cardTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              children: [
                FaIcon(
                  icon, 
                  size: 15,
                  color: isDarkMode ? Colors.lightBlue : Colors.blue,
                ),
                SizedBox(width: 6),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 13, 
                    color: cardTextColor.withOpacity(0.7)
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "• $time",
                  style: TextStyle(
                    fontSize: 13, 
                    color: cardTextColor.withOpacity(0.7)
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onEdit,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: isDarkMode 
                      ? OtakuPlannerTheme.darkButtonBackground 
                      : Colors.grey.shade100,
                  child: Icon(
                    FontAwesomeIcons.pen,
                    size: 13,
                    color: isDarkMode ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: isDarkMode 
                      ? Colors.red.shade900.withOpacity(0.7) 
                      : Colors.red.withOpacity(0.1),
                  child: Icon(
                    FontAwesomeIcons.trash,
                    size: 13,
                    color: isDarkMode ? Colors.white : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}