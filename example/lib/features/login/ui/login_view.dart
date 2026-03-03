import 'package:flutter/material.dart';
import 'package:forge_mvvm/forge_mvvm.dart';
import '../domain/repositories/auth_repository.dart';
import 'login_viewmodel.dart';

class LoginView extends ForgeView<LoginViewModel> {
  const LoginView({super.key});

  @override
  LoginViewModel createViewModel(BuildContext context) =>
      LoginViewModel(ForgeLocator.get<AuthRepository>());

  @override
  Widget buildView(BuildContext context, LoginViewModel vm) {
    if (vm.isLoggedIn) return _WelcomeScreen(vm: vm);
    return _LoginForm(vm: vm);
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.vm});
  final LoginViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('forge_mvvm — Login Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (vm.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  vm.errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'test@forge.dev',
                border: OutlineInputBorder(),
              ),
              onChanged: vm.setEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'password',
                border: OutlineInputBorder(),
              ),
              onChanged: vm.setPassword,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : vm.login,
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hint: use test@forge.dev / password',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen({required this.vm});
  final LoginViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome!')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Hello, \${vm.currentUser!.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(vm.currentUser!.email,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: vm.logout, child: const Text('Logout')),
          ],
        ),
      ),
    );
  }
}
