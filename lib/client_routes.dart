import 'package:flutter/material.dart';
import 'package:groove_app/routes/mobile_routes.dart';

export 'package:groove_app/routes/mobile_routes.dart'
    show MobileRoutes, mobileRoutes, mobileOnGenerateRoute;

@Deprecated('Use MobileRoutes')
typedef ClientRoutes = MobileRoutes;

@Deprecated('Use mobileRoutes')
final Map<String, WidgetBuilder> clientRoutes = mobileRoutes;

@Deprecated('Use mobileOnGenerateRoute')
Route<dynamic>? clientOnGenerateRoute(RouteSettings settings) =>
    mobileOnGenerateRoute(settings);
