import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/register_dto.dart';
import 'package:groove_app/api_service/api_requests.dart';
import 'package:groove_app/auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _familiaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _familiaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // добавлено
    super.dispose();
  }

  String result = "";

  void _submit() async {
    try {
      if (_formKey.currentState!.validate()) {
        final emailExists = await checkEmailExists(_emailController.text);
        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email уже зарегистрирован")),
          );
          return;
        }
        final user = RegisterDto(
          nameuser: _nameController.text,
          familiauser: _familiaController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );

        final response = await registerUser(user);

        if (response == "Регистрация успешна") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Регистрация прошла успешно")),
          );

          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response)));
        }
      }
    } catch (e, stack) {
      print("Ошибка при регистрации: $e");
      print("Stacktrace: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Произошла ошибка при регистрации")),
      );
    }
  }

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+7(###)###-##-##',
    filter: {"#": RegExp(r'\d')},
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) => value!.isEmpty ? "Введите имя" : null,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
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
                    controller: _familiaController,
                    validator:
                        (value) => value!.isEmpty ? "Введите фамилию" : null,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Фамилия',
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
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
                    controller: _phoneController,
                    inputFormatters: [phoneFormatter],
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) => value!.isEmpty ? "Введите телефон" : null,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            !value!.contains('@') ? "Неверный email" : null,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: "example@email.com",
                      hintStyle: TextStyle(color: Colors.grey),
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
                    validator:
                        (value) => value!.length < 6 ? "Мин. 6 символов" : null,
                    obscureText: true,
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Повторите пароль';
                      }
                      if (value != _passwordController.text) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                    obscureText: true,
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

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.55,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Color(0xFFFFFFFF).withOpacity(0.25),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text("Регистрация"),
                  ),
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
                    const Text(
                      "или",
                      style: TextStyle(color: Color(0xFFA4A4A4)),
                    ),
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
                      Navigator.popAndPushNamed(context, '/');
                    },
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: <Color>[Color(0xFFC556E7), Color(0xFF8802B3)],
                        ).createShader(bounds);
                      },
                      child: Text(
                        "Войти",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
