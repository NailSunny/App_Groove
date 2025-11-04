import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/login_dto.dart';
import 'package:groove_app/api_service/api_requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final user = LoginDto(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final result = await loginUser(user);
      if (result.startsWith("LoggedIn_")) {
        final id = int.parse(result.split('_')[1]);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', id);
        Navigator.popAndPushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/Logo_Groove.png",
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextFormField(
                  controller: _emailController,
                  validator:
                      (value) =>
                          value != null && value.contains("@")
                              ? null
                              : "Введите email",
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
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
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator:
                      (value) =>
                          value != null && value.length >= 6
                              ? null
                              : "Мин. 6 символов",
                  style: TextStyle(color: Colors.white),
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
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.popAndPushNamed(context, '/rec');
                  },
                  child: Text(
                    "Забыли пароль?",
                    style: TextStyle(color: Color(0xFFE693FF)),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

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
                child: ElevatedButton(onPressed: _submit, child: Text("Войти")),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      indent: MediaQuery.of(context).size.height * 0.05,
                      endIndent: MediaQuery.of(context).size.width * 0.02,
                      color: Color(0xFFA4A4A4),
                      thickness: 1,
                    ),
                  ),
                  const Text("или", style: TextStyle(color: Color(0xFFA4A4A4))),
                  Expanded(
                    child: Divider(
                      indent: MediaQuery.of(context).size.width * 0.02,
                      endIndent: MediaQuery.of(context).size.height * 0.05,
                      color: Color(0xFFA4A4A4),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/reg');
                  },
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: <Color>[Color(0xFFC556E7), Color(0xFF8802B3)],
                      ).createShader(bounds);
                    },
                    child: Text(
                      "Регистрация",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
