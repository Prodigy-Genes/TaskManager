// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class TaskCounter extends StatefulWidget {
  final int taskCount;

  const TaskCounter({super.key, required this.taskCount});

  @override
  _TaskCounterState createState() => _TaskCounterState();
}

class _TaskCounterState extends State<TaskCounter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${widget.taskCount}', 
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }
}
