

import 'package:flutter/material.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/models/task.dart';
import 'package:project_monitoring_and_tracking/models/user.dart';

class Project extends ChangeNotifier{
  String user;
  String projectId; // Unique identifier for the project
  String projectName; // Name of the project
  String projectDescription; // Description of the project
  DateTime projectStartDate; // Start date of the project
  DateTime projectEndDate; // End date of the project
  List<Phase> phase = []; // List of tasks associated with the project


  Project.withPhases({
    required this.user,
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.projectStartDate,
    required this.projectEndDate,
    required this.phase,
  });
  Project.withoutPhases({
    required this.user,
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.projectStartDate,
    required this.projectEndDate,
  }) : phase = [];

  Map<String, double> get tasksPerPhase {
    Map<String, double> taskCounts = {};
    for (var phase in phase) {
      taskCounts[phase.phaseName] = phase.tasks.length.toDouble();
    }
    return taskCounts;
  }
}

