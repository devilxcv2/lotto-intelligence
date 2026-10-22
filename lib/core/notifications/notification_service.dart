// lib/core/notifications/notification_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../lotto/wheel_catalog.dart';
import '../settings/app_settings.dart';

/// Notifiche locali: nessun server, nessun token, solo Android.
/// Il payload è la rotta da aprire al tocco.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const channelId = 'draw_results';
  static const newDrawId = 1001;
  static const ticketsRoute = '/more/tickets';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Rotta ricevuta da un tocco mentre l'app è viva.
  final ValueNotifier<String?> tappedRoute = ValueNotifier<String?>(null);

  bool get supported => !kIsWeb && Platform.isAndroid;

  Future<void> initialize() async {
    if (_initialized || !supported) return;
    _initialized = true;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        tappedRoute.value = response.payload ?? ticketsRoute;
      },
    );
  }

  /// Rotta della notifica che ha avviato l'app a freddo, se c'è.
  Future<String?> launchRoute() async {
    if (!supported) return null;
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload ?? ticketsRoute;
    }
    return null;
  }

  /// Su Android 13+ serve il permesso esplicito. Restituisce true se concesso.
  Future<bool> requestPermission() async {
    if (!supported) return false;
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> showNewDraw({
    required DateTime drawDate,
    required int inserted,
    required int evaluatedTickets,
    required int netCents,
    required int stakedCents,
    int superInserted = 0,
    int superTickets = 0,
  }) async {
    if (!supported) return;
    await initialize();
    final body = StringBuffer('Estrazione del ${formatItalianDate(drawDate)} in archivio');
    if (evaluatedTickets > 0) {
      body.write('. Schedine confrontate: $evaluatedTickets, netto simulato ${formatEuro(netCents)} su ${formatEuro(stakedCents)} di posta');
    }
    if (superInserted > 0) {
      body.write('. SuperEnalotto: $superInserted concorsi nuovi.');
    }
    if (superTickets > 0) {
      body.write('. Schedine SuperEnalotto confrontate: $superTickets, per categoria e non per importo.');
    }
    body.write('. Apri per vedere i risultati.');
    await _plugin.show(
      id: newDrawId,
      title: 'Nuova estrazione del Lotto',
      body: body.toString(),
      payload: ticketsRoute,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Esiti delle estrazioni',
          channelDescription: 'Avviso quando una nuova estrazione entra nell\'archivio locale.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(body.toString()),
        ),
      ),
    );
  }
}
