/// forge_mvvm — A Flutter MVVM + Clean Architecture framework.
library forge_mvvm;

// Core
export 'src/core/forge_app.dart';
export 'src/core/forge_exception.dart';
export 'src/core/forge_locator.dart';
export 'src/core/forge_result.dart';

// Data Layer
export 'src/data/forge_repository.dart';
export 'src/data/forge_service.dart';

// Domain Layer
export 'src/domain/forge_usecase.dart';

// Navigation
export 'src/navigation/forge_navigator.dart';

// Testing utilities
export 'src/testing/forge_mock_repository.dart';
export 'src/testing/forge_test_harness.dart';

// UI Layer
export 'src/ui/forge_command.dart';
export 'src/ui/forge_form_viewmodel.dart';
export 'src/ui/forge_paginated_viewmodel.dart';
export 'src/ui/forge_state_widget.dart';
export 'src/ui/forge_view.dart';
export 'src/ui/forge_viewmodel.dart';
