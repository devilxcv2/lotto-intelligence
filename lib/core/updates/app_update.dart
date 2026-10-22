// lib/core/updates/app_update.dart

import 'dart:convert';

/// Versione pubblicata, letta dal file che si aggiorna insieme all'APK.
class PublishedUpdate {
  const PublishedUpdate({
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    required this.notes,
  });

  final String versionName;
  final int versionCode;
  final String apkUrl;
  final String notes;
}

/// `true` se il file pubblicato ha un versionCode più alto di quello installato.
bool isNewerRelease({required int installedCode, required int publishedCode}) {
  return publishedCode > installedCode;
}

/// Legge il JSON di pubblicazione. Torna null se manca un campo o l'indirizzo
/// dell'APK non è http o https.
PublishedUpdate? parseUpdateManifest(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map) return null;
  final name = decoded['versionName'];
  final url = decoded['apkUrl'];
  final code = _asInt(decoded['versionCode']);
  if (name is! String || name.trim().isEmpty || code == null || code <= 0) return null;
  if (url is! String || !_httpUrl(url)) return null;
  final notes = decoded['notes'];
  return PublishedUpdate(
    versionName: name.trim(),
    versionCode: code,
    apkUrl: url.trim(),
    notes: notes is String ? notes.trim() : '',
  );
}

bool _httpUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}
