import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../errors/failures.dart';
import 'params/base_async_value_params.dart';

part 'base_async_value_event.dart';
part 'base_async_value_state.dart';

EventTransformer<E> debounceRestartable<E>({
  required Duration duration,
  bool leading = false,
  bool trailing = true,
}) {
  return (events, mapper) {
    final debounced = duration > Duration.zero
        ? events.debounce(duration, leading: leading, trailing: trailing)
        : events;

    return restartable<E>().call(debounced, mapper);
  };
}

abstract class BaseDataBloc<T, P extends BaseAsyncValueParams>
    extends Bloc<BaseAsyncValueEvent, BaseAsyncValueState<T>> {
  BaseDataBloc({
    this.reloadDebounceDuration = const Duration(milliseconds: 100),
    EventTransformer<CallAction<P>>? callTransformer,
  }) : super(BaseAsyncValueState<T>(status: ScreenStatusType.initial)) {
    on<CallAction<P>>(onCallAction, transformer: callTransformer);
    on<ReloadData<P>>(
      onReloadData,
      transformer: debounceRestartable(duration: reloadDebounceDuration),
    );
    on<RestoreData>(restoreData);
    on<UpdateData<T>>(updateData);
  }

  final Duration reloadDebounceDuration;

  FutureOr<void> onCallAction(
    CallAction<P> event,
    Emitter<BaseAsyncValueState<T>> emit,
  ) async {
    emit(state.copyWith(status: ScreenStatusType.loading));

    final res = await repositoryCall(event.params);
    res.fold(
      (l) => onFailure(emit, l),
      (r) => onSuccess(emit, r, event.params),
    );
  }

  FutureOr<void> onReloadData(
    ReloadData<P> event,
    Emitter<BaseAsyncValueState<T>> emit,
  ) async {
    if (!state.status.isSuccess && !state.status.isError) {
      return;
    }
    emit(state.copyWith(status: ScreenStatusType.reloading));

    final res = await repositoryCall(event.params);
    res.fold(
      (l) => onFailure(emit, l),
      (r) => onSuccess(emit, r, event.params),
    );
  }

  void call(P params) {
    add(CallAction(params: params));
  }

  void reload(P params) {
    add(ReloadData(params: params));
  }

  void callToUpdate(T values) {
    add(UpdateData<T>(value: values));
  }

  void clear() {
    add(const RestoreData());
  }

  void restoreData(RestoreData event, Emitter<BaseAsyncValueState<T>> emit) {
    emit(
      BaseAsyncValueState(
        status: ScreenStatusType.initial,
        value: null,
        failure: const GeneralFailure('Unknown error'),
      ),
    );
  }

  void onFailure(Emitter<BaseAsyncValueState<T>> emit, Failure failure) {
    emit(
      BaseAsyncValueState<T>(
        status: ScreenStatusType.error,
        failure: failure,
        value: null,
      ),
    );
  }

  void onSuccess(
    Emitter<BaseAsyncValueState<T>> emit,
    T value,
    BaseAsyncValueParams? params,
  ) {
    emit(state.copyWith(status: ScreenStatusType.success, value: value));
  }

  Future<Either<Failure, T>> repositoryCall(P? params);

  void updateData(UpdateData<T> event, Emitter<BaseAsyncValueState<T>> emit) {
    emit(state.copyWith(value: event.value));
  }
}
