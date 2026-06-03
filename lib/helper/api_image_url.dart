import 'package:groove_app/config/api_config.dart';

/// Базовый origin API без завершающего слэша.
String get apiOrigin {
  final uri = Uri.parse(ApiConfig.baseUrl);
  if (uri.hasPort) {
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }
  return '${uri.scheme}://${uri.host}';
}

/// Преобразует путь из API в URL для [Image.network].
/// Относительные пути и абсолютные URL переписываются на хост из [ApiConfig.baseUrl].
String? resolveApiImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;

  final trimmed = url.trim();

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    final parsed = Uri.parse(trimmed);
    final base = Uri.parse(ApiConfig.baseUrl);
    final rebased = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: parsed.path.isEmpty ? '/' : parsed.path,
      query: parsed.hasQuery ? parsed.query : null,
    );
    return rebased.toString();
  }

  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$apiOrigin$path';
}
