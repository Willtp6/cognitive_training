import '../../fishing_game.dart';

import '../../../shared/exit_button_template.dart';
import 'exit_dialog.dart';

class ExitButton extends ExitButtonTemplate {
  static const String id = 'ExitButton';

  const ExitButton({super.key, required this.game});
  final FishingGame game;

  @override
  void onTapFunction() {
    game.pauseEngine();
    game.overlays.remove(ExitButton.id);
    game.overlays.add(ExitDialog.id);
  }
}
