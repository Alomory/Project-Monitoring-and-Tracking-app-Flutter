import 'package:flutter/material.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/models/task.dart';
import 'package:project_monitoring_and_tracking/models/user.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';
import 'package:project_monitoring_and_tracking/widgets/edit_phase.dart';
import 'package:project_monitoring_and_tracking/widgets/edit_task.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({Key? key,
    required this.user,
    required this.project,
    required this.updateTaskStatus,
    required this.deleteTask,
    required this.deletPhase,
    required this.updatePhase,
    required this.updateTask
  })
      : super(key: key);
  final Project project;
  final User user;
  final Function updateTaskStatus,  deleteTask, deletPhase, updatePhase, updateTask;

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  String selectedSortingOption = 'All Tasks';
  //updating task
  void _showUpdateTaskModal(Task task, Phase phase)  {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EditTask(task: task, phase: phase, updateTask: widget.updateTask, project:  widget.project,);
      },
    );
  }
//updating phase
  void _showUpdatePhaseModal(Phase phase)  {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EditPhase(phase: phase, updatePhase: widget.updatePhase);
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(10),
            color: theme.blueDark.withOpacity(0.8),
            semanticContainer: true,
            elevation: 1.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Text(
                    "Sort by:",
                    style: theme.subtitleStyle.copyWith(color: theme.veryLight),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.veryLight,
                    ),
                    child:
                        //ref: https://www.flutterbeads.com/change-dropdown-color-in-flutter/
                    DropdownButton<String>(
                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
                      dropdownColor: theme.veryLight, // Set the dropdown background color
                      iconEnabledColor: theme.blueDark,
                      underline: SizedBox(),
                      borderRadius: BorderRadius.circular(20),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:theme.blueDark
                      ),
                      value: selectedSortingOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSortingOption = newValue!;
                        });
                      },
                      items: [
                        "All Tasks", // New category for all tasks
                        "Not Started",
                        "In Progress",
                        "Completed",
                      ].map<DropdownMenuItem<String>>(
                            (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            color: theme.veryLight,
            semanticContainer: true,
            elevation: 1.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.project.phase
                        .map(
                          (phase) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    phase.phaseName,
                                    style: theme.subtitleStyle.copyWith(
                                      color: theme.blueDark,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  IconButton(onPressed: (){
                                    _showUpdatePhaseModal(phase);
                                    }, icon: Icon(Icons.edit_note , size: 25, color: theme.blueMeium,)),
                                  IconButton(onPressed: (){widget.deletPhase(phase);} , icon: Icon(Icons.delete_sweep_sharp, size: 25), color: Colors.red,)
                                ],
                              )
                            ],
                          ),
                          Divider(
                            endIndent: MediaQuery.of(context).size.width *.6,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _sortTasksByStatus(phase.tasks, theme, phase),
                          ),
                          Divider(
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),

            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _sortTasksByStatus(List<Task> tasks, AppTheme theme, Phase phase) {
    switch (selectedSortingOption) {
      case "Not Started":
        return tasks
            .where((task) => task.taskStatus == TaskStatus.notStarted.index)
            .map((task) => _buildTaskWidget(task, theme, phase))
            .toList();
      case "In Progress":
        return tasks
            .where((task) => task.taskStatus == TaskStatus.inProgress.index)
            .map((task) => _buildTaskWidget(task, theme, phase))
            .toList();
      case "Completed":
        return tasks
            .where((task) => task.taskStatus == TaskStatus.completed.index)
            .map((task) => _buildTaskWidget(task, theme, phase))
            .toList();
      case "All Tasks": // New case for displaying all tasks
        return tasks.map((task) => _buildTaskWidget(task, theme, phase)).toList();
      default:
        return [];
    }
  }

  Widget _buildTaskWidget(Task task, AppTheme theme, Phase phase) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: ExpansionTile(

          title: Text(task.taskName),
          subtitle: Text(TaskStatus.values[task.taskStatus].toString().split('.')[1]),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(

                      icon: Icon(Icons.edit, color: theme.blueMeium,),
                      onPressed: () {
                        _showUpdateTaskModal(task, phase);
                      },
                    ),
                    IconButton(

                      icon: Icon(Icons.delete, color: Colors.red,),
                      onPressed: () {
                       widget.deleteTask(task, phase);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      activeColor: Colors.red,
                      value: TaskStatus.notStarted.index,
                      groupValue: task.taskStatus,
                      onChanged: (int? value) {
                        widget.updateTaskStatus(task, TaskStatus.notStarted.index);
                      },
                    ),
                    const Text('Not Started'),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      activeColor: Colors.amber,

                      value: TaskStatus.inProgress.index,
                      groupValue: task.taskStatus,
                      onChanged: (int? value) {
                        widget.updateTaskStatus(task, TaskStatus.inProgress.index);
                      },
                    ),
                    const Text('In Progress'),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      activeColor: Colors.lightGreenAccent,

                      value: TaskStatus.completed.index,
                      groupValue: task.taskStatus,
                      onChanged: (int? value) {
                        widget.updateTaskStatus(task, TaskStatus.completed.index);
                      },
                    ),
                    const Text('Completed'),
                  ],
                ),
              ],
            ),
          ],

      ),
    );
  }
}
