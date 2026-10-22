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

class UpdateCatalog {
  const UpdateCatalog({required this.latest, required this.releases});

  final PublishedUpdate latest;
  final List<PublishedUpdate> releases;

  /// Versioni più nuove di [installedCode], ultima in testa.
  List<PublishedUpdate> newerThan(int installedCode) {
    final out = [
      for (final release in releases)
        if (release.versionCode > installedCode) release,
    ];
    out.sort((a, b) => b.versionCode.compareTo(a.versionCode));
    if (out.isEmpty && latest.versionCode > installedCode) return [latest];
    return out;
  }
}

/// `true` se il file pubblicato ha un versionCode più alto di quello installato.
bool isNewerRelease({required int installedCode, required int publishedCode}) {
  return publishedCode > installedCode;
}

/// Legge il JSON di pubblicazione. Accetta anche un elenco `releases` per
/// scegliere una versione se si è rimasti indietro di più di una.
UpdateCatalog? parseUpdateCatalog(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map) return null;
  final latest = _parseOne(decoded);
  if (latest == null) return null;
  final raw = decoded['releases'];
  final listed = <PublishedUpdate>[];
  if (raw is List) {
    for (final item in raw) {
      if (item is Map) {
        final release = _parseOne(Map<Object?, Object?>.from(item));
        if (release != null) listed.add(release);
      }
    }
  }
  if (listed.isEmpty) listed.add(latest);
  listed.sort((a, b) => b.versionCode.compareTo(a.versionCode));
  // Garantisce che la "latest" del file sia presente.
  if (!listed.any((item) => item.versionCode == latest.versionCode)) {
    listed.insert(0, latest);
  }
  return UpdateCatalog(latest: latest, releases: listed);
}

/// Compatibilità: solo la versione in cima al file.
PublishedUpdate? parseUpdateManifest(String body) => parseUpdateCatalog(body)?.latest;

PublishedUpdate? _parseOne(Map<Object?, Object?> decoded) {
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

String formatByteSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String formatRemaining(Duration value) {
  if (value.inDays > 0) return 'più di un giorno';
  if (value.inHours > 0) return '${value.inHours} h ${value.inMinutes % 60} min';
  if (value.inMinutes > 0) return '${value.inMinutes} min ${value.inSeconds % 60} s';
  if (value.inSeconds > 0) return '${value.inSeconds} s';
  return 'pochi secondi';
}
