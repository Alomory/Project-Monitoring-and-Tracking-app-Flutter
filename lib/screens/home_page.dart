import 'package:flutter/material.dart';
import 'package:project_monitoring_and_tracking/data/const.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/models/task.dart';
import 'package:project_monitoring_and_tracking/models/user.dart';
import 'package:project_monitoring_and_tracking/screens/add_project.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_monitoring_and_tracking/screens/information_screen.dart';
import 'package:project_monitoring_and_tracking/screens/userInfo_screen.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';
import 'package:project_monitoring_and_tracking/themes/canvas.dart';

import 'package:project_monitoring_and_tracking/widgets/project_widget.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0; // the current project[index] user is displaying in UI
  List<Project> projects = []; // init for user projects
  List<Widget> _pages = []; // init pages, empty list
  int _selectedIndex = 0; // controller for the pages
  bool _loading = true; // to wait till projects initialized

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

// initialize pages
  void initPages() {
    _pages = [
      ProjectWidget(
        user: widget.user,
        project: projects[currentIndex],
        updateProject: updateProject,
        deleteProject: deleteProject,
      ),
      InformationPage(
          user: widget.user,
          project: projects[currentIndex],
          updateTaskStatus: _updateTaskStatus,
          deleteTask: _deleteTask,
          deletPhase: _deletePhase,
          updatePhase: updatePhase,
          updateTask: updateTask),
      UserInfoPage(user: widget.user, updateUser: updateUserInfo)
    ];
  }

// to change the page index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

