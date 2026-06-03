import 'package:flutter/material.dart';
import 'package:groove_app/arenda.dart';
import 'package:groove_app/auth.dart';
import 'package:groove_app/basket_shop.dart';
import 'package:groove_app/features/trainer/screens/trainer_shell.dart';
import 'package:groove_app/home.dart';
import 'package:groove_app/myabonements.dart';
import 'package:groove_app/myarendalist.dart';
import 'package:groove_app/myjournal.dart';
import 'package:groove_app/mypurchase.dart';
import 'package:groove_app/profile.dart';
import 'package:groove_app/rec.dart';
import 'package:groove_app/rec2.dart';
import 'package:groove_app/reg.dart';
import 'package:groove_app/schedule.dart';
import 'package:groove_app/shop.dart';
import 'package:groove_app/trainerlist.dart';
import 'package:groove_app/contacts_screen.dart';

/// Маршруты мобильного приложения (клиент + тренер).
abstract final class MobileRoutes {
  static const auth = '/';
  static const home = '/home';
  static const trainer = '/trainer';
  static const reg = '/reg';
  static const recovery = '/rec';
  static const recoveryConfirm = '/rec2';
  static const profile = '/profile';
  static const schedule = '/schedule';
  static const arenda = '/arenda';
  static const trainerList = '/trainerlist';
  static const shop = '/shop';
  static const basket = '/basket';
  static const abonements = '/abonements';
  static const purchases = '/purchase';
  static const journal = '/myjournal';
  static const arendaList = '/myarendalist';
  static const contacts = '/contacts';
}

final Map<String, WidgetBuilder> mobileRoutes = {
  MobileRoutes.auth: (_) => const AuthPage(),
  MobileRoutes.home: (_) => const HomePage(),
  MobileRoutes.trainer: (_) => const TrainerShell(),
  MobileRoutes.reg: (_) => const RegPage(),
  MobileRoutes.recovery: (_) => const RecoveryPage(),
  MobileRoutes.profile: (_) => const ProfilePage(),
  MobileRoutes.schedule: (_) => const SchedulePage(),
  MobileRoutes.arenda: (_) => const ArendaPage(),
  MobileRoutes.trainerList: (_) => const TrainerlistPage(),
  MobileRoutes.shop: (_) => const ShopPage(),
  MobileRoutes.basket: (_) => const BasketShopPage(),
  MobileRoutes.abonements: (_) => const AbonementsPage(),
  MobileRoutes.purchases: (_) => const PurchasePage(),
  MobileRoutes.journal: (_) => const MyjournalPage(),
  MobileRoutes.arendaList: (_) => const MyarendalistPage(),
  MobileRoutes.contacts: (_) => const ContactsScreen(),
};

Route<dynamic>? mobileOnGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case MobileRoutes.recoveryConfirm:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const Recovery2Page(),
      );
    default:
      return null;
  }
}
