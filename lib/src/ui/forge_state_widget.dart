import 'package:flutter/material.dart';
import 'forge_viewmodel.dart';

/// Eliminates the loading/error/data if-else boilerplate on every screen.
class ForgeStateWidget<T extends ForgeViewModel> extends StatelessWidget {
  const ForgeStateWidget({
    required this.viewModel,
    required this.data,
    super.key,
    this.loading,
    this.error,
  });

  final T viewModel;
  final Widget Function(BuildContext context, T vm) data;
  final Widget Function(BuildContext context)? loading;
  final Widget Function(BuildContext context, String message)? error;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return loading?.call(context) ??
          const Center(child: CircularProgressIndicator.adaptive());
    }
    if (viewModel.errorMessage != null) {
      return error?.call(context, viewModel.errorMessage!) ??
          Center(child: Text(viewModel.errorMessage!));
    }
    return data(context, viewModel);
  }
}
