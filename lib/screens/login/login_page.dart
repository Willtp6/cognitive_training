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
            backgroundColor: Colors.blue[100],
            appBar: AppBar(
              backgroundColor: Colors.blue[400],
              elevation: 0.0,
              title: const Text('登入'),
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
                      decoration: inputDecoration.copyWith(hintText: '輸入 Id'),
                      validator: (val) => val!.isEmpty ? '不可為空' : null,
                      onChanged: (val) {
                        userId = val;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      height: 50.0,
                      width: 150.0,
                      child: ElevatedButton(
                        style: buttonDecoration,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            isLoading = true;
                            dynamic result =
                                await _auth.loginOrCreateAccountWithId(userId);
                            if (result == null) {
                              setState(() {
                                error = '登入失敗';
                                isLoading = false;
                              });
                            }
                          }
                        },
                        child: const Text(
                          '創建並登入',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      height: 50.0,
                      width: 150.0,
                      child: ElevatedButton(
                        style: buttonDecoration,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            isLoading = true;
                            dynamic result = await _auth.login(userId);
                            if (result == null) {
                              setState(() {
                                error = '登入失敗';
                                isLoading = false;
                              });
                            }
                          }
                        },
                        child: const Text(
                          '登入',
                          style: TextStyle(fontSize: 20),
                        ),
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
