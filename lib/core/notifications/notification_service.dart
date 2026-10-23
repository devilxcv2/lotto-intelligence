// lib/core/notifications/notification_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../lotto/freshness.dart';
import '../lotto/wheel_catalog.dart';
import '../settings/app_settings.dart';

/// Notifiche locali: nessun server, nessun token, solo Android.
/// Il payload è la rotta da aprire al tocco.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const resultsChannelId = 'draw_results';
  static const reminderChannelId = 'draw_reminders';
  static const newDrawId = 1001;
  static const preDrawId = 1002;
  static const archiveCheckId = 1003;
  static const ticketsRoute = '/tickets';
  static const dashboardRoute = '/dashboard';

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

  /// Mezz'ora prima della chiusura: l'estrazione è imminente, i risultati non sono subito online.
  Future<void> showPreDrawReminder({required DateTime drawDate}) async {
    if (!supported) return;
    await initialize();
    final body =
        'Oggi ${formatItalianDate(drawDate)} la raccolta chiude alle $salesCloseHour:${salesCloseMinute.toString().padLeft(2, '0')}. '
        'I numeri non compaiono subito dopo: di solito i risultati si vedono verso le $typicalResultsHour:${typicalResultsMinute.toString().padLeft(2, '0')}. '
        'Dalle $archiveCheckHour:${archiveCheckMinute.toString().padLeft(2, '0')} l\'app scarica lo ZIP ufficiale e ti avvisa quando è in archivio.';
    await _plugin.show(
      id: preDrawId,
      title: 'Estrazione del Lotto imminente',
      body: body,
      payload: dashboardRoute,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          reminderChannelId,
          'Avvisi pre-estrazione',
          channelDescription: 'Promemoria quando sta per chiudere la raccolta e i risultati non sono ancora online.',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }

  /// Alle 20:15, prima dello scarico: l'utente sa che il controllo è partito.
  Future<void> showArchiveCheckStarted({required DateTime drawDate}) async {
    if (!supported) return;
    await initialize();
    final body =
        'Sto scaricando lo ZIP ufficiale per l\'estrazione del ${formatItalianDate(drawDate)}. '
        'Se non è ancora pubblicato riproverò fino alle 23. Ti avviso quando entra in archivio.';
    await _plugin.show(
      id: archiveCheckId,
      title: 'Controllo archivio Lotto',
      body: body,
      payload: ticketsRoute,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          reminderChannelId,
          'Avvisi pre-estrazione',
          channelDescription: 'Promemoria quando sta per chiudere la raccolta e i risultati non sono ancora online.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
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
          resultsChannelId,
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
