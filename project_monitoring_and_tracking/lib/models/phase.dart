

import 'package:project_monitoring_and_tracking/models/task.dart';

class Phase  {
  final String phaseId;
   String phaseName;
   String phaseDescription;
  int taskNo = 0;
  List<Task> tasks = [];

  Phase({required this.phaseId, required this.phaseName, required this.phaseDescription});
  Phase.withTask({required this.phaseId, required this.phaseName, required this.phaseDescription, required this.tasks});

}