import 'package:flutter/material.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/widgets/groove_logo.dart';
import 'package:groove_app/api_DTOs/register_dto.dart';
import 'package:groove_app/api_service/api_requests.dart';
import 'package:groove_app/client_routes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
  final _patronymicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familiaController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // добавлено
    super.dispose();
  }

  String result = "";

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ru'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: MainPurple,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите дату рождения')),
      );
      return;
    }

    try {
      final emailExists = await checkEmailExists(_emailController.text);
      if (!mounted) return;
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email уже зарегистрирован')),
        );
        return;
      }

      final user = RegisterDto(
        nameuser: _nameController.text.trim(),
        familiauser: _familiaController.text.trim(),
        patronymic: _patronymicController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      final response = await registerUser(user);
      if (!mounted) return;

      if (response == 'Регистрация успешна') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Регистрация прошла успешно')),
        );
        Navigator.pushReplacementNamed(context, ClientRoutes.auth);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response)),
      );
    } catch (e, stack) {
      debugPrint('Ошибка при регистрации: $e');
      debugPrint('Stacktrace: $stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Произошла ошибка при регистрации')),
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
                GrooveLogo(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) => value!.isEmpty ? "Введите имя" : null,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
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
                    controller: _patronymicController,
                    validator: (value) => value!.isEmpty ? 'Введите отчество' : null,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
                    decoration: InputDecoration(
                      labelText: 'Отчество',
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
                  child: InkWell(
                    onTap: _pickDateOfBirth,
                    borderRadius: BorderRadius.circular(25),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Дата рождения',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xCC643C70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      child: Text(
                        _dateOfBirth != null
                            ? DateFormat('d MMMM yyyy', 'ru').format(_dateOfBirth!)
                            : 'Нажмите, чтобы выбрать',
                        style: TextStyle(
                          color: _dateOfBirth != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.grey,
                        ),
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@mail.ru',
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
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
                      Navigator.popAndPushNamed(context, ClientRoutes.auth);
                    },
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: <Color>[Color(0xFFC556E7), Color(0xFF8802B3)],
                        ).createShader(bounds);
                      },
                      child: Text(
                        "Войти",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
