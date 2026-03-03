## 0.2.0

* Added `ForgeNavigator` — ViewModel-driven navigation via `NavigationEvent` streams.
* Added `ForgePaginatedViewModel` — page-based pagination with `loadPage()` override.
* Added `ForgeFormViewModel` — per-field form validation with `validateAll()`.
* Added `ForgeStateWidget` — eliminates loading/error boilerplate in views.
* Expanded `ForgeException` hierarchy: `ForgeNetworkException`, `ForgeServerException`, `ForgeCacheException`, `ForgeValidationException`.
* Improved `ForgeApp.setUp()` with debug-mode bootstrap summary.

## 0.1.0

* Initial release.
* Core MVVM base classes: `ForgeView`, `ForgeViewModel`.
* Clean Architecture layers: `ForgeRepository`, `ForgeService`, `ForgeUseCase`.
* Dependency injection via `ForgeLocator` (get_it wrapper).
* `ForgeApp` bootstrap with layer-order enforcement.
* `ForgeCommand` pattern for async actions.
* `ForgeResult` type-safe success/failure wrapper.
* Built-in test utilities: `ForgeTestHarness`, `ForgeMockRepository`.
* Example app demonstrating a full Login feature.
