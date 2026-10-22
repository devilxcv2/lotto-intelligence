// lib/features/ai_lab/data/ai_repository.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/lotto/draw_validation.dart';
import '../../../core/lotto/scientific_notice.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/endpoint_policy.dart';
import '../../../core/security/secret_store.dart';
import '../domain/local_engines.dart';

class StoredAiModel {
  const StoredAiModel({
    required this.id,
    required this.provider,
    required this.displayName,
    required this.endpoint,
    required this.modelName,
    required this.enabled,
    required this.timeoutSeconds,
  });

  final int id;
  final String provider;
  final String displayName;
  final String endpoint;
  final String modelName;
  final bool enabled;
  final int timeoutSeconds;
}

class AiRepository {
  AiRepository(this._db, this._dio, this._secrets);

  final AppDatabase _db;
  final Dio _dio;
  final SecretStore _secrets;

  Future<List<StoredAiModel>> list() async {
    final rows = await _db.select(_db.aiModels).get();
    return [
      for (final row in rows)
        StoredAiModel(
          id: row.id,
          provider: row.provider,
          displayName: row.displayName,
          endpoint: row.endpoint,
          modelName: row.modelName,
          enabled: row.enabled,
          timeoutSeconds: row.timeoutSeconds,
        ),
    ];
  }

  Future<int> save({
    int? id,
    required String provider,
    required String displayName,
    required String endpoint,
    required String modelName,
    required int timeoutSeconds,
    String? apiKey,
  }) async {
    final uri = Uri.tryParse(endpoint.trim());
    if (uri == null || !isAllowedAiEndpoint(uri)) {
      throw StateError('Indirizzo non ammesso. HTTPS ovunque; HTTP solo su localhost o rete privata.');
    }
    final modelId = id ??
        await _db.into(_db.aiModels).insert(AiModelsCompanion.insert(
              provider: provider,
              displayName: displayName,
              endpoint: uri.toString(),
              modelName: modelName,
              timeoutSeconds: Value(timeoutSeconds),
              enabled: const Value(true),
              createdAt: DateTime.now().toUtc(),
            ));
    if (id != null) {
      await (_db.update(_db.aiModels)..where((row) => row.id.equals(id))).write(AiModelsCompanion(
            provider: Value(provider),
            displayName: Value(displayName),
            endpoint: Value(uri.toString()),
            modelName: Value(modelName),
            timeoutSeconds: Value(timeoutSeconds),
            enabled: const Value(true),
          ));
    }
    if (apiKey != null && apiKey.isNotEmpty) {
      await _secrets.write(modelSecretKey(modelId), apiKey);
    }
    return modelId;
  }

  Future<String> testConnection(StoredAiModel model) async {
    final started = DateTime.now().toUtc();
    try {
      final key = await _secrets.read(modelSecretKey(model.id));
      final uri = _join(model.endpoint, model.provider == 'ollama' ? '/api/tags' : '/models');
      final response = await _dio.get<dynamic>(
        uri,
        options: _options(model, key),
      );
      await _log(model.id, started, true, 'GET ${model.provider == 'ollama' ? '/api/tags' : '/models'} -> HTTP ${response.statusCode}');
      return 'Connessione riuscita (HTTP ${response.statusCode}).';
    } on DioException catch (error) {
      final message = _publicError(error);
      await _log(model.id, started, false, message);
      throw StateError(message);
    }
  }

  Future<StudyProposal> generateRemote({
    required StoredAiModel model,
    required String wheelCode,
    required int datasetDraws,
  }) async {
    final started = DateTime.now().toUtc();
    final key = await _secrets.read(modelSecretKey(model.id));
    final system =
        'Rispondi solo con un oggetto JSON con i campi numbers (5 interi distinti fra 1 e 90), method e rationale. '
        'Non assegnare probabilità, percentuali di affidabilità o numeri sicuri. '
        'Se non hai dati, dillo in rationale.';
    final user = 'Proponi una cinquina di studio per la ruota $wheelCode. Estrazioni locali disponibili: $datasetDraws. Non calcolare una probabilità.';
    try {
      final content = model.provider == 'ollama'
          ? await _ollama(model, key, system, user)
          : await _openai(model, key, system, user);
      final proposal = _parse(content, model, wheelCode, datasetDraws);
      await _log(model.id, started, true, 'Generazione JSON accettata per $wheelCode');
      return proposal;
    } on DioException catch (error) {
      final message = _publicError(error);
      await _log(model.id, started, false, message);
      throw StateError(message);
    } catch (error) {
      final message = error is StateError ? error.message : 'Risposta del modello non utilizzabile.';
      await _log(model.id, started, false, message);
      throw StateError(message);
    }
  }

