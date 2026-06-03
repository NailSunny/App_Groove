import 'package:flutter/material.dart';
import 'package:groove_app/widgets/groove_logo.dart';
import 'package:groove_app/api_DTOs/login_dto.dart';
import 'package:groove_app/api_service/api_requests.dart';
import 'package:groove_app/api_service/mobile_auth_api.dart';
import 'package:groove_app/helper/mobile_auth_navigation.dart';
import 'package:groove_app/routes/mobile_routes.dart';
import 'package:groove_app/widgets/theme_mode_switch.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  /// Автовход: тренер → TrainerShell, клиент → HomePage (как в .cursorrules).
  Future<void> _tryAutoLogin() async {
    if (await hasTrainerSession()) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(MobileRoutes.trainer);
      return;
    }

    if (await hasClientSession()) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(MobileRoutes.home);
      return;
    }

    if (mounted) setState(() => _checkingSession = false);
  }

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

      if (!mounted) return;
      if (result == "Успешный вход") {
        await navigateAfterMobileLogin(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFAD03E2)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: ThemeModeSwitch(showLabel: false),
          ),
          Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GrooveLogo(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите email';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                    Navigator.pushNamed(context, MobileRoutes.recovery);
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
                    Navigator.pushNamed(context, MobileRoutes.reg);
                  },
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: <Color>[Color(0xFFC556E7), Color(0xFF8802B3)],
                      ).createShader(bounds);
                    },
                    child: Text(
                      "Регистрация",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }
}
