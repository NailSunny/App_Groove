import 'dart:convert';

/// Нормализует роль из API/JWT к Client | Trainer | Admin.
String normalizeRole(String? role) {
  if (role == null || role.trim().isEmpty) return 'Client';
  final r = role.trim();
  switch (r.toLowerCase()) {
    case 'trainer':
      return 'Trainer';
    case 'admin':
      return 'Admin';
    case 'client':
      return 'Client';
    default:
      return r;
  }
}

/// Роль из JWT (ClaimTypes.Role → claim "role" или полный URI).
String? roleFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (payload is! Map<String, dynamic>) return null;

    const roleKeys = [
      'role',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role',
    ];

    for (final key in roleKeys) {
      final value = payload[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.isNotEmpty) return first;
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

bool isTrainerRole(String? role) => normalizeRole(role) == 'Trainer';

bool isClientRole(String? role) => normalizeRole(role) == 'Client';

bool isAdminRole(String? role) => normalizeRole(role) == 'Admin';
