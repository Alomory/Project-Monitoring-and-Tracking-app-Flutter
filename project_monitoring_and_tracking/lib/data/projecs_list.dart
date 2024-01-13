// import 'package:project_monitoring_and_tracking/models/phase.dart';
// import 'package:project_monitoring_and_tracking/models/project.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ProjectList {
//   List<Project> projects = [];
//   final String firebaseUrl =
//       'project-management-d7680-default-rtdb.asia-southeast1.firebasedatabase.app';
//
//
//  void loadProjects() async {
//   final url = Uri.https(firebaseUrl, 'project-list.json');
//   try {
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> projectsData = json.decode(response.body);
//
//       for (final item in projectsData.entries) {
//         List<Phase> phases = [];
//
//         // Check if 'phase' key exists and is a List
//         if (item.value.containsKey('phase') && item.value['phase'] is List) {
//           phases = (item.value['phase'] as List).map<Phase>((phaseData) {
//             return Phase(
//               projectId: item.key,
//               phaseName: phaseData['phaseName'],
//               // Add other properties as needed
//             );
//           }).toList();
//         }
//
//         projects.add(
//           Project.withPhases(
//             user: item.value['user'],
//             projectId: item.key,
//             projectName: item.value['projectName'],
//             projectDescription: item.value['projectDescription'],
//             projectStartDate: DateTime.parse(item.value['projectStartDate']),
//             projectEndDate: DateTime.parse(item.value['projectEndDate']),
//             phase: phases,
//           ),
//         );
//       }
//     } else {
//       print('Failed to load data. Status code: ${response.statusCode}');
//     }
//   } catch (error) {
//     print('Error loading items: $error');
//   }
// }
//
//   List<Project> getDummyProjectList() {
//     return projects;
//   }
//
//   void addProject(Project newProject) async {
//     final url = Uri.https(firebaseUrl, 'project-list.json');
//
//     try {
//       final response = await http.post(
//         url,
//         body: json.encode({
//           'projectName': newProject.projectName,
//           'projectDescription': newProject.projectDescription,
//           'projectStartDate': newProject.projectStartDate.toIso8601String(),
//           'projectEndDate': newProject.projectEndDate.toIso8601String(),
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print('Project added successfully');
//         // You can update the local projects list if needed
//       } else {
//         print('Failed to add project. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error adding project: $error');
//     }
//   }
//
//   void addPhase( Phase phase)async{
//      final url = Uri.https(firebaseUrl, 'project-list/${phase.projectId}/phase.json');
//
//     try {
//       final response = await http.post(
//         url,
//         body: json.encode({
//           'projectId': phase.projectId,
//           'phaseName': phase.phaseName,
//           'taskNo': phase.taskNo,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print('Phase added successfully');
//         // You can update the local projects list if needed
//       } else {
//         print('Failed to add phasse. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error adding phase: $error');
//     }
//   }
//   // Dummy data for testing
//   // static ProjectList getDummyProjectList() {
//   //   return ProjectList(
//   //     projects: [
//   //       Project(
//   //         projectId: '1',
//   //         projectName: 'Project A',
//   //         projectDescription: 'Description for Project A',
//   //         projectStartDate: DateTime(2023, 1, 1),
//   //         projectEndDate: DateTime(2023, 2, 1),
//   //         phase: [
//   //           Phase(projectId: "1", phaseName: "Planning", tasks: [
//   //             Task(
//   //               taskId: '1',
//   //               taskName: 'Task 1',
//   //               taskDescription: 'Description for Task 1',
//   //               dueDate: DateTime(2023, 1, 15),
//   //               isCompleted: false,
//   //               assignedTo: 'user1',
//   //             ),
//   //             Task(
//   //               taskId: '2',
//   //               taskName: 'Task 2',
//   //               taskDescription: 'Description for Task 2',
//   //               dueDate: DateTime(2023, 1, 20),
//   //               isCompleted: true,
//   //               assignedTo: 'user2',
//   //             ),
//   //           ]),
//   //           Phase(projectId: "1", phaseName: "Designing", tasks: [
//   //             Task(
//   //               taskId: '1',
//   //               taskName: 'Task 1',
//   //               taskDescription: 'Description for Task 1',
//   //               dueDate: DateTime(2023, 1, 15),
//   //               isCompleted: false,
//   //               assignedTo: 'user1',
//   //             ),
//   //             Task(
//   //               taskId: '2',
//   //               taskName: 'Task 2',
//   //               taskDescription: 'Description for Task 2',
//   //               dueDate: DateTime(2023, 1, 20),
//   //               isCompleted: true,
//   //               assignedTo: 'user2',
//   //             ),
//   //           ])
//   //         ],
//   //       ),
//   //       // Add more projects as needed
//   //     ],
//   //   );
//   // }
// }
