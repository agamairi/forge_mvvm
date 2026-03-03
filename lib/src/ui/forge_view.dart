import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'forge_viewmodel.dart';

/// Abstract base for all screen-level widgets in a forge_mvvm application.
///
/// Subclasses MUST implement [createViewModel] and [buildView].
abstract class ForgeView<T extends ForgeViewModel> extends StatefulWidget {
  const ForgeView({super.key});

  @protected
  T createViewModel(BuildContext context);

  @protected
  Widget buildView(BuildContext context, T viewModel);

  @override
  State<ForgeView<T>> createState() => _ForgeViewState<T>();
}

class _ForgeViewState<T extends ForgeViewModel> extends State<ForgeView<T>> {
  late final T _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.createViewModel(context);
    _viewModel.onInit();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: _viewModel,
      child: Consumer<T>(
        builder: (ctx, vm, _) => widget.buildView(ctx, vm),
      ),
    );
  }
}
