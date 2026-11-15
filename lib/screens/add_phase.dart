import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_monitoring_and_tracking/data/const.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';

class AddPhase extends StatefulWidget {
  final Project currentProject;
  final Function addPhase;
  final AppTheme theme;
  static final GlobalKey<FormState>  _phaseFormKey = GlobalKey<FormState>();

  AddPhase(
      {super.key,
      required this.currentProject,
      required this.addPhase,
      required this.theme});

  @override
  State<AddPhase> createState() => _AddPhaseState();
}

class _AddPhaseState extends State<AddPhase> {
  final TextEditingController _phaseNameController = TextEditingController();

  final TextEditingController _phaseDescController = TextEditingController();

  String name = '', description = '';

  void _saveData(context) async {
    if (AddPhase._phaseFormKey.currentState!.validate()) {
      AddPhase._phaseFormKey.currentState!.save();

      final url = Uri.https(
          firebaseUrl, "project-list/${widget.currentProject.projectId}/phase.json");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'phaseName': name,
            'phaseDescription': description,
          },
        ),
      );

      if (response.statusCode == 200) {
        print(
            "Debug add_phase.dart => response body = ${response.body} ${response.statusCode}");
        final Map<String, dynamic> data = json.decode(response.body);
        print("Debug add_phase.dart => phase id = ${data['name']}");

        widget.addPhase(Phase(
            phaseId: data['name'],
            phaseName: name, // Use the saved values
            phaseDescription: description));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phase Added')),
        );
        Navigator.pop(context);
      } else {
        // Error message
        print('Failed to add phase. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          key: AddPhase._phaseFormKey,
          child: Column(
            children: [
              Text(
                'Add Phase',
                style: widget.theme.titleStyle.copyWith(color: widget.theme.blueDark),
              ),
              TextFormField(
                controller: _phaseNameController,
                keyboardType: TextInputType.text,
                decoration:
                    const InputDecoration(hintText: "Enter the phase name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid phase name';
                  }
                  return null; // Validation passed
                },
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _phaseDescController,
                style: widget.theme.hintStyle.copyWith(fontSize: 16),
                decoration: const InputDecoration(
                    hintText: "Enter any description you want"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid phase name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: widget.theme.buttonStyle,
                      onPressed: () {
                        if (AddPhase._phaseFormKey.currentState!.validate()) {
                          name = _phaseNameController.text;
                          description = _phaseDescController.text;
                          _saveData(context);
                        }
                      },
                      child: const Text(
                        "Add Phase",
                      )),
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
