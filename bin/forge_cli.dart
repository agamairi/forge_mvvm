#!/usr/bin/env dart
// forge_cli — forge_mvvm project utilities
// Usage: dart run bin/forge_cli.dart <command> [args]

import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('create')
    ..addCommand('check')
    ..addCommand('test');

  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    _printUsage(parser);
    exitCode = 64;
    return;
  }

  switch (results.command?.name) {
    case 'create':
      await _handleCreate(results.command!);
    case 'check':
      await _handleCheck();
    case 'test':
      await _handleTest();
    default:
      _printUsage(parser);
      exitCode = 64;
  }
}

void _printUsage(ArgParser _) {
  stdout
    ..writeln()
    ..writeln('forge_cli — forge_mvvm project utilities')
    ..writeln()
    ..writeln('Usage: dart run bin/forge_cli.dart <command> [args]')
    ..writeln()
    ..writeln('Commands:')
    ..writeln('  create feature <name>   Scaffold a full clean-arch feature module')
    ..writeln('  check                   Run analyze + test (non-zero exit on failure)')
    ..writeln('  test                    Run flutter test');
}

// ── create ────────────────────────────────────────────────────────────────────

Future<void> _handleCreate(ArgResults command) async {
  if (command.rest.length < 2 || command.rest.first != 'feature') {
    stderr.writeln('Usage: dart run bin/forge_cli.dart create feature <name>');
    exitCode = 64;
    return;
  }

  final name = command.rest[1];
  final cls = _pascal(name);
  final fp = 'lib/features/$name';

  if (Directory(fp).existsSync()) {
    stderr.writeln('Feature "$name" already exists at $fp');
    exitCode = 64;
    return;
  }

  for (final d in [
    '$fp/domain/models',
    '$fp/domain/repositories',
    '$fp/domain/usecases',
    '$fp/data/services',
    '$fp/data/repositories',
    '$fp/ui',
    'test/features/$name',
  ]) {
    Directory(d).createSync(recursive: true);
  }

  _write('$fp/ui/${name}_viewmodel.dart', '''
import 'package:forge_mvvm/forge_mvvm.dart';

class ${cls}ViewModel extends ForgeViewModel {
  @override
  void onInit() {
    // TODO: load initial data
  }
}
''');

  _write('$fp/ui/${name}_view.dart', '''
import 'package:flutter/material.dart';
import 'package:forge_mvvm/forge_mvvm.dart';
import '${name}_viewmodel.dart';

class ${cls}View extends ForgeView<${cls}ViewModel> {
  const ${cls}View({super.key});

  @override
  ${cls}ViewModel createViewModel(BuildContext context) => ${cls}ViewModel();

  @override
  Widget buildView(BuildContext context, ${cls}ViewModel vm) {
    return ForgeStateWidget(
      viewModel: vm,
      data: (ctx, vm) => const Scaffold(
        body: Center(child: Text('$cls Screen')),
      ),
    );
  }
}
''');

  _write('$fp/domain/repositories/${name}_repository.dart', '''
import 'package:forge_mvvm/forge_mvvm.dart';

abstract class ${cls}Repository extends ForgeRepository {}
''');

  // Enforced failing stub — you must replace it before shipping
  _write('test/features/$name/${name}_viewmodel_test.dart', '''
import 'package:flutter_test/flutter_test.dart';
import '../../lib/features/$name/ui/${name}_viewmodel.dart';

void main() {
  late ${cls}ViewModel sut;

  setUp(() {
    sut = ${cls}ViewModel();
    sut.onInit();
  });

  tearDown(() => sut.dispose());

  // FORGE: This test MUST be replaced before you ship this feature.
  test('FORGE STUB — implement ${cls}ViewModel tests', () {
    expect(false, isTrue,
        reason: '[forge_mvvm] Write real tests for ${cls}ViewModel.');
  });
}
''');

  stdout
    ..writeln()
    ..writeln('Scaffolded feature: $name')
    ..writeln('  $fp/')
    ..writeln('  test/features/$name/${name}_viewmodel_test.dart')
    ..writeln()
    ..writeln('Next steps:')
    ..writeln('  1. Implement ${cls}ViewModel')
    ..writeln('  2. Add repository contract in $fp/domain/repositories/')
    ..writeln('  3. Register it in main.dart under ForgeApp.setUp()')
    ..writeln('  4. Replace the failing test stub with real tests');
}

// ── check ─────────────────────────────────────────────────────────────────────

Future<void> _handleCheck() async {
  stdout.writeln('[forge] Running flutter analyze...');
  final analyze = await Process.start('flutter', ['analyze'],
      mode: ProcessStartMode.inheritStdio);
  if (await analyze.exitCode != 0) {
    stderr.writeln('[forge] Analysis failed.');
    exitCode = 1;
    return;
  }
  stdout.writeln('[forge] Running flutter test...');
  final test = await Process.start('flutter', ['test'],
      mode: ProcessStartMode.inheritStdio);
  exitCode = await test.exitCode;
  if (exitCode == 0) {
    stdout.writeln('[forge] All checks passed.');
  } else {
    stderr.writeln('[forge] Tests FAILED — fix before committing.');
  }
}

// ── test ──────────────────────────────────────────────────────────────────────

Future<void> _handleTest() async {
  final t = await Process.start('flutter', ['test'],
      mode: ProcessStartMode.inheritStdio);
  exitCode = await t.exitCode;
}

// ── helpers ───────────────────────────────────────────────────────────────────

void _write(String path, String content) {
  File(path).writeAsStringSync(content);
  stdout.writeln('  created $path');
}

String _pascal(String s) => s
    .split('_')
    .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
    .join();
