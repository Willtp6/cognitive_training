import 'package:cognitive_training/screens/games/shared/exit_button_template.dart';

class ExitButton extends ExitButtonTemplate {
  const ExitButton({
    super.key,
    required this.callback,
    super.alignment,
  });
  final Function callback;

  @override
  void onTapFunction() {
    callback();
  }
}
