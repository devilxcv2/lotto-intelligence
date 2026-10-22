// lib/core/updates/apk_downloader.dart

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_update.dart';

class DownloadProgress {
  const DownloadProgress({
    required this.received,
    required this.total,
    required this.bytesPerSecond,
  });

  final int received;
  final int total;
  final double bytesPerSecond;

  double get fraction => total <= 0 ? 0 : (received / total).clamp(0.0, 1.0);

  Duration? get remaining {
    if (bytesPerSecond <= 1 || total <= 0 || received >= total) return null;
    final seconds = ((total - received) / bytesPerSecond).ceil();
    return Duration(seconds: seconds < 0 ? 0 : seconds);
  }
}

/// Scarica l'APK nella cartella dell'app e riporta avanzamento e velocità.
class ApkDownloader {
  ApkDownloader(this._dio);

  final Dio _dio;
  CancelToken? _token;

  void cancel() => _token?.cancel('Scarico annullato.');

  Future<File> download({
    required PublishedUpdate release,
    required void Function(DownloadProgress progress) onProgress,
  }) async {
    _token?.cancel();
    final token = CancelToken();
    _token = token;
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'lotto-update-${release.versionCode}.apk'));
    if (await file.exists()) await file.delete();

    var lastBytes = 0;
    var lastAt = DateTime.now();
    var speed = 0.0;

    await _dio.download(
      release.apkUrl,
      file.path,
      cancelToken: token,
      options: Options(
        receiveTimeout: const Duration(minutes: 15),
        sendTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
        headers: {'User-Agent': 'LottoIntelligenceAI/0.5 (scarico APK)'},
        validateStatus: (code) => code != null && code < 400,
      ),
      onReceiveProgress: (received, total) {
        final now = DateTime.now();
        final elapsed = now.difference(lastAt).inMilliseconds;
        if (elapsed >= 400) {
          final delta = received - lastBytes;
          final instant = delta * 1000 / elapsed;
          speed = speed <= 0 ? instant : (speed * 0.65 + instant * 0.35);
          lastBytes = received;
          lastAt = now;
        }
        onProgress(DownloadProgress(
          received: received,
          total: total < 0 ? 0 : total,
          bytesPerSecond: speed,
        ));
      },
    );
    if (!await file.exists() || await file.length() < 1024) {
      throw StateError('Il file scaricato non è un APK valido.');
    }
    return file;
  }
}
