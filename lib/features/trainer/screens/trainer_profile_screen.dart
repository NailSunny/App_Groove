import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groove_app/auth.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/trainer/models/trainer_profile.dart';
import 'package:groove_app/features/trainer/services/trainer_api_service.dart';
import 'package:groove_app/api_service/trainer_auth_api.dart';
import 'package:groove_app/helper/mobile_auth_navigation.dart';
import 'package:groove_app/upload_images/universal_image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _infoController = TextEditingController();
  DateTime? _dateOfBirth;
  TrainerProfile? _profile;
  String? _photoUrl;
  Uint8List? _selectedImageBytes;
  bool _loading = true;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+7(###)###-##-##',
    filter: {'#': RegExp(r'\d')},
  );

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _phoneController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await getTrainerProfile();
    if (!mounted) return;
    if (profile == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _profile = profile;
      _nameController.text = profile.name;
      _surnameController.text = profile.surname;
      _patronymicController.text = profile.patronymic ?? '';
      _phoneController.text = profile.phone ?? '';
      _infoController.text = profile.information ?? '';
      _dateOfBirth = profile.dateOfBirth;
      _photoUrl = profile.photo;
      _loading = false;
    });
  }

  Future<File> _bytesToFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/trainer_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _pickImage() async {
    try {
      final bytes = await pickImage((photoUrl) {
        setState(() => _photoUrl = photoUrl);
      });

      if (bytes == null || _profile == null) return;

      String? uploadedUrl;
      if (!kIsWeb) {
        final file = await _bytesToFile(bytes);
        uploadedUrl = await uploadTrainerPhoto(file);
      } else {
        uploadedUrl = await uploadTrainerPhotoBytes(bytes);
      }

      if (uploadedUrl != null) {
        _profile!.photo = uploadedUrl;
        setState(() {
          _photoUrl = uploadedUrl;
          _selectedImageBytes = bytes;
        });
        await updateTrainerProfile(_profile!);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Фото обновлено')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка загрузки фото')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: Locale('ru'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: MainPurple,
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
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
    if (!_formKey.currentState!.validate() || _profile == null) return;

    _profile!
      ..name = _nameController.text.trim()
      ..surname = _surnameController.text.trim()
      ..patronymic =
          _patronymicController.text.trim().isEmpty
              ? null
              : _patronymicController.text.trim()
      ..phone = _phoneController.text.trim()
      ..information = _infoController.text.trim()
      ..dateOfBirth = _dateOfBirth
      ..photo = _photoUrl;

    final success = await updateTrainerProfile(_profile!);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Профиль обновлён' : 'Ошибка обновления'),
      ),
    );
    if (success) await _loadProfile();
  }

  Future<void> _logout() async {
    await clearTrainerSession();
    await navigateToMobileAuth(context);
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      cursorColor: Theme.of(context).colorScheme.onSurface,
      validator:
          label == 'Отчество' || label == 'О себе'
              ? null
              : (v) => (v == null || v.isEmpty) ? 'Обязательно' : null,
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: MainPurple));
    }

    if (_profile == null) {
      return Center(
        child: Text(
          'Не удалось загрузить профиль',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      );
    }

    final dobText =
        _dateOfBirth != null
            ? DateFormat('dd.MM.yyyy').format(_dateOfBirth!)
            : 'Не указана';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
                      color: MainPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.add, size: 20, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  onPressed: _pickImage,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildField(_surnameController, 'Фамилия'),
            SizedBox(height: 16),
            _buildField(_nameController, 'Имя'),
            SizedBox(height: 16),
            _buildField(_patronymicController, 'Отчество'),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              inputFormatters: [_phoneFormatter],
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              cursorColor: Theme.of(context).colorScheme.onSurface,
              validator: (v) => (v == null || v.isEmpty) ? 'Обязательно' : null,
              decoration: InputDecoration(
                labelText: 'Номер телефона',
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
            SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Дата рождения',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              subtitle: Text(
                dobText,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today, color: ProcessYellow),
                onPressed: _pickDateOfBirth,
              ),
            ),
            const SizedBox(height: 8),
            _buildField(_infoController, 'О себе', maxLines: 4),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Сохранить'),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.exit_to_app, color: ProcessYellow),
              label: const Text(
                'Выйти',
                style: TextStyle(color: ProcessYellow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
