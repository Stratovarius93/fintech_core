part of 'base_async_value_bloc.dart';

enum ScreenStatusType { initial, loading, reloading, success, error }

extension ScreenStatusTypeX on ScreenStatusType {
  bool get isInitial => this == ScreenStatusType.initial;
  bool get isLoading => this == ScreenStatusType.loading;
  bool get isReloading => this == ScreenStatusType.reloading;
  bool get isSuccess => this == ScreenStatusType.success;
  bool get isError => this == ScreenStatusType.error;

  void maybeWhen({
    void Function()? initial,
    void Function()? loading,
    void Function()? reloading,
    void Function()? success,
    void Function()? error,
    required void Function() orElse,
  }) {
    switch (this) {
      case ScreenStatusType.initial:
        if (initial != null) initial();
        break;
      case ScreenStatusType.loading:
        if (loading != null) loading();
        break;
      case ScreenStatusType.reloading:
        if (reloading != null) reloading();
        break;
      case ScreenStatusType.success:
        if (success != null) success();
        break;
      case ScreenStatusType.error:
        if (error != null) error();
        break;
    }
    orElse();
  }

  void whenProvided({
    void Function()? initial,
    void Function()? loading,
    void Function()? reloading,
    void Function()? success,
    void Function()? error,
  }) {
    switch (this) {
      case ScreenStatusType.initial:
        initial?.call();
        break;
      case ScreenStatusType.loading:
        loading?.call();
        break;
      case ScreenStatusType.reloading:
        reloading?.call();
        break;
      case ScreenStatusType.success:
        success?.call();
        break;
      case ScreenStatusType.error:
        error?.call();
        break;
    }
  }

  Widget mapProvided({
    Widget Function()? initial,
    Widget Function()? loading,
    Widget Function()? reloading,
    Widget Function()? success,
    Widget Function()? error,
  }) {
    switch (this) {
      case ScreenStatusType.initial:
        return initial?.call() ?? const Offstage();
      case ScreenStatusType.loading:
        return loading?.call() ?? const Offstage();
      case ScreenStatusType.reloading:
        return reloading?.call() ?? const Offstage();
      case ScreenStatusType.success:
        return success?.call() ?? const Offstage();
      case ScreenStatusType.error:
        return error?.call() ?? const Offstage();
    }
  }
}

class BaseAsyncValueState<T> extends Equatable {
  const BaseAsyncValueState({
    ScreenStatusType? status,
    this.value,
    Failure? failure,
  }) : status = status ?? ScreenStatusType.initial,
       failure = failure ?? const GeneralFailure('Unknown error');

  final ScreenStatusType status;
  final T? value;
  final Failure failure;

  BaseAsyncValueState<T> copyWith({
    ScreenStatusType? status,
    T? value,
    Failure? failure,
  }) => BaseAsyncValueState(
    status: status ?? this.status,
    value: value ?? this.value,
    failure: failure ?? this.failure,
  );
  @override
  List<Object?> get props => [status, value, failure];
}
