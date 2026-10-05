class JsonMap {
  JsonMap(this._map);

  final Map<String, dynamic> _map;

  /// Some endpoints wrap their payload under [wrapKey] (e.g. `{"items": [...]}`)
  /// but others reply with a bare list, or `null` for empty/204 responses.
  /// Use this to normalize any of those shapes into a plain `List<dynamic>`.
  static List<dynamic> extractListPayload(dynamic data, {String? wrapKey}) {
    if (data == null) return const [];
    if (data is List) return data;
    if (wrapKey != null && data is Map<String, dynamic>) {
      final value = data[wrapKey];
      if (value is List) return value;
    }
    return const [];
  }

  /// Normalizes a payload that may be `null`, a single object, or a list of
  /// objects (in which case the first element is used) into a single map.
  static Map<String, dynamic>? extractFirstJsonObject(dynamic data) {
    if (data == null) return null;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return null;
  }

  dynamic _getValue(dynamic keyOrKeys) {
    if (keyOrKeys is String) {
      return _map[keyOrKeys];
    } else if (keyOrKeys is List<dynamic>) {
      if (keyOrKeys.isNotEmpty && keyOrKeys[0] is List) {
        for (var keys in keyOrKeys) {
          final value = _getNestedValue(keys);
          if (value != null) {
            return value;
          }
        }
      } else {
        return _getNestedValue(keyOrKeys);
      }
    }
    return null;
  }

  dynamic _getNestedValue(List<dynamic> keys) {
    dynamic value = _map;
    for (var key in keys) {
      if (value is Map<String, dynamic> && key is String) {
        value = value[key];
      } else if (value is List && key is int) {
        if (key < value.length) {
          value = value[key];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return value;
  }

  int mapToInt(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    if (value == null) return 0;
    return value is int ? value : int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  int? mapToIntOrNull(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    return value is int ? value : int.tryParse(value?.toString() ?? '');
  }

  double mapToDouble(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    if (value == null) return 0.0;
    return value is double
        ? value
        : double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  double? mapToDoubleOrNull(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    return value is double ? value : double.tryParse(value?.toString() ?? '');
  }

  String mapToString(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    return value is String ? value : value?.toString() ?? '';
  }

  String? mapToStringOrNull(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    return value is String ? value : value?.toString();
  }

  bool mapToBool(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    if (value == null) return false;
    return value is bool
        ? value
        : bool.tryParse(value?.toString() ?? 'false') ?? false;
  }

  double mapToPrice(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    if (value == null) return 0.0;
    return value is double
        ? value
        : value is int
        ? 0.0 + value
        : double.tryParse(value?.toString() ?? '0.0') ?? 0.0;
  }

  bool mapIsExist(dynamic keyOrKeys) {
    return _getValue(keyOrKeys) != null;
  }

  String _normalizeDateTimeString(String input) {
    var value = input.trim();

    // Avoid touching date-only strings like '2026-05-14'.
    final looksLikeDateTime =
        value.contains('T') || (value.contains(':') && value.contains(' '));
    if (!looksLikeDateTime) return value;

    // Dart's DateTime.tryParse supports ISO-8601 offsets like -05:00 but not
    // RFC822 offsets like -0500. Normalize when needed.
    final hasIsoOffset = RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value);
    if (!hasIsoOffset) {
      value = value.replaceFirstMapped(
        RegExp(r'([+-]\d{2})(\d{2})$'),
        (m) => '${m.group(1)}:${m.group(2)}',
      );

      // Also support hour-only offsets like -05 or +02.
      value = value.replaceFirstMapped(
        RegExp(r'([+-]\d{2})$'),
        (m) => '${m.group(1)}:00',
      );
    }

    return value;
  }

  DateTime? mapToDateTimeOrNull(dynamic keyOrKeys) {
    final value = _getValue(keyOrKeys);
    if (value is String) {
      return DateTime.tryParse(_normalizeDateTimeString(value));
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  DateTime mapToDateTime(dynamic keyOrKeys) {
    final dateTime = mapToDateTimeOrNull(keyOrKeys);
    return dateTime ?? DateTime.now();
  }

  List<T> mapToList<T>(dynamic keyOrKeys, T Function(dynamic item) mapper) {
    final value = _getValue(keyOrKeys);
    if (value == null) return <T>[];

    final iterable = switch (value) {
      final Iterable<dynamic> v => v,
      _ => null,
    };

    if (iterable == null) return <T>[];

    final result = <T>[];
    for (final item in iterable) {
      if (item == null) continue;
      result.add(mapper(item));
    }
    return result;
  }
}
