/// Вариант сборки приложения (flavor).
enum AppFlavor {
  /// Десктоп: только администратор.
  admin,

  /// Мобильные платформы: клиент и тренер.
  mobile,
}

/// Текущий flavor, задаётся в [main_admin] / [main_mobile].
abstract final class AppScope {
  static late final AppFlavor flavor;

  static bool get isAdmin => flavor == AppFlavor.admin;
  static bool get isMobile => flavor == AppFlavor.mobile;
}
