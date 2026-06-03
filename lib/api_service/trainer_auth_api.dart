import 'package:groove_app/api_service/mobile_auth_api.dart';

export 'package:groove_app/api_service/mobile_auth_api.dart'
    show hasTrainerSession, clearMobileSession;

@Deprecated('Use clearMobileSession from mobile_auth_api.dart')
Future<void> clearTrainerSession() => clearMobileSession();
