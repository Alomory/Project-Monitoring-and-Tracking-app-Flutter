
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/models/task.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';
class EditTask extends StatefulWidget {
  final Task task;
  final Phase phase;
  final Function updateTask;
  final Project project;
  const EditTask({super.key, required this.task,required this.phase, required this.updateTask, required this.project});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late TextEditingController taskNameController;
  late TextEditingController descriptionController;
  late DateTime dueDate;
  late int status;
  final _formKey = GlobalKey<FormState>();


  void _presentDatePicker(context) {
    showDatePicker(
        context: context,
        initialDate: widget.task.dueDate,  // Use task's due date as the initial date
        firstDate: widget.project.projectStartDate,
        lastDate: widget.project.projectEndDate)
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        dueDate = pickedDate;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the phase values
    taskNameController = TextEditingController(text: widget.task.taskName);
    descriptionController = TextEditingController(text: widget.task.taskDescription);
    dueDate = widget.task.dueDate;
    status = widget.task.taskStatus;
  }
  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return SingleChildScrollView(
      child: Container(
        color: theme.background,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: taskNameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Task Name can not be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Task Description'),
                controller: descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Task Description can not be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text("Due Date"),
                  SizedBox(width: 20,),
                  TextButton(
                    style: theme.buttonStyle,
                      onPressed: (){
                      _presentDatePicker(context);
                      }, child: Text(
                      DateFormat.yMd().format(dueDate)
                  ))
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Radio(
                        activeColor: Colors.red,
                        value: TaskStatus.notStarted.index,
                        groupValue: status,
                        onChanged: (int? value) {
                          setState(() {
                            status = value!;
                          });
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
                        groupValue: status,
                        onChanged: (int? value) {
                          setState(() {
                            status = value!;
                          });
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
                        groupValue: status,
                        onChanged: (int? value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      const Text('Completed'),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: theme.buttonStyle,
                    onPressed: () {

                      Navigator.pop(context); // Close the modal
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: theme.buttonStyle,
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        widget.updateTask(
                            widget.phase,
                            widget.task,
                            taskNameController.text,
                            descriptionController.text,
                            dueDate,
                            status
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
/*
* String taskName; // Name of the task
  String taskDescription; // Description of the task
  DateTime dueDate; // Due date for the task
  int taskStatus; */
