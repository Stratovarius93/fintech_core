part of 'base_async_value_bloc.dart';

abstract class BaseAsyncValueEvent extends Equatable {
  const BaseAsyncValueEvent();
  @override
  List<Object?> get props => [];
}

class CallAction<P extends BaseAsyncValueParams> extends BaseAsyncValueEvent {
  const CallAction({this.params});
  final P? params;
}

class ReloadData<P extends BaseAsyncValueParams> extends BaseAsyncValueEvent {
  const ReloadData({this.params});
  final P? params;
}

class RestoreData extends BaseAsyncValueEvent {
  const RestoreData();
}

class UpdateData<T> extends BaseAsyncValueEvent {
  const UpdateData({this.value});
  final T? value;
}
