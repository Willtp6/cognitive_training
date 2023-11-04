// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cognitive_training/constants/tutorial_mode_const.dart';
// import 'package:flutter/material.dart';

// class LoginTutorial {
//   LoginTutorial();

//   bool isTutorial = false;

//   int tutorialProgress = 0;

//   List<String> tutorialMessage = [
//     '歡迎來到認知訓練遊戲!',
//     '我是遊戲的小幫手，來帶你認識登入介面',
//     '首先要先登入使用者帳號',
//     '在這裡輸入使用者編號，如:YU1234',
//     '接著輸入使用者名稱，如:王大明',
//     '最後按下登入就可進入遊戲囉!',
//     '',
//   ];

//   List<Alignment> positionXY = [
//     const Alignment(-0.65, 0.1),
//     const Alignment(-0.65, 0.45),
//     const Alignment(-0.3, 0.8),
//   ];

//   AnimatedOpacity tutorialButton() {
//     return AnimatedOpacity(
//       opacity: isTutorial ? 0 : 1,
//       duration: const Duration(milliseconds: 500),
//       child: Align(
//         alignment: const Alignment(0.9, 0.0),
//         child: FractionallySizedBox(
//           widthFactor: 0.15,
//           child: AspectRatio(
//             aspectRatio: 578 / 236,
//             child: Image.asset(TutorialModeConst.enterTutorialModeButton),
//           ),
//         ),
//       ),
//     );
//   }

//   IgnorePointer tutorialDoctor() {
//     return IgnorePointer(
//       ignoring: !isTutorial,
//       child: AnimatedOpacity(
//         opacity: isTutorial ? 1 : 0,
//         duration: const Duration(milliseconds: 500),
//         child: Align(
//           alignment: Alignment.bottomRight,
//           child: FractionallySizedBox(
//             heightFactor: 0.45,
//             child: AspectRatio(
//               aspectRatio: 1,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(TutorialModeConst.doctors),
//                     fit: BoxFit.contain,
//                     alignment: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   IgnorePointer chatBubble() {
//     return IgnorePointer(
//       ignoring: !isTutorial,
//       child: AnimatedOpacity(
//         opacity: isTutorial ? 1 : 0,
//         duration: const Duration(milliseconds: 500),
//         child: Align(
//           alignment: const Alignment(1, -0.9),
//           child: FractionallySizedBox(
//             heightFactor: 0.65,
//             child: AspectRatio(
//               aspectRatio: 1,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(TutorialModeConst.chatBubble),
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 child: Align(
//                   alignment: const Alignment(0, -0.2),
//                   child: FractionallySizedBox(
//                     heightFactor: 0.4,
//                     widthFactor: 0.6,
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: AutoSizeText(
//                         tutorialMessage[tutorialProgress],
//                         maxLines: 3,
//                         softWrap: true,
//                         style: const TextStyle(
//                           fontSize: 100,
//                           fontFamily: 'GSR_R',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   AnimatedOpacity getContinueButton() {
//     return AnimatedOpacity(
//       opacity: isTutorial ? 1 : 0,
//       duration: const Duration(milliseconds: 500),
//       child: Align(
//         alignment: const Alignment(0.5, 0.9),
//         child: FractionallySizedBox(
//           widthFactor: 0.15,
//           child: AspectRatio(
//             aspectRatio: 835 / 373,
//             child: Stack(
//               children: [
//                 Image.asset('assets/login_page/continue_button.png'),
//                 const Center(
//                   child: FractionallySizedBox(
//                     heightFactor: 0.7,
//                     widthFactor: 0.7,
//                     child: FittedBox(
//                       //fit: BoxFit.contain,
//                       child: Text(
//                         '點我繼續',
//                         style: TextStyle(
//                           fontSize: 100,
//                           fontFamily: 'GSR_R',
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Align hintArrow() {
//     return Align(
//       alignment: positionXY[tutorialProgress - 3],
//       child: FractionallySizedBox(
//         heightFactor: 0.2,
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Image.asset(TutorialModeConst.rightArrow),
//         ),
//       ),
//     );
//   }

//   Align mask(double width, double height) {
//     return Align(
//       alignment: const Alignment(0.0, 0.5),
//       child: Opacity(
//         opacity: 0.3,
//         child: FractionallySizedBox(
//           heightFactor: 0.7,
//           widthFactor: 0.5,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(
//                 Radius.elliptical(width * 0.5 * 0.1, height * 0.7 * 0.1),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
