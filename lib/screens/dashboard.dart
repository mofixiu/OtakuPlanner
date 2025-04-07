import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/task_dialog.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/customButton.dart';
import 'package:otakuplanner/widgets/task_card.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class Task {
  String title;
  String category;
  String time;
  IconData icon;
  bool isChecked;

  Task({
    required this.title,
    required this.category,
    required this.time,
    required this.icon,
    this.isChecked = false,
  });
}

class _DashboardState extends State<Dashboard> {
  final int _currentIndex = 1;
  bool checked1 = false;
  bool checked2 = false;
  bool checked3 = false;
  List<Task> tasks = [
    Task(
      title: "Complete React tutorial",
      category: "Study",
      time: "14:02",
      icon: FontAwesomeIcons.bookAtlas,
    ),
    Task(
      title: "Morning Workout",
      category: "Health",
      time: "7:00",
      icon: FontAwesomeIcons.dumbbell,
    ),
    Task(
      title: "Project Presentation",
      category: "Study",
      time: "14:02",
      icon: FontAwesomeIcons.briefcase,
    ),
  ];
  void _showAddTaskDialog() {
    showTaskDialog(
      context: context,
      dialogTitle: "New Task",
      onSubmit: (title, category, time) {
        setState(() {
          tasks.add(
            Task(
              title: title,
              category: category,
              time: time,
              icon: FontAwesomeIcons.tasks,
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).username;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/otaku.jpg", fit: BoxFit.contain),

        centerTitle: false,
        backgroundColor: Color.fromRGBO(252, 242, 232, 1),
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
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(252, 242, 232, 1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 0.4),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Welcome back, $username!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Let's make today productive and achieve \nyour goals",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.22,
                      width: MediaQuery.of(context).size.width / 2 - 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(252, 242, 232, 1),
                        border: Border.all(color: Colors.black, width: 0.4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's\nTasks",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.note_alt_outlined,
                                  color: Color(0xFF1E293B),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Text(
                              "3",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Text("1 completed", style: TextStyle(fontSize: 15)),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),

                            StepProgressIndicator(
                              totalSteps: 100,
                              currentStep: 32,
                              size: 8,
                              padding: 0,
                              selectedColor: Colors.yellow,
                              unselectedColor: Colors.cyan,
                              roundedEdges: Radius.circular(10),
                              selectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E293B), Color(0xFF1E293B)],
                              ),
                              unselectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.22,
                      width: MediaQuery.of(context).size.width / 2 - 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(252, 242, 232, 1),
                        border: Border.all(color: Colors.black, width: 0.4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Current\nStreak",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                FaIcon(
                                  FontAwesomeIcons.clock,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Text(
                              "3",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Text("1 completed", style: TextStyle(fontSize: 15)),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            StepProgressIndicator(
                              totalSteps: 100,
                              currentStep: 74,
                              size: 8,
                              padding: 0,
                              // selectedColor: Colors.yellow,
                              // unselectedColor: Colors.cyan,
                              roundedEdges: Radius.circular(10),
                              selectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.green, Colors.green],
                              ),
                              unselectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.22,
                      width: MediaQuery.of(context).size.width / 2 - 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(252, 242, 232, 1),
                        border: Border.all(color: Colors.black, width: 0.4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Achievements",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                FaIcon(
                                  FontAwesomeIcons.trophy,
                                  color: Colors.yellow,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(
                              "3",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            Text(
                              "6 more to unlock",
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            StepProgressIndicator(
                              totalSteps: 100,
                              currentStep: 74,
                              size: 8,
                              padding: 0,
                              // selectedColor: Colors.yellow,
                              // unselectedColor: Colors.cyan,
                              roundedEdges: Radius.circular(10),
                              selectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.yellow, Colors.yellow],
                              ),
                              unselectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  CustomButton(
                    ontap: _showAddTaskDialog,
                    data: "+",
                    textcolor: Colors.white,
                    backgroundcolor: Colors.deepPurple,
                    width: 40,
                    height: 30,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ...tasks.asMap().entries.map((entry) {
                int index = entry.key;
                Task task = entry.value;

                return TaskCard(
                  title: task.title,
                  category: task.category,
                  time: task.time,
                  icon: task.icon,
                  isChecked: task.isChecked,
                  onChanged: (val) {
                    setState(() {
                      task.isChecked = val ?? false;
                    });
                  },
                  onEdit: () {
                    showTaskDialog(
                      context: context,
                      dialogTitle: "Edit Task",
                      initialTitle: task.title,
                      initialCategory: task.category,
                      initialTime: task.time,
                      onSubmit: (title, category, time) {
                        setState(() {
                          task.title = title;
                          task.category = category;
                          task.time = time;
                        });
                      },
                    );
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete Task"),
                          content: Text(
                            "Are you sure you want to delete ${task.title}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  tasks.removeAt(index);
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
