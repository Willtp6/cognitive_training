import 'package:cognitive_training/firebase/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';
import '../../shared/loading.dart';
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
  bool isLoading = false;
  bool isTutorial = false;

  int tutorialProgress = 0;
  List<String> tutorialMessage = [
    '歡迎來到認知訓練遊戲!',
    '我是遊戲的小幫手，來帶你認識登入介面',
    '首先要先登入使用者帳號',
    '在這裡輸入使用者編號，如:YU1234',
    '接著輸入使用者名稱，如:王大明',
    '最後按下登入就可進入遊戲囉!',
    '',
  ];
  String userId = '';
  String error = '';
  List<Tuple2<double, double>> positionXY = [
    const Tuple2(-0.65, 0.1),
    const Tuple2(-0.65, 0.45),
    const Tuple2(-0.3, 0.8),
  ];

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              opacity: isTutorial ? 0.3 : 1,
              image: const AssetImage('assets/global/login_background_1.jpeg'),
              fit: BoxFit.fitWidth,
            ),
          ),
          child: Stack(
            children: [
              // main block of login
              Align(
                alignment: const Alignment(0.0, 0.5),
                child: Container(
                  height: height * 0.7,
                  width: width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(width * 0.05),
                    ),
                    //border: Border.all(width: 2, color: Colors.black),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.025,
                      right: width * 0.025,
                      top: height * 0.05,
                      bottom: height * 0.025,
                    ),
                    child: getLoginForm(),
                  ),
                ),
              ),
              // masked of login
              if (isTutorial && tutorialProgress < 1)
                Align(
                  alignment: const Alignment(0.0, 0.5),
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      height: height * 0.7,
                      width: width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(width * 0.05),
                        ),
                        //border: Border.all(width: 2, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              // login logo
              Align(
                alignment: const Alignment(0.0, -0.8),
                child: Container(
                  height: height * 0.3,
                  width: width * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      opacity: isTutorial && tutorialProgress < 1 ? 0.3 : 1,
                      image:
                          const AssetImage('assets/login_page/login_logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: isTutorial ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: height * 0.4,
                    width: width * 0.2,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/login_page/tutorial_doctors.png',
                        ),
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: isTutorial ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Align(
                  alignment: const Alignment(1, -0.9),
                  child: Container(
                    height: width * 0.3,
                    width: width * 0.3,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/login_page/tutorial_chat_bubble.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Align(
                      alignment: const Alignment(0, -0.2),
                      child: FractionallySizedBox(
                        heightFactor: 0.4,
                        widthFactor: 0.6,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            tutorialMessage[tutorialProgress],
                            maxLines: 4,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: width * 0.3 * 0.6 / 6,
                              fontFamily: 'GSR_R',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              getContinueButton(),
              //tutorial button
              AnimatedOpacity(
                opacity: isTutorial ? 0 : 1,
                duration: const Duration(milliseconds: 500),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: width * 0.05),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isTutorial = true;
                        });
                      },
                      child: SizedBox(
                        width: width * 0.15,
                        height: width * 0.15 * 236 / 578,
                        child: Image.asset(
                            'assets/login_page/tutorial_button.png'),
                      ),
                    ),
                  ),
                ),
              ),
              if (isTutorial && tutorialProgress >= 3)
                Align(
                  alignment: Alignment(positionXY[tutorialProgress - 3].item1,
                      positionXY[tutorialProgress - 3].item2),
                  child: SizedBox(
                      width: width * 0.1,
                      height: width * 0.1,
                      child: Image.asset(
                          'assets/login_page/tutorial_right_arrow.png')),
                ),
              if (isLoading)
                SpinKitCircle(
                  color: Colors.blue,
                  duration: Duration(milliseconds: 1500),
                )
            ],
          ),
        ),
      ),
    );
  }

  AnimatedOpacity getContinueButton() {
    double localWidth = MediaQuery.of(context).size.width * 0.15;
    return AnimatedOpacity(
      opacity: isTutorial ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Align(
        alignment: const Alignment(0.5, 0.9),
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (tutorialProgress < 5) {
                tutorialProgress++;
              } else {
                Future.delayed(const Duration(milliseconds: 500), () {
                  tutorialProgress = 0;
                });
                isTutorial = false;
              }
            });
          },
          child: Container(
            width: localWidth,
            height: localWidth * 373 / 835,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_page/continue_button.png'),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(localWidth * 0.1),
              child: const FittedBox(
                child: Text(
                  '點我繼續',
                  style: TextStyle(
                    fontFamily: 'GSR_R',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoginForm() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // empty space for logo
          Expanded(flex: 2, child: Container()),
          // login label
          const Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                '使用者登入',
                style: TextStyle(
                  fontFamily: 'GSR_B',
                ),
              ),
            ),
          ),
          // input id
          Expanded(
            flex: 3,
            child: DottedBorder(
              color: isTutorial && tutorialProgress == 3
                  ? Colors.red
                  : Colors.white,
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
                      'assets/login_page/login_id.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text('使用者編號'),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: width * 0.025),
                      child: TextFormField(
                        enabled: !isTutorial,
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
          // input username
          Expanded(
            flex: 3,
            child: DottedBorder(
              color: isTutorial && tutorialProgress == 4
                  ? Colors.red
                  : Colors.white,
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
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text('使用者姓名'),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: width * 0.025),
                      child: TextFormField(
                        enabled: !isTutorial,
                        decoration: inputDecoration.copyWith(
                          hintText: '輸入姓名',
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
          // login button
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  dynamic result = await _auth.login(userId);
                  String errorMessage;
                  if (result.code == 'user-not-found') {
                    errorMessage = '帳號不存在';
                  } else if (result.code == 'network-request-failed') {
                    errorMessage = '網路錯誤';
                  } else {
                    errorMessage = '未知錯誤';
                  }
                  setState(() {
                    error = '登入失敗';
                    isLoading = false;
                  });
                  _showAlertDialog(errorMessage);
                }
              },
              child: DottedBorder(
                color: isTutorial && tutorialProgress == 5
                    ? Colors.red
                    : Colors.white,
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                strokeWidth: 2,
                dashPattern: const [8, 4],
                padding: const EdgeInsets.all(5),
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
              children: const <Widget>[
                Center(child: Text('帳號似乎不存在')),
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
