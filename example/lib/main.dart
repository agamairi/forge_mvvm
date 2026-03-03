import 'package:flutter/material.dart';
import 'package:forge_mvvm/forge_mvvm.dart';
import 'features/login/data/repositories/auth_repository_impl.dart';
import 'features/login/data/services/auth_service_impl.dart';
import 'features/login/domain/repositories/auth_repository.dart';
import 'features/login/ui/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ForgeApp.setUp(
    services: [() => AuthServiceImpl()],
    repositories: [
      () => AuthRepositoryImpl(ForgeLocator.get<AuthServiceImpl>()),
    ],
  );

  // Register the abstract type so ForgeLocator.get<AuthRepository>() works
  ForgeLocator.registerSingleton<AuthRepository>(
    ForgeLocator.get<AuthRepositoryImpl>(),
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'forge_mvvm Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const LoginView(),
    );
  }
}