// load all data for that user's projects
  void loadProjects() async {
    final url = Uri.https(firebaseUrl, 'project-list.json');
    try {
      setState(() {
        _loading = true;
      });
      final response = await http.get(url);

      List<Project> projectList = [];

      if (response.statusCode == 200) {
        final Map<String, dynamic> projectsData = json.decode(response.body);

        for (final item in projectsData.entries) {
          List<Phase> phases = [];
          if (item.value.containsKey('phase')) {
            Map<String, dynamic> temp = item.value['phase'];

            phases = (temp.entries).map<Phase>((phaseData) {
              List<Task> tasks = [];

              if (phaseData.value.containsKey('tasks')) {
                Map<String, dynamic> tempTasks = phaseData.value['tasks'];

                tasks = tempTasks.entries.map<Task>((taskData) {
                  print(
                      "#Debug home_page.dart => taskName ${taskData.value['taskName']}, phase name = ${phaseData.value['phaseName']}");
                  return Task(
                    taskId: taskData.key,
                    taskName: taskData.value['taskName'],
                    taskDescription: taskData.value['taskDescription'],
                    dueDate: DateTime.parse(taskData.value['dueDate']),
                    taskStatus: taskData.value['isCompleted'],
                    // it may be an int or a string, or you can modify the Task class to handle it properly.
                  );
                }).toList();
              }
              return Phase.withTask(
                phaseId: phaseData.key.toString(),
                phaseDescription:
                    phaseData.value['phaseDescription'].toString(),
                phaseName: phaseData.value['phaseName'].toString(),
                tasks: tasks,
              );
            }).toList();
          }
          print("#Debug home_page.dart => inside the task loop");

          projectList.add(
            Project.withPhases(
              user: item.value['userId'].toString(),
              projectId: item.key.toString(),
              projectName: item.value['projectName'].toString(),
              projectDescription: item.value['projectDescription'].toString(),
              projectStartDate: DateTime.parse(item.value['projectStartDate']),
              projectEndDate: DateTime.parse(item.value['projectEndDate']),
              phase: phases,
            ),
          );
        }

        setState(() {
          projects = projectList.where((element) {
            return element.user == widget.user.userId;
          }).toList();
          initPages();
        });
        setState(() {
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error home_page.dart loading items: $error');
      setState(() {
        _loading = false;
      });
    }
  }

  //Updating task Status
  void _updateTaskStatus(Task task, int status) async {
    //getting the ids of the firebase to update a task status
    int phaseIndex = projects[currentIndex].phase.indexWhere((element) {
      return element.tasks.contains(task);
    });

    int taskIndex = projects[currentIndex]
        .phase[phaseIndex]
        .tasks
        .indexWhere((element) => element.taskId == task.taskId);

    final url = Uri.https(
        firebaseUrl,
        'project-list/${projects[currentIndex].projectId}/phase/'
        '${projects[currentIndex].phase[phaseIndex].phaseId}/tasks/'
        '${projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskId}.json');

    int failUpdate =
        projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskStatus;
    setState(() {
      projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskStatus =
          status;
      initPages();
    });
    try {
      //ref: https://stackoverflow.com/questions/63120142/the-way-of-sending-patch-request-in-flutter
      // PATCH request to update the task status on Firebase
      final response = await http.patch(
        url,
        body: jsonEncode({'isCompleted': status}),
      );
      if (response.statusCode >= 400) {
        setState(() {
          projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskStatus =
              failUpdate;
          initPages();
        });
      }
      print(
          "#Debug home_page.dart => Successfully updated task status on Firebase");
    } catch (error) {
      print(
          "#Error home_page.dart => Error updating task status on Firebase: $error");
      // Handle the error as needed
    }
  }

  // deleting task
  void _deleteTask(Task task, Phase phase) async {
    int phaseIndex = projects[currentIndex]
        .phase
        .indexWhere((element) => element.phaseId == phase.phaseId);
    int taskIndex = projects[currentIndex]
        .phase[phaseIndex]
        .tasks
        .indexWhere((element) => element.taskId == task.taskId);

    setState(() {
      projects[currentIndex]
          .phase[phaseIndex]
          .tasks
          .removeWhere((element) => element.taskId == task.taskId);
      initPages();
      print("#Debug home_page.dart => Item deleted locally");
    });

    try {
      final url = Uri.https(
        firebaseUrl,
        'project-list/${projects[currentIndex].projectId}/phase/${projects[currentIndex].phase[phaseIndex].phaseId}/tasks/${task.taskId}.json',
      );
      // DELETE request to delete a task from firebase

      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print("#Debug home_page.dart => Successfully deleted task on Firebase");
      } else {
        setState(() {
          // Handle the case when the DELETE request fails
          projects[currentIndex]
              .phase[phaseIndex]
              .tasks
              .insert(taskIndex, task);
          initPages();
          print("#Debug home_page.dart => Failed to delete task on Firebase");
        });
      }
    } catch (error) {
      setState(() {
        // Handle other errors
        projects[currentIndex].phase[phaseIndex].tasks.insert(taskIndex, task);
        initPages();
        print(
            "#Error home_page.dart => Error deleting task on Firebase: $error");
      });
    }
  }

// deleting phase
  void _deletePhase(Phase phase) async {
    int phaseIndex = projects[currentIndex]
        .phase
        .indexWhere((element) => element.phaseId == phase.phaseId);

    setState(() {
      projects[currentIndex]
          .phase
          .removeWhere((element) => element.phaseId == phase.phaseId);
      initPages();
      print("#Debug home_page.dart => Phase deleted locally");
    });

    try {
      final url = Uri.https(
        firebaseUrl,
        'project-list/${projects[currentIndex].projectId}/phase/${phase.phaseId}.json',
      );

      // DELETE request to delete a phase from Firebase
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print(
            "#Debug home_page.dart => Successfully deleted phase on Firebase");
      } else {
        setState(() {
          // Handle the case when the DELETE request fails
          projects[currentIndex].phase.insert(phaseIndex, phase);
          initPages();
          print("#Debug home_page.dart => Failed to delete phase on Firebase");
        });
      }
    } catch (error) {
      setState(() {
        // Handle other errors
        projects[currentIndex].phase.insert(phaseIndex, phase);
        initPages();
        print(
            "#Error home_page.dart => Error deleting phase on Firebase: $error");
      });
    }
  }

// updating a phase
  void updatePhase(Phase phase, String phaseName, String description) async {
    int phaseIndex = projects[currentIndex]
        .phase
        .indexWhere((element) => element.phaseId == phase.phaseId);
    setState(() {
      // Check if phaseName and phaseDesc are not null before updating
      if (phaseName != null) {
        projects[currentIndex].phase[phaseIndex].phaseName = phaseName;
      }
      if (description != null) {
        projects[currentIndex].phase[phaseIndex].phaseDescription = description;
      }
      // Print updated values
      print(
          "Debug Updated phaseName: ${projects[currentIndex].phase[phaseIndex].phaseName}");
      print(
          "Debug Updated phaseDesc: ${projects[currentIndex].phase[phaseIndex].phaseDescription}");
      initPages();
    });

    try {
      // Update request to update a phase in Firebase
      final url = Uri.https(firebaseUrl,
          'project-list/${projects[currentIndex].projectId}/phase/${phase.phaseId}.json');

      final response = await http.patch(url,
          body: jsonEncode({
            'phaseName': phaseName,
            'phaseDescription': description,
            // Add more fields to update in Firebase as needed
          }));

      if (response.statusCode >= 400) {
        // Handle the case when the PATCH request fails
        setState(() {
          // Rollback the local changes if the update fails
          projects[currentIndex].phase[phaseIndex].phaseName = phase.phaseName;
          projects[currentIndex].phase[phaseIndex].phaseDescription =
              phase.phaseDescription;
          initPages();
        });
      }
    } catch (error) {
      // Handle the error as needed
      print(
          "#Error home_page.dart => Error updating phase on Firebase: $error");
    }
  }

  // update task
  void updateTask(Phase phase, Task task, String name, String desc,
      DateTime duedate, int newStatus) async {
    int phaseIndex = projects[currentIndex]
        .phase
        .indexWhere((element) => element.phaseId == phase.phaseId);
    int taskIndex = projects[currentIndex]
        .phase[phaseIndex]
        .tasks
        .indexWhere((element) => element.taskId == task.taskId);
    String failName =
        projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskName;
    String failDesc = projects[currentIndex]
        .phase[phaseIndex]
        .tasks[taskIndex]
        .taskDescription;
    DateTime failDue =
        projects[currentIndex].phase[phaseIndex].tasks[taskIndex].dueDate;
    int failStatus =
        projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskStatus;

    // update the task locally
    setState(() {
      projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskName = name;
      projects[currentIndex]
          .phase[phaseIndex]
          .tasks[taskIndex]
          .taskDescription = desc;
      projects[currentIndex].phase[phaseIndex].tasks[taskIndex].dueDate =
          duedate;
      projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskStatus =
          newStatus;
      initPages();
      print("Debug Updated taskName: ${task.taskName}");
      print("Debug Updated taskStatus: ${task.taskStatus}");
    });

    try {
      // Update request to update a task in Firebase
      final url = Uri.https(firebaseUrl,
          'project-list/${projects[currentIndex].projectId}/phase/${phase.phaseId}/tasks/${task.taskId}.json');

      final response = await http.patch(url,
          body: jsonEncode({
            'taskName': name,
            'taskDescription': desc,
            'isCompleted': newStatus,
            'dueDate': duedate.toIso8601String(),
          }));
      if (response.statusCode >= 400) {
        // Handle the case when the PATCH request fails
        setState(() {
          // Rollback the local changes if the update fails
          projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskName =
              failName;
          projects[currentIndex]
              .phase[phaseIndex]
              .tasks[taskIndex]
              .taskDescription = failDesc;
          projects[currentIndex].phase[phaseIndex].tasks[taskIndex].dueDate =
              failDue;
          projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskStatus =
              failStatus;
          initPages();
        });
      }
      print("#Debug home_page.dart => Successfully updated task on Firebase");
    } catch (error) {
      print("#Error home_page.dart => Error updating task on Firebase: $error");
      setState(() {
        // error change the local if the update fails
        projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskName =
            failName;
        projects[currentIndex]
            .phase[phaseIndex]
            .tasks[taskIndex]
            .taskDescription = failDesc;
        projects[currentIndex].phase[phaseIndex].tasks[taskIndex].dueDate =
            failDue;
        projects[currentIndex].phase[phaseIndex].tasks[taskIndex].taskStatus =
            failStatus;
        initPages();
      });
    }
  }

// deleting project from firebase
  void deleteProject(Project project) async {
    // Save the project and index before removing it
    Project failedProject = project;
    int index = currentIndex;
    try {
      final url = Uri.https(
        firebaseUrl,
        'project-list/${project.projectId}.json',
      );

      // DELETE request to delete a project from Firebase
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          projects.remove(project);
          currentIndex = 0;
          initPages();
        });
        print(
            "#Debug home_page.dart => Successfully deleted project on Firebase");
      } else {
        setState(() {
          // Revert the changes in case of failure
          projects.insert(index, failedProject);
          initPages();
          print(
              "#Debug home_page.dart => Failed to delete project on Firebase");
        });
      }
    } catch (error) {
      // Handle other errors
      setState(() {
        // Revert the changes in case of an error
        projects.insert(index, failedProject);
        initPages();
        print(
            "#Error home_page.dart => Error deleting project on Firebase: $error");
      });
    }
  }

  // updating project from firebase
  void updateProject(Project project, String name, String desc, DateTime start,
      DateTime end) async {
    Project failProject = project;
    setState(() {
      projects[currentIndex].projectName = name;
      projects[currentIndex].projectDescription = desc;
      projects[currentIndex].projectStartDate = start;
      projects[currentIndex].projectEndDate = end;
      initPages();
    });

    try {
      // Update request to update a project in Firebase
      final url = Uri.https(
          firebaseUrl, 'project-list/${projects[currentIndex].projectId}.json');

      final response = await http.patch(url,
          body: jsonEncode({
            'projectName': name,
            'projectDescription': desc,
            'projectStartDate': start.toIso8601String(),
            'projectEndDate': end.toIso8601String(),
            // Add more fields to update in Firebase as needed
          }));

      if (response.statusCode >= 400) {
        // Handle the case when the PATCH request fails
        setState(() {
          // Rollback the local changes if the update fails
          projects[currentIndex].projectName = failProject.projectName;
          projects[currentIndex].projectDescription =
              failProject.projectDescription;
          projects[currentIndex].projectStartDate =
              failProject.projectStartDate;
          projects[currentIndex].projectEndDate = failProject.projectEndDate;
          initPages();
        });
      }
    } catch (error) {
      // Handle the error as needed
      print(
          "#Error home_page.dart => Error updating phase on Firebase: $error");
    }
  }

  // update user info
  void updateUserInfo(String username , String email, String password) async{
    final url = Uri.https(firebaseUrl, "users/${widget.user.userId}.json");
    String failName = widget.user.displayName;
    String failEmail = widget.user.email ;
    String failPassword =  widget.user.password ;

    try{
      final response = await http.patch(url,
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password, // Add more fields to update in Firebase as needed
          }));
      if (response.statusCode >= 400) {
        setState(() {
          widget.user.displayName = failName;
          widget.user.email = failEmail;
          widget.user.password = failPassword;
          initPages();
        });
      }else{
        setState(() {
          widget.user.displayName = username;
          widget.user.email = email;
          widget.user.password = password;
          initPages();
        });
        print("#Debug home_page.dart => user updated");
      }
    }catch (error){
      setState(() {
        widget.user.displayName = failName;
        widget.user.email = failEmail;
        widget.user.password = failPassword;
        initPages();
      });
      print("#Debug home_page.dart => error(update user) $error");
    }

  }

  // build widget starting
  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    Widget content =
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: const BoxDecoration(),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: theme.blueDark,
            ),
            children: const [
              TextSpan(text: 'Click '),
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(Icons.add),
                ),
              ),
              TextSpan(text: ' add Project'),
            ],
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () async {
          Project? newProject = await Navigator.push<Project>(
            context,
            MaterialPageRoute(
                builder: (context) => AddProject(
                      user: widget.user,
                    )),
          );
          // debug
          if (newProject != null) {
            // Project added successfully
            print("#Debug home_page.dart => project added");
            setState(() {
              currentIndex = projects.length;
              projects.add(newProject);
              initPages();
            });
          } else {
            // Failed to add project
            print("#Debug home_page.dart => failed to add project");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add project.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        child: Container(
          decoration: theme.cardBodyDecoration,
          width: MediaQuery.of(context).size.width * .5,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Project",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: theme.veryLight),
              ),
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.add,
                color: theme.veryLight,
              )
            ],
          ),
        ),
      ),
    ]);

    if (_loading) {
      content = Container(
        decoration: theme.boxDecorationWithBackgroudnImage,
        child: Center(
          child: CircularProgressIndicator(
            color: theme.blueLight,
          ),
        ),
      );
    }

    if (projects.isNotEmpty) {
      content = _pages[_selectedIndex];
    }
    print("#Debug home_page.dart => project index= $currentIndex");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //ref: https://stackoverflow.com/questions/62706950/how-to-make-curved-bottom-appbar-in-flutter
      appBar: AppBar(
        toolbarHeight: 80.0,
        elevation: 0.0,
        backgroundColor: theme.blueDark,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.sort,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),

        flexibleSpace: Image(
          opacity: const AlwaysStoppedAnimation(.2),
          image: AssetImage('assets/images/arabic.jpg'),
          fit: BoxFit.cover,
        ),
        // leading: Icon(Icons.sort, color: Colors.white,),

        title: Text(
          "Dashboard",
          style:
              theme.titleStyle.copyWith(fontSize: 24, color: theme.veryLight),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                loadProjects();
              },
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ))
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white.withOpacity(0.9),
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                    color: theme.blueDark,
                    image: const DecorationImage(
                        fit: BoxFit.cover,
                        opacity: 0.3,
                        image: AssetImage(
                          'assets/images/arabic.jpg',
                        ))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person,
                      size: 32,
                      color: theme.veryLight,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.user.displayName.toString().toUpperCase(),
                      style: theme.titleStyle.copyWith(color: theme.veryLight),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                      color: theme.blueMeium.withOpacity(.7),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: ListTile(
                    title: Text(
                      'Home',
                      style:
                          theme.subtitleStyle.copyWith(color: theme.veryLight),
                    ),
                    trailing: Icon(
                      Icons.home,
                      color: theme.veryLight,
                    ),
                    // selected: _selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              !_loading
                  ? Container(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: theme.blueMeium.withOpacity(.7),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: ExpansionTile(
                          //ref: https://stackoverflow.com/questions/62667990/how-to-remove-the-divider-lines-of-an-expansiontile-when-expanded-in-flutter
                          shape: Border(),
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          title: Text(
                            "Projects",
                            style: theme.subtitleStyle
                                .copyWith(color: theme.veryLight),
                          ),

                          children: projects.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final Project project = entry.value;

                            return ListTile(
                              title: Text(
                                project.projectName,
                                style: theme.subtitleStyle
                                    .copyWith(color: theme.veryLight),
                              ),
                              selected: index == currentIndex ? true : false,
                              subtitle: Text(
                                project.projectDescription,
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Icon(
                                Icons.ads_click,
                                color: Colors.white,
                              ),
                              onTap: () {
                                // Set the selected index to the tapped index
                                setState(() {
                                  currentIndex = index;
                                  initPages();
                                });
                                Navigator.of(context).pop();

                                // Your other onTap logic here
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text(
                        "Projects",
                        style: theme.subtitleStyle
                            .copyWith(color: theme.veryLight),
                      ),
                      trailing: const CircularProgressIndicator(),
                    ),
              Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: projects.isEmpty
                      ? theme.cardBodyDecoration
                      : BoxDecoration(
                          color: theme.blueMeium.withOpacity(.7),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: ListTile(
                    title: Text(
                      "Create Project",
                      style:
                          theme.subtitleStyle.copyWith(color: theme.veryLight),
                    ),
                    trailing: Icon(
                      Icons.add,
                      color: theme.veryLight,
                    ),
                    onTap: () async {
                      Project? newProject = await Navigator.push<Project>(
                          context, MaterialPageRoute(builder: (ctx) {
                        return AddProject(user: widget.user);
                      }));
                      if (newProject != null) {
                        print("#Debug home_page.dart => project added");
                        print(
                            "#Debug home_page.dart => project name = ${newProject.projectName}");
                        setState(() {
                          currentIndex = projects.length;
                          projects.add(newProject);
                        });
                      } else {
                        print("#Debug home_page.dart => failed to add project");
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                      color: theme.blueMeium.withOpacity(.7),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: ListTile(
                    title: Text(
                      "Logout",
                      style:
                          theme.subtitleStyle.copyWith(color: theme.veryLight),
                    ),
                    trailing: Icon(
                      Icons.logout,
                      color: theme.veryLight,
                    ),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (route) => false);
                    },
                  ),
                ),
              )
            ]),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: content),
            ),
          ),
          CustomPaint(
            painter: AppBarPainter(),
            child: Container(height: 0),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        // type: BottomNavigationBarType.shifting,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'User Info',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.blueMeium,
        onTap: _onItemTapped,
      ),
    );
  }
}

