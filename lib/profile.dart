import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:groove_app/upload_images/universal_image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:groove_app/api_DTOs/user_dto.dart';
import 'package:groove_app/api_service/api_user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _familiaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _balanceController = TextEditingController();

  int? _userId;
  UserDto? _user;
  String? _photoUrl;
  Uint8List? _selectedImageBytes;

  Future<void> _saveImageToPrefs(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = base64Encode(bytes);
    await prefs.setString('profile_photo_base64', base64String);
  }

  Future<Uint8List?> _loadImageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString('profile_photo_base64');
    if (base64String != null) {
      try {
        return base64Decode(base64String);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _pickImageFromGallery() async {
    try {
      final bytes = await pickImage((photoUrl) {
        setState(() {
          _photoUrl = photoUrl;
        });
      });

      if (bytes != null) {
        setState(() {
          _selectedImageBytes = bytes;
        });
        await _saveImageToPrefs(bytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Фото загружено')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _topUpBalance() async {
    if (_userId == null) return;

    final amountText = _balanceController.text.trim();
    if (amountText.isEmpty || int.tryParse(amountText) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Введите корректную сумму")));
      return;
    }

    final amount = int.parse(amountText);

    final success = await topUpUserBalance(_userId!, amount);
    if (success) {
      setState(() {
        _user!.balance += amount;
        _balanceController.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Баланс успешно пополнен")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка пополнения баланса")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');

    // Попытка загрузить фото из SharedPreferences
    final localPhoto = await _loadImageFromPrefs();

    if (localPhoto != null) {
      setState(() {
        _selectedImageBytes = localPhoto;
      });
    }

    if (_userId != null) {
      final user = await fetchUserById(_userId!);
      if (user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.name_user ?? '';
          _familiaController.text = user.familia_user ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phone ?? '';
          if (_selectedImageBytes == null) {
            // Если нет локального фото, используем URL
            _photoUrl = user.photo;
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _userId != null && _user != null) {
      final updatedUser = UserDto(
        id_user: _userId!,
        name_user: _nameController.text.trim(),
        familia_user: _familiaController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photo: _photoUrl ?? '', // сохранить URL
        balance: _user!.balance,
      );

      final success = await updateUserProfile(_userId!, updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Профиль обновлён" : "Ошибка обновления"),
        ),
      );

      if (success) {
        setState(() {
          _user = updatedUser;
        });
      }
    }
  }

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+7(###)###-##-##',
    filter: {"#": RegExp(r'\d')},
  );

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      validator:
          (value) => (value == null || value.isEmpty) ? 'Обязательно' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
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
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      validator:
          (value) => (value == null || value.isEmpty) ? 'Обязательно' : null,
      inputFormatters: [phoneFormatter],
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: "Номер телефона",
        labelStyle: const TextStyle(color: Colors.grey),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home');
          },
        ),
        title: const Text("Профиль", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Ваш баланс: ${_user?.balance ?? 0} ₽',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _selectedImageBytes != null
                            ? MemoryImage(_selectedImageBytes!)
                            : (_photoUrl != null && _photoUrl!.isNotEmpty
                                    ? NetworkImage(_photoUrl!)
                                    : null)
                                as ImageProvider<Object>?,
                    backgroundColor: Colors.grey.shade800,
                    child:
                        (_selectedImageBytes == null &&
                                (_photoUrl?.isEmpty ?? true))
                            ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFAD03E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _pickImageFromGallery,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, "Имя"),
              const SizedBox(height: 20),
              _buildTextField(_familiaController, "Фамилия"),
              const SizedBox(height: 20),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildTextField(_emailController, "Email"),
              const SizedBox(height: 20),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Сумма пополнения",
                  labelStyle: const TextStyle(color: Colors.grey),
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
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      color: const Color(0xFFFFFFFF).withOpacity(0.25),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _topUpBalance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03DAC6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Пополнить баланс"),
                ),
              ),

              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      color: const Color(0xFFFFFFFF).withOpacity(0.25),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAD03E2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Сохранить"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
