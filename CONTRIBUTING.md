# Contributing to forge_mvvm

Thank you for considering contributing to forge_mvvm! Every contribution helps
make Flutter architecture more accessible.

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/forge_mvvm.git
   cd forge_mvvm
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

## Development Workflow

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feat/your-feature
   ```
2. Make your changes in `lib/src/`.
3. **Write tests** — PRs without tests will not be merged. Place tests in the
   matching `test/` subdirectory.
4. Ensure everything passes:
   ```bash
   dart run bin/forge_cli.dart check   # runs flutter analyze + flutter test
   ```
5. Commit with a clear, descriptive message.

## Pull Request Guidelines

- Keep PRs focused — one feature or fix per PR.
- Update `CHANGELOG.md` under an **Unreleased** section.
- Update `README.md` if you add or change public API.
- Ensure `dart format .` produces no diffs.
- All CI checks must pass before merge.

## Code Style

- Follow the lints defined in `analysis_options.yaml`.
- Use `dart format` with the default line length.
- Prefer `const` constructors where possible.
- Always declare return types.

## Reporting Issues

- Use the [GitHub Issues](https://github.com/agamairi/forge_mvvm/issues) tracker.
- Include a minimal reproduction, Dart/Flutter version, and expected vs. actual
  behaviour.

## License

By contributing you agree that your contributions will be licensed under the
[MIT License](LICENSE).
