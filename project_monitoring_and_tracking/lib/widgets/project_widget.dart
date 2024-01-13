import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/models/task.dart';
import 'package:project_monitoring_and_tracking/models/user.dart';
import 'package:project_monitoring_and_tracking/screens/add_phase.dart';
import 'package:project_monitoring_and_tracking/screens/add_task.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';
import 'package:project_monitoring_and_tracking/widgets/edit_project.dart';
import 'package:project_monitoring_and_tracking/widgets/pie_chart.dart';
import 'package:project_monitoring_and_tracking/widgets/pie_chart_task_status.dart';
import 'package:project_monitoring_and_tracking/widgets/util.dart';

class ProjectWidget extends StatefulWidget {
  final Project project;
  final User user;
  final Function updateProject;
  final Function deleteProject;

  const ProjectWidget({super.key, required this.user, required this.project, required this.updateProject, required this.deleteProject});

  @override
  State<ProjectWidget> createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  int totalTask = 0, completed = 0, inProgress = 0;

  @override
  void initState() {
    super.initState();
  }

  void _addTask(String phaseId, Task task) {
    setState(() {
      widget.project.phase
          .firstWhere((element) => element.phaseId == phaseId)
          .tasks
          .add(task);
    });
    print(
        "#Debug home_page.dart => new Task added ${widget.project.phase.firstWhere((element) => element.phaseId == phaseId).phaseId}");
  }

  List<Task> _totalTask() {
    return widget.project.phase.fold<List<Task>>(
        [], (previousValue, element) => previousValue + element.tasks);
  }

  int completedTasks(List<Task> tasks) {
    return tasks
        .where((task) => task.taskStatus == TaskStatus.completed)
        .length;
  }

  void _addPhase(Phase newPhase) {
    setState(() {
      widget.project.phase.add(newPhase);
      // phases = currentProject.phase;
    });
  }
  void _showModalBottomProject(){
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EditProject(project: widget.project, updateProject: widget.updateProject);
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rectangle box behind "Project A" and its description
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  margin: EdgeInsets.all(10),
                  color: theme.veryLight,
                  semanticContainer: true,
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.project.projectName,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                   SizedBox(width: 20,),
                                    Row(
                                      children: [
                                        IconButton(onPressed: () {
                                          _showModalBottomProject();
                                        }, icon:  Icon(Icons.edit), color: theme.blueDark,),
                                        IconButton(onPressed: (){
                                          widget.deleteProject(widget.project);
                                        }, icon:  Icon(Icons.delete_forever),color: Colors.red,)
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  widget.project.projectDescription,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),

                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        widget.project.phase.isNotEmpty &&
                                _totalTask().length > 0
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PieChartTaskStatus(project: widget.project),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  PieChartWidget(project: widget.project),
                                ],
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
              // Metrics
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: theme.veryLight,
                  semanticContainer: true,
                  elevation: 1.0,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Metrics",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildMetric(context, "Total Tasks",
                                _totalTask().length.toString()),
                            buildMetric(
                              context,
                              "Completed",
                              _totalTask()
                                  .where((task) =>
                                      task.taskStatus ==
                                      TaskStatus.completed.index)
                                  .length
                                  .toString(),
                            ),
                            buildMetric(
                              context,
                              "In Progress",
                              _totalTask()
                                  .where((task) =>
                                      task.taskStatus ==
                                      TaskStatus.inProgress.index)
                                  .length
                                  .toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Upcoming Deadlines
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: theme.veryLight,
                  semanticContainer: true,
                  elevation: 1.0,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Upcoming Deadlines:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        _totalTask().isNotEmpty
                            ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: ListView.builder(
                            itemCount: _totalTask().length,
                            itemBuilder: (BuildContext context, int index) {
                              Task task = _totalTask()[index];

                              // Check if the task's due date is within the next 3 days
                              DateTime currentDate = DateTime.now();
                              DateTime dueDate = task.dueDate; // Assuming you have a dueDate property in your Task class

                              // Calculate the difference in days
                              int daysDifference = dueDate.difference(currentDate).inDays;

                              // Display only tasks that are due within the next 3 days
                              if (daysDifference >= 0 && daysDifference <= 3 ) {
                                return buildTaskTile(context, task, theme);
                              } else {
                                // If the task is not within the next 3 days, return an empty container
                                return Container();
                              }
                            },
                          ),
                        )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                child: const Center(
                                    child: Text(
                                  "There is no Task...!",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )),
                              ),
                      ],
                    ),
                  ),
                ),
              ),

              // Phases
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    color: theme.veryLight,
                    semanticContainer: true,
                    elevation: 1.0,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: widget.project.phase.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Phases:",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(

                                          borderRadius: BorderRadius.circular(20),
                                          color: theme.blueDark,
                                        ),
                                        child: IconButton(
                                            splashColor: theme.blueDark,
                                            onPressed: () {
                                              showModalBottomSheet(
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  enableDrag: true,
                                                  context: context,
                                                  elevation: 1,
                                                  isScrollControlled: true,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AddPhase(
                                                      currentProject:
                                                      widget.project,
                                                      addPhase: _addPhase,
                                                      theme: theme,
                                                    );
                                                  });
                                            },
                                            icon:  Icon(Icons.add, color: theme.veryLight,)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Column(
                                    children: widget.project.phase.map((phase) {
                                      return ExpansionTile(
                                        title: Text(phase.phaseName),
                                        children: phase.tasks.map((task) {
                                          return buildTaskTile(
                                            context,
                                            task,
                                            theme,
                                          );
                                        }).toList(),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              )
                            : ListTile(
                                title: const Text("Add Phase"),
                                trailing:  Container(
                                  decoration:BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.blueDark,
                                  ) ,

                                  child: Icon(Icons.add, color: theme.veryLight,),
                                ),
                                onTap: () {
                                  showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      enableDrag: true,
                                      context: context,
                                      elevation: 1,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return AddPhase(
                                          currentProject: widget.project,
                                          addPhase: _addPhase,
                                          theme: theme,
                                        );
                                      });
                                },
                              )),
                  )),
            ],
          ),
        ),
        floatingActionButton: widget.project.phase.isNotEmpty
            ? FloatingActionButton(
                backgroundColor: theme.blueDark,
                onPressed: () async {
                  // Map<String, dynamic> result = await
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      enableDrag: true,
                      context: context,
                      elevation: 1,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return AddTask(
                          theme: theme,
                          project: widget.project,
                          addTask: _addTask,
                        );
                      });
                },
                child: Icon(
                  Icons.add,
                  color: theme.veryLight,
                ),
              )
            : Container());
  }

  Widget buildMetric(context, String title, String value) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget buildTaskTile(BuildContext context, Task task, AppTheme theme) {
    return ListTile(
      trailing: Icon(
        Icons.touch_app_outlined,
        color: theme.blueDark,
      ),
      //ref: https://stackoverflow.com/questions/29628989/how-to-capitalize-the-first-letter-of-a-string-in-dart
      title: Text("- ${task.taskName.toTitleCase()}",
          style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 15)),

      subtitle: Text(
          '\t\t\tDue Date: ${DateFormat("yyyy-MM-dd").format(task.dueDate)}'),
      onTap: () {
        //TODO: remove the task from the list and firebase
      },
    );
  }
}
