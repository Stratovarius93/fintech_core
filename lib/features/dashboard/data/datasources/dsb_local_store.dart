import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/dsb_summary_model.dart';

class DsbLocalStore {
  // Singleton pattern implementation
  DsbLocalStore._internal();
  
  static DsbLocalStore _instance = DsbLocalStore._internal();
  static DsbLocalStore get instance => _instance;

  @visibleForTesting
  static set instance(DsbLocalStore value) => _instance = value;

  final String _boxName = 'dsb_dashboard';
  final String _key = 'summary_cache';

  /// Saves the [DsbSummaryModel] to the local Hive box
  Future<void> saveSummary(DsbSummaryModel model) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, model.toJson());
  }

  /// Retrieves the cached [DsbSummaryModel] if available, otherwise returns null
  Future<DsbSummaryModel?> getSummary() async {
    try {
      final box = await Hive.openBox(_boxName);
      final data = box.get(_key);
      if (data != null) {
        return DsbSummaryModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // If there's an error reading cache, we return null
      return null;
    }
    return null;
  }
}
