import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/data_async_value/params/base_async_value_params.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBaseDataBloc extends Mock
    implements BaseDataBloc<int, BaseAsyncValueParams> {}

class MockBaseAsyncValueParams extends Mock implements BaseAsyncValueParams {}

class MockBaseDataBlocRestore extends Mock
    implements BaseDataBloc<int, BaseAsyncValueParams> {
  MockBaseDataBlocRestore() {
    when(() => stream).thenAnswer((_) async* {
      yield const BaseAsyncValueState<int>();
    });
  }
}

class MockBaseDataBlocUpdated extends Mock
    implements BaseDataBloc<int, BaseAsyncValueParams> {
  MockBaseDataBlocUpdated() {
    when(() => stream).thenAnswer((_) async* {
      yield const BaseAsyncValueState<int>(value: 100);
    });
  }
}

class _TestBloc extends BaseDataBloc<int, BaseAsyncValueParams> {
  @override
  Future<Either<Failure, int>> repositoryCall(
    BaseAsyncValueParams? params,
  ) async {
    return const Right(0);
  }
}

class _FailTestBloc extends BaseDataBloc<int, BaseAsyncValueParams> {
  @override
  Future<Either<Failure, int>> repositoryCall(
    BaseAsyncValueParams? params,
  ) async {
    return const Left(GeneralFailure('Reload failed'));
  }
}

