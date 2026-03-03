// ignore_for_file: avoid_print
/// Minimal example showing the forge_mvvm pattern.
///
/// For a full working app see the `example/lib/` directory.
library;

import 'package:flutter/material.dart';
import 'package:forge_mvvm/forge_mvvm.dart';

// ──────────────────────────────────────────────
// 1. Domain — Use Case
// ──────────────────────────────────────────────

class GreetParams {
  const GreetParams(this.name);
  final String name;
}

class GreetUseCase extends ForgeUseCase<GreetParams, ForgeResult<String>> {
  @override
  Future<ForgeResult<String>> execute(GreetParams params) async {
    if (params.name.isEmpty) {
      return ForgeResult.failure(
        const ForgeValidationException('Name cannot be empty'),
      );
    }
    return ForgeResult.success('Hello, ${params.name}!');
  }
}

// ──────────────────────────────────────────────
// 2. ViewModel
// ──────────────────────────────────────────────

class GreetViewModel extends ForgeViewModel {
  final _useCase = GreetUseCase();

  String _name = '';
  String _greeting = '';

  String get name => _name;
  String get greeting => _greeting;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  Future<void> greet() async {
    await runBusyAction(() async {
      final result = await _useCase.execute(GreetParams(_name));
      result.when(
        success: (msg) => _greeting = msg,
        failure: (e) => setError(e.toString()),
      );
    });
  }
}

// ──────────────────────────────────────────────
// 3. View
// ──────────────────────────────────────────────

class GreetView extends ForgeView<GreetViewModel> {
  const GreetView({super.key});

  @override
  GreetViewModel createViewModel(BuildContext context) => GreetViewModel();

  @override
  Widget buildView(BuildContext context, GreetViewModel vm) {
    return ForgeStateWidget(
      viewModel: vm,
      data: (_, viewModel) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: viewModel.setName,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.greet,
              child: const Text('Greet'),
            ),
            const SizedBox(height: 24),
            Text(
              viewModel.greeting,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
