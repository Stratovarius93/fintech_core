import 'package:fintech_core/core/data_async_value/params/base_async_value_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BaseDataParams toMap should return null', () {
    const baseDataParams = BaseAsyncValueParams();
    var result = baseDataParams.toMap();
    expect(result, isNull);
  });
}
