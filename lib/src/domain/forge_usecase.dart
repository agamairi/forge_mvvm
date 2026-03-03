abstract class ForgeUseCase<Input, Output> {
  const ForgeUseCase();
  Future<Output> execute(Input input);
}

abstract class ForgeUseCaseNoParams<Output> {
  const ForgeUseCaseNoParams();
  Future<Output> execute();
}
