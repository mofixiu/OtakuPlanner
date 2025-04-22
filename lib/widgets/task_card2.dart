import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskCard2 extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final ValueChanged<bool?> onChanged;
  final IconData? icon;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard2({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.onChanged,
    this.icon,

    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 50), // Add margin here

            child: Row(
              children: [
                FaIcon(icon, size: 15), // dynamic icon
                SizedBox(width: 6),
                Text(
                  category,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                SizedBox(width: 10),
                Text(
                  "• $time",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(
                    FontAwesomeIcons.pen,
                    size: 19,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(
                    FontAwesomeIcons.trash,
                    size: 19,
                    color: Colors.red,
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
