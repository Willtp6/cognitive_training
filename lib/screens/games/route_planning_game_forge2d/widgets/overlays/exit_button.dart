import '../../../shared/exit_button_template.dart';
import '../../route_planning_game_forge2d.dart';
import 'exit_dialog.dart';

class ExitButton extends ExitButtonTemplate {
  static const String id = 'ExitButton';

  const ExitButton({super.key, required this.game});
  final RoutePlanningGameForge2d game;

  @override
  void onTapFunction() {
    game.pauseEngine();
    // game.overlays.remove(ExitButton.id);
    game.overlays.add(ExitDialog.id);
  }
}
