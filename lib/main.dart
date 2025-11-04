import 'package:flutter/material.dart';
import 'package:groove_app/api_service/cart_provider.dart';
import 'package:groove_app/arenda.dart';
import 'package:groove_app/auth.dart';
import 'package:groove_app/basket_shop.dart';
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
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const AppTheme(),
    ),
  );
}

class AppTheme extends StatelessWidget {
  const AppTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'RubikMonoOne',
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF151515),
          centerTitle: true,
        ),
        scaffoldBackgroundColor: Color(0xFF151515),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(color: Color(0xFFAD03E2)),
              ),
            ),
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            foregroundColor: WidgetStatePropertyAll(Colors.black),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            backgroundColor: WidgetStatePropertyAll(Color(0xFFAD03E2)),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthPage(),
        '/reg': (context) => RegPage(),
        '/rec': (context) => RecoveryPage(),
        '/rec2': (context) => Recovery2Page(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/trainerlist': (context) => TrainerlistPage(),
        '/schedule': (context) => SchedulePage(),
        '/shop': (context) => ShopPage(),
        '/basket': (context) => BasketShopPage(),
        '/abonements': (context) => AbonementsPage(),
        '/purchase': (context) => PurchasePage(),
        '/arenda': (context) => ArendaPage(),
        '/myarendalist': (context) => MyarendalistPage(),
        '/myjournal': (context) => MyjournalPage(),
      },
    );
  }
}
