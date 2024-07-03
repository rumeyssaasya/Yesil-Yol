import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskPage extends StatefulWidget {
  final String pageName;
  final List<String> tasks;
  final Function(int) onTaskComplete;
  final Map<String, dynamic> completedTasks;
  final Function(String, Timestamp) onTaskChecked; // Fonksiyon tipi güncellendi
  final User loggedInUser; // loggedInUser parametresi eklendi

  TaskPage({
    required this.pageName,
    required this.tasks,
    required this.onTaskComplete,
    required this.completedTasks,
    required this.onTaskChecked,
    required this.loggedInUser,
  });

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Map<String, bool> taskCompletionStatus = {};

  @override
  void initState() {
    super.initState();
    for (var task in widget.tasks) {
      taskCompletionStatus[task] =
          widget.completedTasks.containsKey(task);
    }
  }

  void _handleTaskCompletion(String task) async {
    if (!widget.completedTasks.containsKey(task)) {
      final now = DateTime.now();
      final completeDate = Timestamp.fromDate(now);
      widget.onTaskChecked(task, completeDate); // Tamamlama tarihini iletiyoruz
      widget.onTaskComplete(5); // Örnek: Görev tamamlandığında 5 greenCoins kazan
      setState(() {
        taskCompletionStatus[task] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageName),
      ),
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          return ListTile(
            title: Text(task),
            trailing: Checkbox(
              value: taskCompletionStatus[task] ?? false,
              onChanged: (bool? isChecked) {
                if (isChecked != null && isChecked) {
                  _handleTaskCompletion(task);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