  Future<int> saveProposal(StudyProposal proposal, {int? modelId}) async {
    return _db.transaction(() async {
      final id = await _db.into(_db.predictions).insert(PredictionsCompanion.insert(
            modelId: Value(modelId),
            wheelCode: proposal.config['wheel'] as String? ?? '',
            generatedAt: DateTime.now().toUtc(),
            engineId: proposal.engineId,
            engineVersion: proposal.engineVersion,
            method: proposal.method,
            rationale: proposal.rationale,
            limitations: proposal.limitations,
            datasetNote: proposal.datasetNote,
            configJson: jsonEncode(proposal.config),
          ));
      await _db.batch((batch) {
        batch.insertAll(_db.predictionNumbers, [
          for (var i = 0; i < proposal.numbers.length; i++)
            PredictionNumbersCompanion.insert(predictionId: id, position: i + 1, number: proposal.numbers[i]),
        ]);
      });
      return id;
    });
  }

  Future<String> _openai(StoredAiModel model, String? key, String system, String user) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _join(model.endpoint, '/chat/completions'),
      data: {
        'model': model.modelName,
        'temperature': 0.2,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
      },
      options: _options(model, key),
    );
    final choices = response.data?['choices'];
    if (choices is! List || choices.isEmpty) throw StateError('Risposta senza choices.');
    final message = choices.first;
    if (message is! Map) throw StateError('Messaggio non valido.');
    final content = message['message'];
    if (content is! Map || content['content'] is! String) throw StateError('Contenuto assente.');
    return content['content'] as String;
  }

  Future<String> _ollama(StoredAiModel model, String? key, String system, String user) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _join(model.endpoint, '/api/chat'),
      data: {
        'model': model.modelName,
        'stream': false,
        'format': 'json',
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
      },
      options: _options(model, key),
    );
    final message = response.data?['message'];
    if (message is! Map || message['content'] is! String) throw StateError('Ollama non ha restituito JSON.');
    return message['content'] as String;
  }

  StudyProposal _parse(String raw, StoredAiModel model, String wheelCode, int datasetDraws) {
    final cleaned = raw.trim().replaceFirst(RegExp(r'^```json'), '').replaceFirst(RegExp(r'^```'), '').replaceFirst(RegExp(r'```$'), '').trim();
    final decoded = jsonDecode(cleaned);
    if (decoded is! Map) throw StateError('Il modello non ha restituito un oggetto JSON.');
    final numbersRaw = decoded['numbers'];
    if (numbersRaw is! List) throw StateError('Manca il campo numbers.');
    final numbers = <int>[];
    for (final value in numbersRaw) {
      if (value is int) {
        numbers.add(value);
      } else {
        final parsed = int.tryParse('$value');
        if (parsed == null) throw StateError('Numero non intero nella risposta.');
        numbers.add(parsed);
      }
    }
    final validation = validateDrawNumbers(numbers);
    if (!validation.isValid) throw StateError(validation.error!);
    return StudyProposal(
      engineId: 'remote-${model.provider}',
      engineVersion: model.modelName,
      numbers: validation.numbers!,
      method: '${decoded['method'] ?? 'Proposta del modello'}',
      rationale: '${decoded['rationale'] ?? 'Il modello non ha spiegato la scelta.'} Eventuali probabilità presenti nella risposta sono state ignorate.',
      limitations: 'Il testo del modello non è una misura di accuratezza. $scientificDisclaimer',
      datasetNote: 'Ruota $wheelCode. Estrazioni locali note all\'app: $datasetDraws. Il modello remoto può non averle viste.',
      config: {'wheel': wheelCode, 'provider': model.provider, 'model': model.modelName, 'window': datasetDraws},
    );
  }

  Options _options(StoredAiModel model, String? key) {
    return Options(
      headers: {
        if (key != null && key.isNotEmpty) 'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      sendTimeout: Duration(seconds: model.timeoutSeconds),
      receiveTimeout: Duration(seconds: model.timeoutSeconds),
      responseType: ResponseType.json,
    );
  }

  String _join(String endpoint, String path) {
    final base = endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;
    return '$base$path';
  }

  String _publicError(DioException error) {
    final code = error.response?.statusCode;
    if (code == 401 || code == 403) return 'Autenticazione rifiutata (HTTP $code).';
    if (code != null) return 'Il provider ha risposto HTTP $code.';
    return 'Connessione al provider non riuscita.';
  }

  Future<void> _log(int modelId, DateTime started, bool success, String summary) {
    return _db.into(_db.aiExecutionLogs).insert(AiExecutionLogsCompanion.insert(
          modelId: Value(modelId),
          startedAt: started,
          finishedAt: Value(DateTime.now().toUtc()),
          success: success,
          errorMessage: Value(success ? null : summary),
          requestSummary: summary,
        ));
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(databaseProvider), ref.watch(dioProvider), ref.watch(secretStoreProvider));
});

final aiModelsProvider = FutureProvider<List<StoredAiModel>>((ref) {
  return ref.watch(aiRepositoryProvider).list();
});
