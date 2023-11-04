import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/constants/login_page_const.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:cognitive_training/shared/button_with_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
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
  String userName = '';
  String error = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(LoginPageConst.loginBackground),
              fit: BoxFit.fitWidth,
            ),
          ),
          child: SingleChildScrollView(
            //* set for dismiss keyboard when drag event
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: SizedBox(
              height: height - MediaQuery.of(context).padding.top,
              width: width,
              child: Stack(
                children: [
                  // main block of login
                  loginBlock(height, width),
                  loginLogo(),
                  // loading animation
                  if (isLoading)
                    const SpinKitCircle(
                      color: Colors.blue,
                      duration: Duration(milliseconds: 1500),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Align loginBlock(double height, double width) {
    return Align(
      alignment: const Alignment(0.0, 0.5),
      child: FractionallySizedBox(
        heightFactor: 0.7,
        widthFactor: 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
                Radius.elliptical(width * 0.5 * 0.1, height * 0.7 * 0.1)),
          ),
          child: FractionallySizedBox(
            heightFactor: 0.9,
            widthFactor: 0.9,
            child: getLoginForm(),
          ),
        ),
      ),
    );
  }

  Align loginLogo() {
    return Align(
      alignment: const Alignment(0.0, -0.9),
      child: FractionallySizedBox(
        heightFactor: 0.3,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(LoginPageConst.loginLogo),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoginForm() {
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          // login label
          const Align(
            alignment: Alignment(0.0, -0.7),
            child: FractionallySizedBox(
              heightFactor: 0.1,
              child: AutoSizeText(
                '使用者登入',
                style: TextStyle(
                  fontSize: 100,
                  fontFamily: 'GSR_B',
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, -0.3),
            child: FractionallySizedBox(
              heightFactor: 0.3,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Image.asset(
                        LoginPageConst.loginId,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 4,
                    child: Center(
                      child: AutoSizeText(
                        '使用者編號',
                        maxLines: 1,
                        style: TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: TextFormField(
                        decoration: inputDecoration.copyWith(
                          hintText: '輸入編號',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        validator: (val) => val!.isEmpty ? '不可為空' : null,
                        onChanged: (val) {
                          userId = val;
                        },
                        onEditingComplete: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 0.5),
            child: FractionallySizedBox(
              heightFactor: 0.3,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      LoginPageConst.loginUsername,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Expanded(
                    flex: 4,
                    child: AutoSizeText(
                      '使用者姓名',
                      maxLines: 1,
                      style: TextStyle(fontSize: 100),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: TextFormField(
                      decoration: inputDecoration.copyWith(
                        hintText: '輸入姓名',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (val) => val!.isEmpty ? '不可為空' : null,
                      onChanged: (val) {
                        userName = val;
                      },
                      onEditingComplete: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 1.0),
            child: FractionallySizedBox(
              heightFactor: 0.2,
              child: ButtonWithText(
                text: '登入',
                onTapFunction: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    //dynamic result = await _auth.login(userId);
                    dynamic result = await _auth.loginOrCreateAccountWithId(
                        userId, userName);

                    if (result.runtimeType != String) {
                      String errorMessage;
                      if (result.code == 'user-not-found') {
                        errorMessage = '帳號不存在';
                      } else if (result.code == 'wrong-password') {
                        errorMessage = '姓名錯誤';
                      } else if (result.code == 'network-request-failed') {
                        errorMessage = '網路錯誤';
                      } else {
                        errorMessage = '未知錯誤';
                      }
                      setState(() {
                        isLoading = false;
                      });
                      _showAlertDialog(errorMessage);
                    }
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showAlertDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('登入錯誤')),
          // this part can put multiple messages
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(child: Text(errorMessage)),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text('好的'),
                onPressed: () {
                  GoRouter.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
