import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/login_dto.dart';
import 'package:groove_app/api_service/admin_auth_api.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/helper/admin_auth_navigation.dart';
import 'package:groove_app/routes/admin_routes.dart';
import 'package:groove_app/widgets/groove_logo.dart';
import 'package:groove_app/widgets/theme_mode_switch.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final hasSession = await hasAdminSession();
    if (!mounted) return;
    if (hasSession) {
      Navigator.of(context).pushReplacementNamed(AdminRoutes.home);
      return;
    }
    setState(() => _checkingSession = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final error = await loginAdmin(
      LoginDto(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: UnactiveRed),
      );
      return;
    }

    await navigateAfterAdminLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final g = context.groove;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (_checkingSession) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: MainPurple)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ThemeModeSwitch(),
                  ),
                  const SizedBox(height: 8),
                  const GrooveLogo(height: 120),
                  const SizedBox(height: 16),
                  Text(
                    'Панель администратора',
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: onSurface),
                    validator: (v) => v != null && v.contains('@') ? null : 'Введите email',
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: g.onSurfaceSecondary),
                      prefixIcon: Icon(Icons.email, color: g.onSurfaceMuted),
                      filled: true,
                      fillColor: ElementsPurple.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: onSurface),
                    validator: (v) => v != null && v.length >= 4 ? null : 'Минимум 4 символа',
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      labelStyle: TextStyle(color: g.onSurfaceSecondary),
                      prefixIcon: Icon(Icons.lock, color: g.onSurfaceMuted),
                      filled: true,
                      fillColor: ElementsPurple.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Войти'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