void main() {
  late MockBaseDataBloc bloc;
  late MockBaseDataBlocRestore blocRestore;
  late MockBaseAsyncValueParams params;
  late MockBaseDataBlocUpdated blocUpdated;

  setUp(() {
    bloc = MockBaseDataBloc();
    blocRestore = MockBaseDataBlocRestore();
    params = MockBaseAsyncValueParams();
    blocUpdated = MockBaseDataBlocUpdated();

    when(() => bloc.state).thenReturn(const BaseAsyncValueState<int>());
    when(() => bloc.stream).thenAnswer((_) async* {
      yield const BaseAsyncValueState<int>();
    });
    when(() => blocRestore.stream).thenAnswer((_) async* {
      yield const BaseAsyncValueState<int>();
    });
    when(() => blocRestore.add(const RestoreData())).thenAnswer((_) async {});

    when(() => bloc.close()).thenAnswer((_) async => Future.value());
    when(() => blocRestore.close()).thenAnswer((_) async => Future.value());
    when(() => blocUpdated.stream).thenAnswer((_) async* {
      yield const BaseAsyncValueState<int>(value: 100);
    });
    when(
      () => blocUpdated.add(const UpdateData(value: 100)),
    ).thenAnswer((_) async {});
  });

  group('BaseDataBloc', () {
    blocTest<MockBaseDataBloc, BaseAsyncValueState<int>>(
      'emits [loading, success] when repositoryCall is successful',
      build: () {
        when(
          () => bloc.repositoryCall(params),
        ).thenAnswer((_) async => const Right(42));
        whenListen(
          bloc,
          Stream.fromIterable([
            const BaseAsyncValueState<int>(status: ScreenStatusType.loading),
            const BaseAsyncValueState<int>(
              status: ScreenStatusType.success,
              value: 42,
            ),
          ]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const CallAction(params: BaseAsyncValueParams())),
      expect: () => [
        const BaseAsyncValueState<int>(status: ScreenStatusType.loading),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.success,
          value: 42,
        ),
      ],
    );

    blocTest<MockBaseDataBloc, BaseAsyncValueState<int>>(
      'emits [loading, error] when repositoryCall fails',
      build: () {
        when(() => bloc.repositoryCall(params)).thenAnswer(
          (_) async => const Left(ServiceFailure('Server Error', code: 500)),
        );
        whenListen(
          bloc,
          Stream.fromIterable([
            const BaseAsyncValueState<int>(status: ScreenStatusType.loading),
            const BaseAsyncValueState<int>(
              status: ScreenStatusType.error,
              failure: ServiceFailure('Server Error', code: 500),
            ),
          ]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const CallAction(params: BaseAsyncValueParams())),
      expect: () => [
        const BaseAsyncValueState<int>(status: ScreenStatusType.loading),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.error,
          failure: ServiceFailure('Server Error', code: 500),
        ),
      ],
    );

    blocTest<MockBaseDataBloc, BaseAsyncValueState<int>>(
      'emits [reloading, success] when ReloadData is triggered and successful',
      build: () {
        when(
          () => bloc.repositoryCall(params),
        ).thenAnswer((_) async => const Right(88));
        whenListen(
          bloc,
          Stream.fromIterable([
            const BaseAsyncValueState<int>(status: ScreenStatusType.reloading),
            const BaseAsyncValueState<int>(
              status: ScreenStatusType.success,
              value: 88,
            ),
          ]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const ReloadData(params: BaseAsyncValueParams())),
      expect: () => [
        const BaseAsyncValueState<int>(status: ScreenStatusType.reloading),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.success,
          value: 88,
        ),
      ],
    );

    blocTest<MockBaseDataBloc, BaseAsyncValueState<int>>(
      'emits [reloading, error] when ReloadData is triggered and fails',
      build: () {
        when(
          () => bloc.repositoryCall(params),
        ).thenAnswer((_) async => const Left(GeneralFailure('Reload Error')));
        whenListen(
          bloc,
          Stream.fromIterable([
            const BaseAsyncValueState<int>(status: ScreenStatusType.reloading),
            const BaseAsyncValueState<int>(
              status: ScreenStatusType.error,
              failure: GeneralFailure('Reload Error'),
            ),
          ]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const ReloadData(params: BaseAsyncValueParams())),
      expect: () => [
        const BaseAsyncValueState<int>(status: ScreenStatusType.reloading),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.error,
          failure: GeneralFailure('Reload Error'),
        ),
      ],
    );

    blocTest<MockBaseDataBloc, BaseAsyncValueState<int>>(
      'emits initial state when RestoreData is called',
      build: () {
        whenListen(
          bloc,
          Stream.fromIterable([const BaseAsyncValueState<int>()]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const RestoreData()),
      expect: () => [const BaseAsyncValueState<int>()],
    );
    blocTest<MockBaseDataBloc, BaseAsyncValueState<int>>(
      'emits initial state when ReloadData is called',
      build: () {
        whenListen(
          bloc,
          Stream.fromIterable([const BaseAsyncValueState<int>()]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const ReloadData(params: BaseAsyncValueParams())),
      expect: () => [const BaseAsyncValueState<int>()],
    );

    // test('onReloadData should emit initial state', () {
    //   final blocReload = MockBaseDataBloc();
    //   final states = <BaseAsyncValueState<int>>[];
    //   final expectedStates = <BaseAsyncValueState<int>>[
    //     const BaseAsyncValueState<int>(status: ScreenStatusType.reloading),
    //     const BaseAsyncValueState<int>(),
    //   ];
    //   blocReload.stream.listen(states.add);
    //   blocReload.add(const ReloadData(params: BaseAsyncValueParams()));
    //   Future.delayed(Duration.zero, () {
    //     expect(states, expectedStates);
    //   });
    // });

    test('restoreData should emit initial state', () {
      final blocRestore = MockBaseDataBlocRestore();
      final states = <BaseAsyncValueState<int>>[];
      final expectedStates = <BaseAsyncValueState<int>>[
        const BaseAsyncValueState<int>(),
      ];
      blocRestore.stream.listen(states.add);
      blocRestore.add(const RestoreData());
      Future.delayed(Duration.zero, () {
        expect(states, expectedStates);
      });
    });

    blocTest<MockBaseDataBloc, BaseAsyncValueState<int>>(
      'emits initial state when UpdatedData is called',
      build: () {
        whenListen(
          bloc,
          Stream.fromIterable([const BaseAsyncValueState<int>(value: 200)]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateData(value: 200)),
      expect: () => [const BaseAsyncValueState<int>(value: 200)],
    );

    test('updateData should emit updated state', () {
      final blocUpdated = MockBaseDataBlocUpdated();
      final states = <BaseAsyncValueState<int>>[];
      final expectedStates = <BaseAsyncValueState<int>>[
        const BaseAsyncValueState<int>(value: 100),
      ];
      blocUpdated.stream.listen(states.add);
      blocUpdated.add(const UpdateData(value: 100));
      Future.delayed(Duration.zero, () {
        expect(states, expectedStates);
      });
    });
  });

  group('BaseDataBloc convenience methods', () {
    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'callToUpdate emits updated value state',
      build: () => _TestBloc(),
      act: (bloc) => bloc.callToUpdate(123),
      expect: () => [
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: 123,
        ),
      ],
    );
    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'reload emits reloading then success states (if previously successful)',
      build: () => _TestBloc(),
      seed: () => const BaseAsyncValueState<int>(
        status: ScreenStatusType.success,
        value: 10,
      ),
      act: (bloc) => bloc.reload(const BaseAsyncValueParams()),
      // ReloadData is debounced (reloadDebounceDuration = 100ms), so wait past
      // the debounce window before asserting the emitted states.
      wait: const Duration(milliseconds: 150),
      expect: () => [
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.reloading,
          value: 10,
        ),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.success,
          value: 0,
        ),
      ],
    );

    blocTest<_FailTestBloc, BaseAsyncValueState<int>>(
      'reload emits [reloading, error] when repositoryCall returns Left',
      build: () => _FailTestBloc(),
      seed: () => const BaseAsyncValueState<int>(
        status: ScreenStatusType.success,
        value: 10,
      ),
      act: (bloc) => bloc.reload(const BaseAsyncValueParams()),
      // ReloadData is debounced (reloadDebounceDuration = 100ms), so wait past
      // the debounce window before asserting the emitted states.
      wait: const Duration(milliseconds: 150),
      expect: () => [
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.reloading,
          value: 10,
        ),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.error,
          failure: GeneralFailure('Reload failed'),
          value: null,
        ),
      ],
    );

    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'reload does NOTHING when current status is initial',
      build: () => _TestBloc(),
      act: (bloc) => bloc.reload(const BaseAsyncValueParams()),
      expect: () => [],
    );

    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'reload does NOTHING when current status is loading',
      build: () => _TestBloc(),
      seed: () =>
          const BaseAsyncValueState<int>(status: ScreenStatusType.loading),
      act: (bloc) => bloc.reload(const BaseAsyncValueParams()),
      expect: () => [],
    );

    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'clear emits reset initial state with GeneralFailure',
      build: () => _TestBloc(),
      act: (bloc) => bloc.clear(),
      expect: () => [
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: null,
          failure: GeneralFailure('Unknown error'),
        ),
      ],
    );

    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'callToUpdate then clear emits updated then reset states',
      build: () => _TestBloc(),
      act: (bloc) {
        bloc.callToUpdate(55);
        bloc.clear();
      },
      expect: () => [
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: 55,
        ),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: null,
          failure: GeneralFailure('Unknown error'),
        ),
      ],
    );

    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'two consecutive callToUpdate calls emit two updated states',
      build: () => _TestBloc(),
      act: (bloc) {
        bloc.callToUpdate(10);
        bloc.callToUpdate(20);
      },
      expect: () => [
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: 10,
        ),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: 20,
        ),
      ],
    );

    blocTest<_TestBloc, BaseAsyncValueState<int>>(
      'update after clear still works',
      build: () => _TestBloc(),
      act: (bloc) {
        bloc.callToUpdate(1);
        bloc.clear();
        bloc.callToUpdate(2);
      },
      expect: () => [
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: 1,
        ),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: null,
          failure: GeneralFailure('Unknown error'),
        ),
        const BaseAsyncValueState<int>(
          status: ScreenStatusType.initial,
          value: 2,
        ),
      ],
    );
  });
}
