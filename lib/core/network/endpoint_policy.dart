// lib/core/network/endpoint_policy.dart

/// HTTPS è ammesso verso l'host indicato dall'utente.
/// HTTP solo verso localhost o indirizzi LAN privati, per Ollama in rete domestica.
bool isAllowedAiEndpoint(Uri uri) {
  if (uri.host.isEmpty) return false;
  if (uri.scheme == 'https') return true;
  if (uri.scheme != 'http') return false;
  return _isLocalOrPrivate(uri.host);
}

bool _isLocalOrPrivate(String host) {
  final lower = host.toLowerCase();
  if (lower == 'localhost' || lower == '127.0.0.1' || lower == '::1') return true;
  final parts = lower.split('.');
  if (parts.length != 4) return false;
  final numbers = <int>[];
  for (final part in parts) {
    final value = int.tryParse(part);
    if (value == null || value < 0 || value > 255) return false;
    numbers.add(value);
  }
  final a = numbers[0];
  final b = numbers[1];
  if (a == 10) return true;
  if (a == 192 && b == 168) return true;
  if (a == 172 && b >= 16 && b <= 31) return true;
  return false;
}
