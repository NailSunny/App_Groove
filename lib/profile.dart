import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groove_app/client_routes.dart';
import 'package:groove_app/widgets/theme_mode_switch.dart';
import 'package:groove_app/upload_images/universal_image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:groove_app/api_DTOs/user_dto.dart';
import 'package:groove_app/api_service/api_user.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _familiaController = TextEditingController();
  final _patronymicController = TextEditingController();
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
        setState(() => _photoUrl = photoUrl);
      });

      if (bytes != null) {
        String? uploadedUrl;

        if (!kIsWeb) {
          // Android / iOS – через временный файл
          final file = await _bytesToFile(bytes);
          uploadedUrl = await uploadPhoto(file);
        } else {
          // Web – напрямую байты
          uploadedUrl = await uploadPhotoBytes(bytes);
        }

        if (uploadedUrl != null) {
          setState(() {
            _photoUrl = uploadedUrl;
            _selectedImageBytes = bytes;
          });
          await _saveImageToPrefs(bytes);

          // Обновляем профиль с новым photoUrl
          if (_user != null) {
            final updatedUser = UserDto(
              id_user: _user!.id_user,
              name_user: _user!.name_user,
              familia_user: _user!.familia_user,
              patronymic: _user!.patronymic,
              email: _user!.email,
              phone: _user!.phone,
              photo: uploadedUrl,
              balance: _user!.balance,
            );
            await updateMyProfile(updatedUser); // ваш метод PUT /me
            setState(() => _user = updatedUser);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Фото загружено и сохранено')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка загрузки фото на сервер')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<File> _bytesToFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/temp_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _topUpBalance() async {
    final amountText = _balanceController.text.trim();
    if (amountText.isEmpty || int.tryParse(amountText) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Введите корректную сумму")));
      return;
    }
    final amount = int.parse(amountText);
    final success = await topUpUserBalance(amount);
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
    _userId = prefs.getInt('userId'); // может пригодиться для других целей

    // ✅ Загружаем свой профиль через fetchMyProfile
    final user = await fetchMyProfile();
    if (user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.name_user ?? '';
        _familiaController.text = user.familia_user ?? '';
        _patronymicController.text = user.patronymic ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _photoUrl = user.photo;
      });
    }

    // Фото из локального кэша (если было загружено ранее)
    final localPhoto = await _loadImageFromPrefs();
    if (localPhoto != null) {
      setState(() {
        _selectedImageBytes = localPhoto;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _user != null) {
      final updatedUser = UserDto(
        id_user: _user!.id_user,
        name_user: _nameController.text.trim(),
        familia_user: _familiaController.text.trim(),
        patronymic: _patronymicController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photo: _photoUrl ?? '',
        balance: _user!.balance,
      );

      final success = await updateMyProfile(updatedUser); // ✅ изменённый вызов

      if (success) {
        setState(() {
          _user = updatedUser;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Профиль обновлён")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Ошибка обновления")));
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
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      cursorColor: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      cursorColor: Theme.of(context).colorScheme.onSurface,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Обязательно';
        if (!value.contains('@')) return 'Неверный email';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'example@mail.ru',
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
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      cursorColor: Theme.of(context).colorScheme.onSurface,
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
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.popAndPushNamed(context, ClientRoutes.home);
          },
        ),
        title: Text("Профиль", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ThemeModeSwitch(showLabel: false),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Ваш баланс: ${_user?.balance ?? 0} ₽',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
                              ? Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                              : null,
                    ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xFFAD03E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      onPressed: _pickImageFromGallery,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "Имя"),
                const SizedBox(height: 20),
                _buildTextField(_familiaController, 'Фамилия'),
                const SizedBox(height: 20),
                _buildTextField(_patronymicController, 'Отчество'),
                SizedBox(height: 20),
                _buildPhoneField(),
                SizedBox(height: 20),
                _buildEmailField(),
                SizedBox(height: 20),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
