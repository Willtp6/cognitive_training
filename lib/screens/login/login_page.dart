import 'package:auto_size_text/auto_size_text.dart';
import 'package:cognitive_training/firebase/auth.dart';
import 'package:cognitive_training/screens/login/login_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../shared/design_type.dart';
import 'package:dotted_border/dotted_border.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final LoginTutorial _loginTutorial = LoginTutorial();

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
        body: SingleChildScrollView(
          child: Container(
            height: height - MediaQuery.of(context).padding.top,
            width: width,
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: _loginTutorial.isTutorial ? 0.3 : 1,
                image:
                    const AssetImage('assets/global/login_background_1.jpeg'),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Stack(
              children: [
                // main block of login
                loginBlock(height, width),
                // masked of login
                if (_loginTutorial.isTutorial &&
                    _loginTutorial.tutorialProgress < 1)
                  _loginTutorial.mask(width, height),
                loginLogo(),
                _loginTutorial.tutorialDoctor(),
                _loginTutorial.chatBubble(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_loginTutorial.tutorialProgress < 5) {
                        _loginTutorial.tutorialProgress++;
                      } else {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _loginTutorial.tutorialProgress = 0;
                        });
                        _loginTutorial.isTutorial = false;
                      }
                    });
                  },
                  child: _loginTutorial.getContinueButton(),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _loginTutorial.isTutorial = true;
                    });
                  },
                  child: _loginTutorial.tutorialButton(),
                ),
                if (_loginTutorial.isTutorial &&
                    _loginTutorial.tutorialProgress >= 3)
                  _loginTutorial.hintArrow(),
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
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: _loginTutorial.isTutorial &&
                        _loginTutorial.tutorialProgress < 1
                    ? 0.3
                    : 1,
                image: const AssetImage('assets/login_page/login_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  AnimatedOpacity tutorialButton() {
    return AnimatedOpacity(
      opacity: _loginTutorial.isTutorial ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _loginTutorial.isTutorial = true;
            });
          },
          child: FractionallySizedBox(
            widthFactor: 0.15,
            child: AspectRatio(
              aspectRatio: 578 / 236,
              child: Image.asset('assets/login_page/tutorial_button.png'),
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
              child: DottedBorder(
                color: _loginTutorial.isTutorial &&
                        _loginTutorial.tutorialProgress == 3
                    ? Colors.red
                    : Colors.white.withOpacity(0),
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                strokeWidth: 2,
                dashPattern: const [8, 4],
                padding: const EdgeInsets.all(5),
                borderPadding: const EdgeInsets.symmetric(vertical: 1),
                strokeCap: StrokeCap.round,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Image.asset(
                          'assets/login_page/login_id.png',
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
                          enabled: !_loginTutorial.isTutorial,
                          decoration: inputDecoration.copyWith(
                            hintText: '輸入編號',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          validator: (val) => val!.isEmpty ? '不可為空' : null,
                          onChanged: (val) {
                            userId = val;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 0.5),
            child: FractionallySizedBox(
              heightFactor: 0.3,
              child: DottedBorder(
                color: _loginTutorial.isTutorial &&
                        _loginTutorial.tutorialProgress == 4
                    ? Colors.red
                    : Colors.white.withOpacity(0),
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                strokeWidth: 2,
                dashPattern: const [8, 4],
                padding: const EdgeInsets.all(5),
                borderPadding: const EdgeInsets.symmetric(vertical: 1),
                strokeCap: StrokeCap.round,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Image.asset(
                        'assets/login_page/login_username.png',
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
                        enabled: !_loginTutorial.isTutorial,
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, 1.0),
            child: FractionallySizedBox(
              heightFactor: 0.2,
              child: GestureDetector(
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (!_loginTutorial.isTutorial &&
                      _formKey.currentState!.validate()) {
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
                child: DottedBorder(
                  color: _loginTutorial.isTutorial &&
                          _loginTutorial.tutorialProgress == 5
                      ? Colors.red
                      : Colors.white.withOpacity(0),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  padding: const EdgeInsets.all(3),
                  borderPadding: const EdgeInsets.symmetric(vertical: 1),
                  strokeCap: StrokeCap.round,
                  child: Stack(
                    children: [
                      Image.asset('assets/login_page/continue_button.png'),
                      const Positioned.fill(
                        child: Center(
                          child: FractionallySizedBox(
                            heightFactor: 0.7,
                            widthFactor: 0.7,
                            child: FittedBox(
                              //fit: BoxFit.contain,
                              child: Text(
                                '登入',
                                style: TextStyle(
                                  fontSize: 100,
                                  fontFamily: 'GSR_R',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
