import 'package:fintech_core/core/network/json_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonMap', () {
    final sampleMap = {
      'id': 123,
      'account_name': 'Cuenta de Ahorros',
      'balance': 45.67,
      'is_active': true,
      'has_overdraft': 'no overdraft',
      'created_at': '2026-05-14T10:30:00.000Z',
      'created_at_offset_iso': '2023-11-24T23:49:13-05:00',
      'created_at_offset_iso_ms': '2023-11-24T23:49:13.7-05:00',
      'created_at_offset_rfc822': '2023-11-24T23:49:13-0500',
      'created_at_offset_rfc822_ms': '2023-11-24T23:49:13.7-0500',
      'created_at_offset_hour_only': '2023-11-24T23:49:13-05',
      'created_date_only': '2026-05-14',
      'created_at_ms': 1715682600000,
      'created_at_invalid': 'not-a-date',
      'ints': [1, 2, 3],
      'mixed_ints': [1, '2', null, 3],
      'nested': {
        'nestedIntKey': 789,
        'nestedStringKey': 'world',
        'numbers': [10, 20],
      },
      'balance_with_error': 'not a balance',
      'balance_total': 10,
      'balance_with_interest': 99.99,
      'last_balance': null,
      'account_alias': {'EN': 'Savings Account', 'ES': 'Cuenta de Ahorros'},
      'branch': {
        'street': 'Wall St',
        'number': 123,
        'coordinates': [12.34, -56.78],
      },
    };

    final jsonMap = JsonMap(sampleMap);

    test('extractFirstJsonObject should return null for null payload', () {
      expect(JsonMap.extractFirstJsonObject(null), isNull);
    });

    test('extractFirstJsonObject should return a map payload', () {
      final payload = {'id': 123, 'account_name': 'Cuenta de Ahorros'};

      expect(JsonMap.extractFirstJsonObject(payload), payload);
    });

    test('extractFirstJsonObject should return the first map from a list', () {
      final firstObject = {'id': 123};

      expect(
        JsonMap.extractFirstJsonObject([
          firstObject,
          {'id': 456},
        ]),
        firstObject,
      );
    });

    test(
      'extractFirstJsonObject should return null for an empty or invalid list',
      () {
        expect(JsonMap.extractFirstJsonObject([]), isNull);
        expect(JsonMap.extractFirstJsonObject(['not an object']), isNull);
      },
    );

    test('mapToInt should return an integer', () {
      expect(jsonMap.mapToInt(['id']), 123);
    });

    test('mapToIntOrNull should return null if key does not exist', () {
      expect(jsonMap.mapToIntOrNull(['nonExistentKey']), null);
    });

    test('mapToDouble should return a double', () {
      expect(jsonMap.mapToDouble(['balance']), 45.67);
    });

    test('mapToDouble should return 0.0 if value is not a double', () {
      expect(jsonMap.mapToDouble(['balance_with_error']), 0.0);
    });

    test('mapToDoubleOrNull should return null if key does not exist', () {
      expect(jsonMap.mapToDoubleOrNull(['nonExistentKey']), null);
    });

    test('mapToString should return a string', () {
      expect(jsonMap.mapToString(['account_name']), 'Cuenta de Ahorros');
    });

    test('mapToStringOrNull should return null if key does not exist', () {
      expect(jsonMap.mapToStringOrNull(['nonExistentKey']), null);
    });

    test('mapToBool should return a boolean', () {
      expect(jsonMap.mapToBool(['is_active']), true);
    });

    test('mapToBool should return false if value is not a boolean', () {
      expect(jsonMap.mapToBool(['is_active_error']), false);
    });

    test('mapToBool should return false if value is not a boolean', () {
      expect(jsonMap.mapToBool(['has_overdraft']), false);
    });

    test('mapToPrice should return a price', () {
      expect(jsonMap.mapToPrice(['balance_with_interest']), 99.99);
    });

    test('mapToPrice should return 0.0 if value is not a double', () {
      expect(jsonMap.mapToPrice(['balance_with_error']), 0.0);
    });

    test('mapToPrice should return a price', () {
      expect(jsonMap.mapToPrice(['balance_total']), 10.0);
    });

    test('mapToPrice should return 0.0 if value is null', () {
      expect(jsonMap.mapToPrice(['last_balance']), 0.0);
    });

    test('mapIsExist should return true if key exists', () {
      expect(jsonMap.mapIsExist(['id']), true);
    });

    test('mapIsExist should return false if key does not exist', () {
      expect(jsonMap.mapIsExist(['nonExistentKey']), false);
    });

    test('mapToDateTimeOrNull should parse a DateTime from String', () {
      final result = jsonMap.mapToDateTimeOrNull(['created_at']);
      expect(result, DateTime.parse('2026-05-14T10:30:00.000Z'));
    });

    test('mapToDateTimeOrNull should parse ISO8601 with offset (-05:00)', () {
      final result = jsonMap.mapToDateTimeOrNull(['created_at_offset_iso']);
      expect(result, DateTime.parse('2023-11-24T23:49:13-05:00'));
    });

    test(
      'mapToDateTimeOrNull should parse ISO8601 with ms and offset (-05:00)',
      () {
        final result = jsonMap.mapToDateTimeOrNull([
          'created_at_offset_iso_ms',
        ]);
        expect(result, DateTime.parse('2023-11-24T23:49:13.7-05:00'));
      },
    );

    test('mapToDateTimeOrNull should parse RFC822 offset (-0500)', () {
      final result = jsonMap.mapToDateTimeOrNull(['created_at_offset_rfc822']);
      expect(result, DateTime.parse('2023-11-24T23:49:13-05:00'));
    });

    test('mapToDateTimeOrNull should parse RFC822 offset with ms (-0500)', () {
      final result = jsonMap.mapToDateTimeOrNull([
        'created_at_offset_rfc822_ms',
      ]);
      expect(result, DateTime.parse('2023-11-24T23:49:13.7-05:00'));
    });

    test('mapToDateTimeOrNull should parse hour-only offset (-05)', () {
      final result = jsonMap.mapToDateTimeOrNull([
        'created_at_offset_hour_only',
      ]);
      expect(result, DateTime.parse('2023-11-24T23:49:13-05:00'));
    });

    test('mapToDateTimeOrNull should not break date-only strings', () {
      final result = jsonMap.mapToDateTimeOrNull(['created_date_only']);
      expect(result, DateTime.parse('2026-05-14'));
    });

    test(
      'mapToDateTimeOrNull should parse a DateTime from int milliseconds',
      () {
        final result = jsonMap.mapToDateTimeOrNull(['created_at_ms']);
        expect(result, DateTime.fromMillisecondsSinceEpoch(1715682600000));
      },
    );

    test('mapToDateTimeOrNull should return null for invalid date strings', () {
      final result = jsonMap.mapToDateTimeOrNull(['created_at_invalid']);
      expect(result, null);
    });

    test('mapToDateTime should return parsed DateTime when value is valid', () {
      final result = jsonMap.mapToDateTime(['created_at']);
      expect(result, DateTime.parse('2026-05-14T10:30:00.000Z'));
    });

    test('mapToDateTime should fallback to now when key does not exist', () {
      final before = DateTime.now();
      final result = jsonMap.mapToDateTime(['nonExistentKey']);
      final after = DateTime.now();

      expect(result.isBefore(before), isFalse);
      expect(result.isAfter(after), isFalse);
    });

    test('mapToList should return empty list if key does not exist', () {
      final result = jsonMap.mapToList<int>([
        'nonExistentKey',
      ], (x) => x as int);
      expect(result, <int>[]);
    });

    test('mapToList should return empty list if value is not iterable', () {
      final result = jsonMap.mapToList<String>([
        'branch',
      ], (x) => x.toString());
      expect(result, <String>[]);
    });

    test('mapToList should map items from a list', () {
      final result = jsonMap.mapToList<int>(['ints'], (x) => x as int);
      expect(result, <int>[1, 2, 3]);
    });

    test('mapToList should ignore null items', () {
      final result = jsonMap.mapToList<int>([
        'mixed_ints',
      ], (x) => int.parse(x.toString()));
      expect(result, <int>[1, 2, 3]);
    });

    test('Test nested map access', () {
      expect(jsonMap.mapToInt(['nested', 'nestedIntKey']), 789);
      expect(jsonMap.mapToString(['nested', 'nestedStringKey']), 'world');
    });

    test('Test nested map access with non-existent key', () {
      expect(jsonMap.mapToIntOrNull(['nested', 'nonExistentKey']), null);
    });

    test('mapToList should support nested list access', () {
      final result = jsonMap.mapToList<int>([
        'nested',
        'numbers',
      ], (x) => x as int);
      expect(result, <int>[10, 20]);
    });

    test('Test nested map access with String and int keys', () {
      expect(jsonMap.mapToDouble(['branch', 'coordinates', 0]), 12.34);
      expect(jsonMap.mapToDouble(['branch', 'coordinates', 1]), -56.78);
    });

    test('Test nested map access with String key', () {
      expect(jsonMap.mapToString('account_name'), 'Cuenta de Ahorros');
    });
    test('Test nested map access', () {
      expect(
        jsonMap.mapToInt([
          ['nested', 'nestedIntKeyOther'],
          ['nested', 'nestedIntKey'],
        ]),
        789,
      );
    });
  });
}
