import 'package:flutter/material.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:intl/intl.dart';

void showAdminError(BuildContext context, Object error) {
  final message = error is AdminApiException ? error.message : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: UnactiveRed),
  );
}

void showAdminSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: ActiveGreen),
  );
}

String adminInitials(String? familia, String? name) {
  final f = familia?.trim();
  final n = name?.trim();
  if (f != null && f.isNotEmpty && n != null && n.isNotEmpty) {
    return '${f[0]}${n[0]}'.toUpperCase();
  }
  if (f != null && f.isNotEmpty) return f[0].toUpperCase();
  if (n != null && n.isNotEmpty) return n[0].toUpperCase();
  return 'А';
}

String adminDisplayName(String? familia, String? name, String? patronymic) {
  final parts = <String>[];
  if (familia != null && familia.trim().isNotEmpty) parts.add(familia.trim());
  if (name != null && name.trim().isNotEmpty) {
    parts.add('${name.trim()[0]}.');
  }
  if (patronymic != null && patronymic.trim().isNotEmpty) {
    parts.add('${patronymic.trim()[0]}.');
  }
  return parts.isEmpty ? 'Администратор' : parts.join(' ');
}

bool isValidEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) return false;
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return pattern.hasMatch(email);
}

String formatDate(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('dd.MM.yyyy').format(date);
}

Future<DateTime?> pickDate(BuildContext context, DateTime? initial) async {
  return showDatePicker(
    context: context,
    initialDate: initial ?? DateTime(2000),
    firstDate: DateTime(1920),
    lastDate: DateTime.now(),
    builder: (ctx, child) {
      final g = ctx.groove;
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
            primary: MainPurple,
            onPrimary: Colors.white,
            surface: g.cardBackground,
            onSurface: g.onSurface,
          ),
        ),
        child: child!,
      );
    },
  );
}

InputDecoration adminInputDecoration(BuildContext context, String label) {
  final g = context.groove;
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: g.onSurfaceSecondary),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ElementsPurple),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MainPurple),
    ),
  );
}

Widget adminAddButton({required VoidCallback onPressed}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.add),
    label: const Text('Добавить'),
  );
}
