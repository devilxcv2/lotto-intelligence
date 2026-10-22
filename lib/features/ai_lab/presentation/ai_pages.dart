// lib/features/ai_lab/presentation/ai_pages.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/lotto/wheel_catalog.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../draws/data/draw_repository.dart';
import '../data/ai_repository.dart';
import '../domain/local_engines.dart';

class AiLabPage extends ConsumerStatefulWidget {
  const AiLabPage({super.key});

  @override
  ConsumerState<AiLabPage> createState() => _AiLabPageState();
}

class _AiLabPageState extends ConsumerState<AiLabPage> {
  StudyProposal? _proposal;
  String? _message;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final wheel = ref.watch(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    return PageScaffold(
      title: 'AI Lab',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 12),
          Text('Ruota ${wheelByCode(wheel)?.name ?? wheel}. I motori A–C girano sul dispositivo. Il modello classico esterno e il runtime on-device non sono inclusi: si usano solo se configuri un provider.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _busy ? null : () => _run('uniform'), child: const Text('A · Casuale')),
              FilledButton(onPressed: _busy ? null : () => _run('frequency'), child: const Text('B · Frequenza')),
              FilledButton(onPressed: _busy ? null : () => _run('delay'), child: const Text('B · Ritardo')),
              FilledButton(onPressed: _busy ? null : () => _run('heuristic'), child: const Text('C · Filtro')),
            ],
          ),
          if (_message != null) ...[const SizedBox(height: 12), Text(_message!)],
          if (_proposal != null) ...[
            const SizedBox(height: 16),
            NumberBalls(numbers: _proposal!.numbers),
            const SizedBox(height: 8),
            Text(_proposal!.method),
            const SizedBox(height: 8),
            Text(_proposal!.rationale),
            const SizedBox(height: 8),
            Text(_proposal!.limitations),
            const SizedBox(height: 8),
            Text(_proposal!.datasetNote),
          ],
        ],
      ),
    );
  }

  Future<void> _run(String kind) async {
    setState(() => _busy = true);
    final wheel = ref.read(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final draws = await ref.read(drawRepositoryProvider).loadWheel(wheel);
    final seed = Random().nextInt(1 << 31);
    try {
      final proposal = switch (kind) {
        'frequency' => const DescriptiveWeightEngine().generate(wheelCode: wheel, history: draws, seed: seed, useDelay: false),
        'delay' => const DescriptiveWeightEngine().generate(wheelCode: wheel, history: draws, seed: seed, useDelay: true),
        'heuristic' => const HeuristicFilterEngine().generate(wheelCode: wheel, history: draws, seed: seed, minDelay: 0, evensOnly: false),
        _ => const UniformEngine().generate(wheelCode: wheel, seed: seed, datasetDraws: draws.length),
      };
      await ref.read(aiRepositoryProvider).saveProposal(proposal);
      if (mounted) setState(() => _proposal = proposal);
    } on StateError catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class AiModelsPage extends ConsumerStatefulWidget {
  const AiModelsPage({super.key});

  @override
  ConsumerState<AiModelsPage> createState() => _AiModelsPageState();
}

class _AiModelsPageState extends ConsumerState<AiModelsPage> {
  final _name = TextEditingController(text: 'Ollama locale');
  final _endpoint = TextEditingController(text: 'http://127.0.0.1:11434');
  final _model = TextEditingController(text: 'llama3.2');
  final _key = TextEditingController();
  var _provider = 'ollama';
  var _timeout = 30;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _endpoint.dispose();
    _model.dispose();
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final models = ref.watch(aiModelsProvider);
    return PageScaffold(
      title: 'Modelli AI',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('La chiave resta nel secure storage e non viene scritta nel database né nei log. Il modello locale non è obbligatorio.'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _provider,
            items: const [
              DropdownMenuItem(value: 'ollama', child: Text('Ollama')),
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
              DropdownMenuItem(value: 'openai_compatible', child: Text('Compatibile OpenAI')),
            ],
            onChanged: (value) => setState(() => _provider = value ?? 'ollama'),
          ),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome')),
          TextField(controller: _endpoint, decoration: const InputDecoration(labelText: 'Endpoint')),
          TextField(controller: _model, decoration: const InputDecoration(labelText: 'Modello')),
          TextField(controller: _key, obscureText: true, decoration: const InputDecoration(labelText: 'Chiave API, se serve')),
          Text('Timeout ${_timeout}s'),
          Slider(value: _timeout.toDouble(), min: 5, max: 120, divisions: 23, onChanged: (value) => setState(() => _timeout = value.round())),
          FilledButton(onPressed: _save, child: const Text('Salva configurazione')),
          if (_message != null) Text(_message!),
          const SizedBox(height: 16),
          AsyncBody<List<StoredAiModel>>(
            value: models,
            onRetry: () => ref.invalidate(aiModelsProvider),
            data: (items) => Column(
              children: [
                for (final item in items)
                  ListTile(
                    title: Text(item.displayName),
                    subtitle: Text('${item.provider} · ${item.modelName}\n${item.endpoint}'),
                    isThreeLine: true,
                    trailing: Wrap(
                      children: [
                        IconButton(tooltip: 'Prova connessione', onPressed: () => _test(item), icon: const Icon(Icons.wifi_tethering)),
                        IconButton(tooltip: 'Genera', onPressed: () => _generate(item), icon: const Icon(Icons.play_arrow)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    try {
      await ref.read(aiRepositoryProvider).save(
            provider: _provider,
            displayName: _name.text.trim(),
            endpoint: _endpoint.text.trim(),
            modelName: _model.text.trim(),
            timeoutSeconds: _timeout,
            apiKey: _key.text,
          );
      _key.clear();
      ref.invalidate(aiModelsProvider);
      setState(() => _message = 'Configurazione salvata. La chiave non è nel database.');
    } on StateError catch (error) {
      setState(() => _message = error.message);
    }
  }

  Future<void> _test(StoredAiModel model) async {
    try {
      final message = await ref.read(aiRepositoryProvider).testConnection(model);
      setState(() => _message = message);
    } on StateError catch (error) {
      setState(() => _message = error.message);
    }
  }

  Future<void> _generate(StoredAiModel model) async {
    final wheel = ref.read(settingsControllerProvider).value?.selectedWheelCode ?? 'BA';
    final draws = await ref.read(drawRepositoryProvider).loadWheel(wheel);
    try {
      final proposal = await ref.read(aiRepositoryProvider).generateRemote(
            model: model,
            wheelCode: wheel,
            datasetDraws: draws.length,
          );
      await ref.read(aiRepositoryProvider).saveProposal(proposal, modelId: model.id);
      setState(() => _message = 'Proposta salvata: ${proposal.numbers.join(', ')}. ${proposal.limitations}');
    } on StateError catch (error) {
      setState(() => _message = error.message);
    }
  }
}
