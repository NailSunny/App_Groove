# Flavors Groove App

Два варианта сборки с разными точками входа и навигацией.

| Flavor | Точка входа | Платформы | Роли |
|--------|-------------|-----------|------|
| `mobile` | `lib/main_mobile.dart` | Android, iOS | Client, Trainer |
| `admin` | `lib/main_admin.dart` | Windows, macOS, Linux | Admin |

## Запуск

### Mobile (клиент / тренер)

```bash
flutter run -t lib/main_mobile.dart --flavor mobile
```

### Admin (десктоп)

```bash
flutter run -t lib/main_admin.dart --flavor admin -d windows
flutter run -t lib/main_admin.dart --flavor admin -d macos
flutter run -t lib/main_admin.dart --flavor admin -d linux
```

На десктопе `--flavor` опционален (достаточно `-t lib/main_admin.dart`).

## Сборка release

```bash
flutter build apk -t lib/main_mobile.dart --flavor mobile
flutter build ios -t lib/main_mobile.dart --flavor mobile
flutter build windows -t lib/main_admin.dart --flavor admin
flutter build macos -t lib/main_admin.dart --flavor admin
flutter build linux -t lib/main_admin.dart --flavor admin
```

## Навигация

- **Mobile**: `lib/routes/mobile_routes.dart` — вход `AuthPage`, клиент → `/home`, тренер → `/trainer`.
- **Admin**: `lib/routes/admin_routes.dart` — вход `AdminLoginPage`, главная → `/home`.

Вход администратора в mobile-приложении отклоняется с подсказкой использовать десктоп.
