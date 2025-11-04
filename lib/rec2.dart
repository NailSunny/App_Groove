import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

class Recovery2Page extends StatefulWidget {
  const Recovery2Page({super.key});

  @override
  State<Recovery2Page> createState() => _Recovery2PageState();
}

class _Recovery2PageState extends State<Recovery2Page> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  late String email;
  late String code;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    email = args['email']!;
    code = args['code']!;
  }

  Future<void> resetPassword() async {
    final newPassword = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    if (newPassword != repeatPassword) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Ошибка'),
              content: Text('Пароли не совпадают'),
            ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/PasswordResetEmail/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      // Показать уведомление после перехода
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/', // Или '/', если это ваш экран входа
        (route) => false,
      );

      // Используем Future.microtask, чтобы показать SnackBar после навигации
      Future.microtask(() {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Пароль успешно изменён')));
      });
    } else {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Ошибка'),
              content: Text('Неверный код или email'),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/Logo_Groove.png",
              // height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TextFormField(
                controller: passwordController,
                style: TextStyle(color: Colors.white),
                validator:
                    (value) => value!.length < 6 ? "Мин. 6 символов" : null,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xCC643C70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TextField(
                controller: repeatPasswordController,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Повторите пароль',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xCC643C70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.04),

            Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.55,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    // ignore: deprecated_member_use
                    color: Color(0xFFFFFFFF).withOpacity(0.25),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: resetPassword,
                child: Text("Сохранить"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
