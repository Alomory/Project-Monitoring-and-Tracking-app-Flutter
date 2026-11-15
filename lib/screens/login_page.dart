import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_monitoring_and_tracking/data/const.dart';
import 'package:project_monitoring_and_tracking/models/user.dart';
import 'package:project_monitoring_and_tracking/screens/home_page.dart';
import 'package:project_monitoring_and_tracking/screens/signup_page.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<User> users = [];
  String _email = '';
  String _password = '';
  String _error = '';
  bool _hidePassword = true;
  bool loading = false;


  void _loginUser()async{
    final url = Uri.https(firebaseUrl, 'users.json');
    try {
      setState(() {
        loading = true;
      });
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> usersJson = json.decode(response.body);

        for (final tempUsers in usersJson.entries) {



          users.add(
            User(
                userId: tempUsers.key.toString(),
                displayName: tempUsers.value['username'].toString(),
                email: tempUsers.value['email'].toString(),
                password: tempUsers.value['password'].toString()),
          );
          print(
              "#Debug login_page.dart -> key for users = ${tempUsers.value['username']}");

        }
      } else {
        setState(() => loading = false);
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() => loading = false);
      print('Error login_page.dart loading items: $error');
    }
    late User registeredUser;
    bool checkLogin = false;
    if(users.isNotEmpty){
      for(final tempUser in users){
        if(tempUser.email == _email && tempUser.password == _password){
          registeredUser = tempUser;
          checkLogin = true;
        }
      }
    }
    if(checkLogin){
      setState(() {
        loading = false;
      });
      print("#Debug Login_page.dart=>  user Loged in");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (ctx){
            return HomePage(user: registeredUser);
          }), (route) => false);
    }else{
      setState(() => loading = false);
      print( "#Debug login_page.dart -> User is not in the database");

    }
  }
  Widget _buildEmailTF(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Email', style: theme.subtitleStyle),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: theme.textFieldDecoration,
          height: 60.0,
          child: TextFormField(
            onChanged: (value) => setState(() {
              _email = value;
            }),
            controller: _emailController,
            validator: (val) => val == null ||
                    val.isEmpty
                // ||!RegExp(r"^[A-Za-z0-9._%+-]+@pitt\.edu$").hasMatch(val)
                ? 'Please enter valid email.'
                : null,
            keyboardType: TextInputType.emailAddress,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
                border: InputBorder.none,
                // contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(Icons.email, color: theme.blueDark),
                hintText: 'Enter your Email',
                hintStyle: theme.hintStyle),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Password', style: theme.subtitleStyle),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: theme.textFieldDecoration,
          height: 60.0,
          child: TextFormField(
            onChanged: (value) => setState(() {
              _password = value.trim();
            }),
            controller: _passwordController,
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter valid password' : null,
            obscureText: _hidePassword,
            decoration: InputDecoration(
                border: InputBorder.none,
                // contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(Icons.lock, color: theme.blueDark),
                suffixIcon: IconButton(
                  icon: Icon(
                      color: theme.blueDark,
                      _hidePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () async {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
                hintText: 'Enter your Password',
                hintStyle: theme.hintStyle),
          ),
        ),
      ],
    );
  }

Widget _buildLoginBtn(
      AppTheme theme, bool loading, 
      // AuthService authService
      ) {
    return Container(
            padding: EdgeInsets.symmetric(vertical: 25.0),
            child: Container(
              decoration: loading?
                  BoxDecoration()
                  :theme.cardBodyDecoration,
              child: loading?CircularProgressIndicator(
                color: theme.blueDark,
              ):TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    _email = _emailController.text;
                    _password = _passwordController.text;
                    _loginUser();
                  }
                },
                child: Text('LOGIN', style: theme.titleStyle),
              ),
            ),
          );
  }
  

  
  Widget _buildSignupBtn(AppTheme theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignUpPage()),
  );
      }
      // => routePage(SignUpPage(), context)
      ,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: 'Don\'t have an Account? ', style: theme.regularStyle.copyWith(color: theme.veryLight)),
            TextSpan(
                text: 'Sign Up',
                style:
                    theme.regularStyle.copyWith(fontWeight: FontWeight.bold, color: theme.veryLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMsg(AppTheme theme) => Text(_error,
      style: theme.regularStyle.copyWith(color: Colors.red),
      textAlign: TextAlign.center);

  Widget _buildSpacing() => const SizedBox(height: 30);

  Widget _buildTitle(AppTheme theme) =>
      Text('Sign In', style: theme.titleStyle.copyWith(fontSize: 40));

  @override
  Widget build(BuildContext context) {
    // final AuthService authService = Provider.of<AuthService>(context);
    final AppTheme theme =
        Theme.of(context).extension<AppTheme>()!;
    //const Widget spacing = SizedBox(height: 30);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                  height: double.infinity,
                  width: double.infinity,

                  // move to theme
                  decoration: theme.boxDecorationWithBackgroudnImage),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 120.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildTitle(theme),
                          _buildSpacing(),
                          _buildEmailTF(theme),
                          _buildSpacing(),
                          _buildPasswordTF(theme),
                          // _buildForgotPasswordBtn(theme),
                          _buildErrorMsg(theme),
                          _buildLoginBtn(theme, loading,),
                          // _buildSocialBtnRow(theme, authService),
                          _buildSignupBtn(theme),
                        ],
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}