import 'package:flutter/material.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';
import '../models/user.dart';

class UserInfoPage extends StatefulWidget {
  final Function updateUser;
  final User user;

  const UserInfoPage({Key? key, required this.user, required this.updateUser})
      : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfoPage> {
  late TextEditingController _usernameEditingController;
  late TextEditingController _emailEditingController;
  late TextEditingController _passwordEditingController;

  bool isEditing = false;
  Icon myIcon = Icon(
    Icons.edit,
    size: 20,
  );

  @override
  void initState() {
    super.initState();
    _usernameEditingController =
        TextEditingController(text: widget.user.displayName);
    _emailEditingController = TextEditingController(text: widget.user.email);
    _passwordEditingController =
        TextEditingController(text: widget.user.password);
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Card(
        elevation: 4,
        semanticContainer: true,
        color: theme.veryLight,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "User Information",
                    style: theme.titleStyle.copyWith(
                        fontWeight: FontWeight.bold, color: theme.blueDark),
                  ),
                  SizedBox(width: 30,),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.blueDark),
                    child: IconButton(
                      color: theme.veryLight,
                      onPressed: () {
                        if(!isEditing){
                          setState(() {
                            isEditing = true;
                            myIcon = Icon(Icons.cancel);
                          });
                        }else{
                          setState(() {
                            isEditing = false;
                            myIcon = Icon(Icons.edit);
                          });
                        }


                      },
                      icon: myIcon,
                    ),
                  )
                ],
              ),
              Divider(),
              SizedBox(height: 20),
              TextFormField(
                enabled: isEditing,
                controller: _usernameEditingController,
                decoration: InputDecoration(
                  label: Text('Username'),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                enabled: false,
                controller: _emailEditingController,
                decoration: InputDecoration(
                  label: Text('Email'),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                enabled: isEditing,
                controller: _passwordEditingController,
                decoration: InputDecoration(
                  label: Text("Password"),
                ),
              ),
              SizedBox(height: 30),
              if (isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: theme.buttonStyle,
                      onPressed: () {
                        // Implement your update logic
                        setState(() {
                          // Update the value and exit editing mode
                          // value = controller.text;
                          isEditing = false;
                          setState(() {
                            widget.updateUser(
                                _usernameEditingController.text,
                                _emailEditingController.text,
                                _passwordEditingController.text);
                          });
                        });
                      },
                      child: Text('Update'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: theme.buttonStyle,
                      onPressed: () {
                        // Cancel editing and exit editing mode
                        setState(() {
                          isEditing = false;
                          myIcon = Icon(Icons.edit);
                        });
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                )
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}
