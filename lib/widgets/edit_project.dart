import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';

class EditProject extends StatefulWidget {
  final Project project;
  final Function updateProject;

  const EditProject(
      {super.key, required this.project, required this.updateProject});

  @override
  State<EditProject> createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  late TextEditingController projectName, projectDesc;
  late DateTime startDate, endDate;

  final _formKey = GlobalKey<FormState>();

  void _startDatePicker() {
    showDatePicker(
            context: context,
            initialDate: startDate,
            firstDate: startDate,
            lastDate: startDate.add(const Duration(days: 60)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        startDate = pickedDate;
      });
    });
  }

  void _endDatePicker() {
    showDatePicker(
            context: context,
            initialDate: endDate,
            firstDate: startDate,
            lastDate: endDate.add(const Duration(days: 60)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        endDate = pickedDate;
      });
    });
  }

  @override
  void initState() {
    projectName = TextEditingController(text: widget.project.projectName);
    projectDesc =
        TextEditingController(text: widget.project.projectDescription);
    startDate = widget.project.projectStartDate;
    endDate = widget.project.projectEndDate;
    super.initState();
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
            children: [
              Text(
                "Project Details",
                style: theme.titleStyle.copyWith(color: theme.blueDark),
              ),
              Divider(),
              SizedBox(
                height: 25,
              ),
              TextFormField(
                controller: projectName,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Project Name can not be empty";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: projectDesc,
                decoration:
                    const InputDecoration(labelText: 'Project Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Project Description can not be empty";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20,),
              Container(
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Text(
                        "Start Date: ",
                        style:
                            theme.subtitleStyle.copyWith(color: theme.blueDark),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(theme.veryLight),
                          foregroundColor: MaterialStatePropertyAll(theme.blueDark)
                        ),
                        onPressed: _startDatePicker,
                        child: Text(startDate == null
                            ? "Choose Date"
                            : DateFormat.yMd().format(startDate)))
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        "Expected end Date: ",
                        style:
                            theme.subtitleStyle.copyWith(color: theme.blueDark),
                      ),
                    ),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(theme.veryLight),
                            foregroundColor: MaterialStatePropertyAll(theme.blueDark)
                        ),                        onPressed: _endDatePicker,
                        child: Text(endDate == null
                            ? "Choose Date"
                            : DateFormat.yMd().format(endDate)))
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: theme.buttonStyle,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.updateProject(
                              widget.project,
                              projectName.text,
                              projectDesc.text,
                              startDate,
                              endDate
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Project Updated')),
                          );
                        }

                      },
                      child: const Text('Update')),
                  TextButton(
                      style: theme.buttonStyle,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'))
                ],
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
