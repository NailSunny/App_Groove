import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool codeSent = false;

  Future<void> requestCode() async {
    final email = emailController.text.trim();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/PasswordResetEmail/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      setState(() {
        codeSent = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Код отправлен на почту')));
    } else {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Ошибка'),
              content: Text('Не удалось отправить код. Проверьте email.'),
            ),
      );
    }
  }

  Future<void> verifyCodeAndProceed() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Введите код')));
      return;
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/PasswordResetEmail/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode == 200) {
      Navigator.pushNamed(
        context,
        '/rec2',
        arguments: {'email': email, 'code': code},
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Неверный код')));
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/Logo_Groove.png",
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: inputDecoration("Email", Icons.email),
              ),
              SizedBox(height: 15),
              if (codeSent)
                TextField(
                  controller: codeController,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: inputDecoration("Код", Icons.lock),
                ),
              SizedBox(height: 30),
              if (!codeSent)
                buildButton("Запросить код", requestCode)
              else
                buildButton("Подтвердить код", verifyCodeAndProceed),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
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
    );
  }

  Widget buildButton(String text, VoidCallback onPressed) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.55,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 15, color: Color(0xFFFFFFFF).withOpacity(0.25)),
        ],
      ),
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
