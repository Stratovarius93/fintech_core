import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:flutter/material.dart' show Key, Offstage, SizedBox;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScreenStatusTypeX Extension', () {
    test('isInitial should return true for ScreenStatusType.initial', () {
      expect(ScreenStatusType.initial.isInitial, isTrue);
    });

    test('isLoading should return true for ScreenStatusType.loading', () {
      expect(ScreenStatusType.loading.isLoading, isTrue);
    });

    test('isReloading should return true for ScreenStatusType.reloading', () {
      expect(ScreenStatusType.reloading.isReloading, isTrue);
    });

    test('isSuccess should return true for ScreenStatusType.success', () {
      expect(ScreenStatusType.success.isSuccess, isTrue);
    });

    test('isError should return true for ScreenStatusType.error', () {
      expect(ScreenStatusType.error.isError, isTrue);
    });
  });

  group('BaseAsyncValueState', () {
    test('should have initial values', () {
      const state = BaseAsyncValueState<int>();

      expect(state.status, ScreenStatusType.initial);
      expect(state.value, isNull);
      expect(state.failure, isA<GeneralFailure>());
      if (state.failure is GeneralFailure) {
        expect((state.failure as GeneralFailure).message, 'Unknown error');
      }
    });

    test('should copyWith values correctly', () {
      const state = BaseAsyncValueState<int>();

      final newState = state.copyWith(
        status: ScreenStatusType.success,
        value: 42,
        failure: const GeneralFailure('Custom error'),
      );

      expect(newState.status, ScreenStatusType.success);
      expect(newState.value, 42);
      if (state.failure is GeneralFailure) {
        expect((state.failure as GeneralFailure).message, 'Unknown error');
      }
    });

    test('should allow using ServerFailure in copyWith', () {
      const state = BaseAsyncValueState<int>();

      final newState = state.copyWith(
        failure: const ServiceFailure('Server error', code: 500),
      );

      expect(newState.failure, isA<ServiceFailure>());

      if (state.failure is ServiceFailure) {
        expect((state.failure as ServiceFailure).message, 'Server error');
      }
      expect((newState.failure as ServiceFailure).code, 500);
    });

    test('props should contain status, value, and failure', () {
      const state = BaseAsyncValueState<int>();
      expect(state.props, [state.status, state.value, state.failure]);
    });
  });

  group('ScreenStatusTypeX functional methods', () {
    test('maybeWhen executes matching callback and orElse', () {
      var loadingCalled = false;
      var orElseCalled = false;

      ScreenStatusType.loading.maybeWhen(
        loading: () => loadingCalled = true,
        orElse: () => orElseCalled = true,
      );

      expect(loadingCalled, isTrue);
      expect(orElseCalled, isTrue);
    });

    test(
      'maybeWhen executes matching callback and orElse in ScreenStatusType.error',
      () {
        var errorCalled = false;
        var orElseCalled = false;

        ScreenStatusType.error.maybeWhen(
          error: () => errorCalled = true,
          orElse: () => orElseCalled = true,
        );

        expect(errorCalled, isTrue);
        expect(orElseCalled, isTrue);
      },
    );

    test(
      'maybeWhen executes matching callback and orElse in ScreenStatusType.success',
      () {
        var successCalled = false;
        var orElseCalled = false;

        ScreenStatusType.success.maybeWhen(
          success: () => successCalled = true,
          orElse: () => orElseCalled = true,
        );

        expect(successCalled, isTrue);
        expect(orElseCalled, isTrue);
      },
    );

    test(
      'maybeWhen executes matching callback and orElse in ScreenStatusType.reloading',
      () {
        var reloadingCalled = false;
        var orElseCalled = false;

        ScreenStatusType.reloading.maybeWhen(
          reloading: () => reloadingCalled = true,
          orElse: () => orElseCalled = true,
        );

        expect(reloadingCalled, isTrue);
        expect(orElseCalled, isTrue);
      },
    );

    test(
      'maybeWhen executes matching callback and orElse in ScreenStatusType.initial',
      () {
        var initialCalled = false;
        var orElseCalled = false;

        ScreenStatusType.initial.maybeWhen(
          initial: () => initialCalled = true,
          orElse: () => orElseCalled = true,
        );

        expect(initialCalled, isTrue);
        expect(orElseCalled, isTrue);
      },
    );

    test('maybeWhen without matching callback still calls orElse', () {
      var orElseCalled = false;

      ScreenStatusType.success.maybeWhen(
        loading: () {},
        orElse: () => orElseCalled = true,
      );

      expect(orElseCalled, isTrue);
    });

    test('whenProvided executes only provided callback for status', () {
      var successCalled = false;
      var otherCalled = false;

      ScreenStatusType.success.whenProvided(
        success: () => successCalled = true,
        loading: () => otherCalled = true,
      );

      expect(successCalled, isTrue);
      expect(otherCalled, isFalse);
    });

    test(
      'whenProvided executes only provided callback for status in ScreenStatusType.loading',
      () {
        var loadingCalled = false;
        var otherCalled = false;

        ScreenStatusType.loading.whenProvided(
          loading: () => loadingCalled = true,
          success: () => otherCalled = true,
        );

        expect(loadingCalled, isTrue);
        expect(otherCalled, isFalse);
      },
    );

    test(
      'whenProvided executes only provided callback for status in ScreenStatusType.reloading',
      () {
        var reloadingCalled = false;
        var otherCalled = false;

        ScreenStatusType.reloading.whenProvided(
          reloading: () => reloadingCalled = true,
          success: () => otherCalled = true,
        );

        expect(reloadingCalled, isTrue);
        expect(otherCalled, isFalse);
      },
    );

    test(
      'whenProvided executes only provided callback for status in ScreenStatusType.initial',
      () {
        var initialCalled = false;
        var otherCalled = false;

        ScreenStatusType.initial.whenProvided(
          initial: () => initialCalled = true,
          success: () => otherCalled = true,
        );

        expect(initialCalled, isTrue);
        expect(otherCalled, isFalse);
      },
    );

    test(
      'whenProvided executes only provided callback for status in ScreenStatusType.error',
      () {
        var errorCalled = false;
        var otherCalled = false;

        ScreenStatusType.error.whenProvided(
          error: () => errorCalled = true,
          success: () => otherCalled = true,
        );

        expect(errorCalled, isTrue);
        expect(otherCalled, isFalse);
      },
    );


    test('mapProvided returns Offstage when builder not provided', () {
      final w = ScreenStatusType.error.mapProvided(
        success: () => const SizedBox(),
      );

      expect(w, isA<Offstage>());
    });

    test('mapProvided returns provided widget', () {
      const k = Key('initial');
      final w = ScreenStatusType.initial.mapProvided(
        initial: () => const SizedBox(key: k),
      );

      expect((w as SizedBox).key, k);
    });

    test('mapProvided returns provided widget in ScreenStatusType.error', () {
      const k = Key('error');
      final w = ScreenStatusType.error.mapProvided(
        error: () => const SizedBox(key: k),
      );

      expect((w as SizedBox).key, k);
    });

    test('mapProvided returns provided widget in ScreenStatusType.loading', () {
      const k = Key('loading');
      final w = ScreenStatusType.loading.mapProvided(
        loading: () => const SizedBox(key: k),
      );

      expect((w as SizedBox).key, k);
    });

    test(
      'mapProvided returns provided widget in ScreenStatusType.reloading',
      () {
        const k = Key('reloading');
        final w = ScreenStatusType.reloading.mapProvided(
          reloading: () => const SizedBox(key: k),
        );

        expect((w as SizedBox).key, k);
      },
    );
    test('mapProvided returns provided widget in ScreenStatusType.success', () {
      const k = Key('success');
      final w = ScreenStatusType.success.mapProvided(
        success: () => const SizedBox(key: k),
      );

      expect((w as SizedBox).key, k);
    });
  });
}
