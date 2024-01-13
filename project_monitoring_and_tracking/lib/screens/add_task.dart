import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_monitoring_and_tracking/data/const.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project_monitoring_and_tracking/models/task.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';

class AddTask extends StatefulWidget {
  final Project project;
  final Function addTask;
  final AppTheme theme;

  AddTask({required this.project, required this.addTask, required this.theme});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _taskDescController = TextEditingController();
  static final GlobalKey<FormState>  _taskFormKey = GlobalKey<FormState>();
  var _phaseId;
  DateTime _dueDate = DateTime.now();

  @override
  void initState() {
    _phaseId = widget.project.phase[0].phaseId;
    super.initState();
  }

  bool isDateSet = false;

  void _presentDatePicker(context) {
    showDatePicker(
            context: context,
            initialDate: widget.project.projectStartDate,
            firstDate: widget.project.projectStartDate,
            lastDate: widget.project.projectEndDate)
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        isDateSet = true;
        _dueDate = pickedDate;
      });
    });
  }

  void _saveData(context) async {

      final url = Uri.https(firebaseUrl,
          "project-list/${widget.project.projectId}/phase/$_phaseId/tasks.json");
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'taskName': _taskNameController.text,
              'taskDescription': _taskDescController.text,
              'dueDate': _dueDate.toIso8601String(),
              'isCompleted': 0
            },
          ),
        );

        if (response.statusCode == 200) {
          print(
              "Debug add_phase.dart => response body = ${response.body} ${response.statusCode}");
          final Map<String, dynamic> data = json.decode(response.body);
          print("Debug add_phase.dart => phase id = ${data['name']}");
          Task newTask = Task(
              taskId: data['name'].toString(),
              taskName: _taskNameController.text,
              taskDescription: _taskDescController.text,
              dueDate: _dueDate,
              taskStatus: 0);

          if (_phaseId != null) {
            widget.addTask(_phaseId, newTask);
            print("#Debug add_task.dart => _phase id new = $_phaseId");

            // Navigator.of(context).pop({"task":newTask,"phaseId":_phaseId});
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select an phase first')),
            );
          }
        }
      } catch (error) {
        print('Error home_page.dart loading items: $error');
      }

  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    //ref: https://github.com/flutter/flutter/issues/32747
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Form(
          key: _taskFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Add Task",
                  style: widget.theme.titleStyle.copyWith(
                    color: widget.theme.blueDark,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Phase:",
                          style: widget.theme.subtitleStyle
                              .copyWith(color: widget.theme.blueDark)),
                      const SizedBox(
                        height: 15,
                      ),
                      DropdownMenu<Phase>(
                        menuStyle: MenuStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(theme.blueDark),
                          // surfaceTintColor: MaterialStatePropertyAll(theme.dark)
                        ),
                        enableSearch: true,
                        width: MediaQuery.of(context).size.width * 0.5,
                        initialSelection: widget.project.phase.isNotEmpty
                            ? widget.project.phase.first
                            : null,
                        // Set to null if the list is empty,
                        onSelected: (Phase? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _phaseId = value!.phaseId;
                          });
                          print("phase is =$_phaseId");
                        },
                        dropdownMenuEntries: widget.project.phase
                            .map<DropdownMenuEntry<Phase>>((Phase value) {
                          return DropdownMenuEntry<Phase>(
                            style: ElevatedButton.styleFrom(
                              elevation: 4.0,
                              foregroundColor: theme.veryLight,
                            ),
                            value: value,
                            label: value.phaseName.toUpperCase(),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Due Date",
                        style: widget.theme.subtitleStyle
                            .copyWith(color: widget.theme.blueDark),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      IconButton(
                          onPressed: () => _presentDatePicker(context),
                          icon: Icon(
                            Icons.date_range,
                            color: widget.theme.blueMeium,
                          )),
                      Text(
                        isDateSet
                            ? DateFormat.yMd().format(_dueDate)
                            : "Choose Date",
                        style: widget.theme.subtitleStyle
                            .copyWith(color: widget.theme.blueDark),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(hintText: "Enter the phase name"),
                validator: (value) {
                  if(value!.isEmpty || value == null){
                    return "Please Enter phase name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _taskDescController,
                decoration:
                    InputDecoration(hintText: "Enter any description you want"),
                validator: (value) {
                  if(value!.isEmpty || value == null){
                    return "Please Enter phase description name";
                  }
                  return null;
                },
              ),

              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: widget.theme.buttonStyle,
                      onPressed: () {
                       if(_taskFormKey.currentState!.validate()){
                         print("#Debug add_task.dart => phase id = ${_phaseId}");

                         _saveData(context);
                       }

                      },
                      child: const Text("Add Task")),
                  ElevatedButton(
                      style: widget.theme.buttonStyle,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
