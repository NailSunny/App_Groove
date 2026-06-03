import 'package:flutter/material.dart';
import 'package:groove_app/auth.dart';
import 'package:groove_app/helper/mobile_auth_navigation.dart';

@Deprecated('Use navigateAfterMobileLogin')
Future<void> navigateAfterLogin(BuildContext context) =>
    navigateAfterMobileLogin(context);

@Deprecated('Use navigateToMobileAuth')
Future<void> logoutAndGoToAuth(BuildContext context, Widget authPage) =>
    navigateToMobileAuth(context);
