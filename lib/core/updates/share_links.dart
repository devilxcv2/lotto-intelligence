// lib/core/updates/share_links.dart

import '../settings/settings_repository.dart' show SettingsRepository;

/// Link pubblici da copiare o inviare (WhatsApp, SMS, mail…).
abstract final class AppShareLinks {
  /// Pagina leggera con pulsante «Scarica APK» (legge sempre update.json).
  static const landingUrl =
      'https://cdn.jsdelivr.net/gh/devilxcv2/lotto-intelligence@main/dist/download.html';

  /// Pagina GitHub dell'ultima release (fallback se la landing non apre).
  static const releasesLatestUrl =
      'https://github.com/devilxcv2/lotto-intelligence/releases/latest';

  static const updateManifestUrl = SettingsRepository.defaultUpdateManifestUrl;

  /// Testo pronto da incollare in chat.
  static String inviteMessage({String? versionName, String? apkUrl}) {
    final buffer = StringBuffer()
      ..writeln('Ciao — ti mando Lotto Intelligence (laboratorio di studio del Lotto, non un gioco online).')
      ..writeln()
      ..writeln('Scarica qui: $landingUrl');
    if (versionName != null && versionName.isNotEmpty) {
      buffer.writeln('(versione $versionName)');
    }
    if (apkUrl != null && apkUrl.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('APK diretto: $apkUrl');
    }
    buffer
      ..writeln()
      ..writeln('Su Android apri il file e consenti l\'installazione da quella fonte. I soldi in app sono simulati.');
    return buffer.toString().trim();
  }
}
