import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère le mode de thème avec les seuls outils du framework
/// (ValueNotifier + InheritedNotifier), sans package d'état dédié.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController(this._prefs) : super(_restore(_prefs));

  static const String _key = 'theme_mode';

  final SharedPreferences _prefs;

  /// Au premier lancement, l'app suit le thème du système.
  static ThemeMode _restore(SharedPreferences prefs) {
    switch (prefs.getString(_key)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Bascule vers l'opposé du thème réellement affiché à l'écran.
  void toggle(Brightness displayed) {
    value = displayed == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_key, value == ThemeMode.dark ? 'dark' : 'light');
  }
}

/// Expose le [ThemeController] à l'arbre de widgets sans dépendance externe.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope introuvable dans le contexte');
    return scope!.notifier!;
  }
}
