import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/models/user.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';
import 'package:project_monitoring_and_tracking/themes/canvas.dart';

class AddProject extends StatefulWidget {
 final User user;

  const AddProject({super.key, required this.user});

  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  late Project newProject;
  final TextEditingController _proNameController = TextEditingController();
  final TextEditingController _proDesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now().add(Duration(days: 90));

  void _startDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: _startDate,
            lastDate: DateTime.now().add(const Duration(days: 60)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _startDate = pickedDate;
      });
    });

  }
  void _endDatePicker() {
    showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: _startDate,
        lastDate: _startDate.add(const Duration(days: 60)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _endDate = pickedDate;
      });
    });
  }

  void _addProject()async {
    final String firebaseUrl =
        'project-management-d7680-default-rtdb.asia-southeast1.firebasedatabase.app';
    final url = Uri.https(firebaseUrl, 'project-list.json');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
                'userId':widget.user.userId,
              'projectName': _proNameController.text,
              'projectDescription': _proDesController.text,
              'projectStartDate': _startDate.toIso8601String(),
              'projectEndDate': _endDate.toIso8601String()
            },
          ));
      if (response.statusCode == 200) {
          Map<String, dynamic> tempProject = json.decode(response.body);
          print("#Debug home_page.dart => testing: ${tempProject['name']}");

          newProject =
            Project.withoutPhases(
              user: widget.user.userId,
              projectId: tempProject['name'].toString(),
              projectName: _proNameController.text,
              projectDescription: _proDesController.text,
              projectStartDate: _startDate,
              projectEndDate: _endDate,
            );
          print("#Debug home_page.dart => testing: ${newProject.projectName}");
          if (newProject != null) {
            Navigator.pop(context, newProject);
          }
      } else {
        print('Failed to add data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;

    return Scaffold(
        appBar: AppBar(

          toolbarHeight: 80.0,
          elevation: 0.0,
          backgroundColor: theme.blueDark,
          flexibleSpace: Image(
            opacity: const AlwaysStoppedAnimation(.2),
            image: AssetImage('assets/images/arabic.jpg'),
            fit: BoxFit.cover,
          ),
          title:  Text("Create Project" ,style:
          theme.titleStyle.copyWith(fontSize: 24, color: theme.veryLight),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              );
            },
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // Input field for adding new project
                    TextFormField(
                      controller: _proNameController,
                      decoration: const  InputDecoration(
                        labelText: 'Project Name',
                      ),
                      validator: (value) {
                        if(value!.isEmpty || value == null){
                          return "Project Name is really important";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _proDesController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if(value!.isEmpty || value == null){
                          return "Project Description is also important";
                        }
                        return null;
                      },
                    ),

                    Container(
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: Text("Start Date: " ,style:
                            theme.subtitleStyle.copyWith(color: theme.blueDark),),
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
                              child: Text(_startDate == null
                                  ? "Choose Date"
                                  : DateFormat.yMd().format(_startDate)))
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text("Expected end Date: ", style:
                              theme.subtitleStyle.copyWith(color: theme.blueDark),
                              )),
                          TextButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(theme.veryLight),
                                  foregroundColor: MaterialStatePropertyAll(theme.blueDark)
                              ),
                              onPressed: _endDatePicker,
                              child: Text(_endDate == null
                                  ? "Choose Date"
                                  : DateFormat.yMd().format(_endDate)))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    // Button to add a new project
                    ElevatedButton(
                      style: theme.buttonStyle,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addProject();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Project Created')),
                          );
                          return;
                        }

                        },
                      child: Text('Create Project'),
                    ),
                  ],
                ),
              ),
            ),
            CustomPaint(
            painter: AppBarPainter(),
      child: Container(height: 0),)
          ],
        ));
  }
}
