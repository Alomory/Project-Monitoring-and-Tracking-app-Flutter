import 'package:flutter/material.dart';
import 'package:project_monitoring_and_tracking/models/phase.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';

class EditPhase extends StatefulWidget {
  final Phase phase;
  final Function updatePhase;

  const EditPhase({
    Key? key,
    required this.phase,
    required this.updatePhase,
  }) : super(key: key);

  @override
  _EditPhaseState createState() => _EditPhaseState();
}

class _EditPhaseState extends State<EditPhase> {
  late TextEditingController phaseNameController;
  late TextEditingController descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the phase values
    phaseNameController = TextEditingController(text: widget.phase.phaseName);
    descriptionController = TextEditingController(text: widget.phase.phaseDescription);
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
                'Update Phase',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phaseNameController,
                decoration: const InputDecoration(labelText: 'Phase Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phase Name can not be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phase Description'),
                controller: descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phase Description can not be empty as well";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
                        widget.updatePhase(widget.phase, phaseNameController.text, descriptionController.text);
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
