import 'package:cognitive_training/firebase/auth.dart';
import 'package:flutter/material.dart';
import '../../shared/loading.dart';
import '../../shared/design_type.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String userId = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: const Text('Login'),
            ),
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 60.0),
                    TextFormField(
                      maxLength: 20,
                      decoration:
                          inputDecoration.copyWith(hintText: 'Input Id'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter your user Id' : null,
                      onChanged: (val) {
                        setState(() {
                          userId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      height: 100.0,
                      width: 200.0,
                      child: ElevatedButton(
                        style: buttonDecoration,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            isLoading = true;
                            dynamic result =
                                await _auth.loginOrCreateAccountWithId(userId);
                            if (result == null) {
                              setState(() {
                                error = 'Login failed';
                                isLoading = false;
                              });
                            } else {
                              print("in login $result");
                            }
                          }
                        },
                        child: const Text('register'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
