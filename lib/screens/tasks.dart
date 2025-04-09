import 'package:flutter/material.dart';
import 'package:otakuplanner/screens/profile.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/customButtonSmallerTextSize.dart';
import 'package:otakuplanner/shared/categories.dart'; // Import the shared categories
import 'package:provider/provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  void profile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  final int _currentIndex = 2;

  // Track the selected category
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.getTasksByCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/otaku.jpg", fit: BoxFit.contain),
        centerTitle: false,
        backgroundColor: Color.fromRGBO(255, 249, 233, 1),
        elevation: 2,
        scrolledUnderElevation: 2,
        title: Text(
          "OtakuPlanner",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: profile,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Tasks",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            CustomButton(
              ontap: () {},
              data: "+ Automate Task",
              textcolor: Colors.white,
              backgroundcolor: Color(0xFF1E293B),
              width: MediaQuery.of(context).size.width,
              height: 40,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Wrap(
              spacing: 8.0, // Horizontal spacing between items
              runSpacing: 8.0, // Vertical spacing between rows
              children: Categories.categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF1E293B) : Colors.white,
                      border: Border.all(color: Colors.grey.shade100, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Text(
                        "No tasks available for this category.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return ListTile(
                          leading: Icon(Icons.task, color: task.color),
                          title: Text(task.title),
                          subtitle: Text("${task.category} - ${task.time}"),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
