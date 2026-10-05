import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/data_async_value/params/base_async_value_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseDataEvent', () {
    test('CallAction event should have correct props', () {
      const params = BaseAsyncValueParams();
      const callAction = CallAction(params: params);

      expect(callAction.params, params);
    });

    test('CallAction event should accept null params', () {
      const callAction = CallAction<BaseAsyncValueParams>();

      expect(callAction.props, []);
    });

    test('RestoreData event should have empty props', () {
      const restoreData = RestoreData();

      expect(restoreData.props, isEmpty);
    });

    test('RestoreData should be equal to another instance of RestoreData', () {
      const restoreData1 = RestoreData();
      const restoreData2 = RestoreData();

      expect(restoreData1, restoreData2);
    });
  });
}
