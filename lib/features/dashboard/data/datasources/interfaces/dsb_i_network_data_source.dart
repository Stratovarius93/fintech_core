import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';

abstract class DsbINetworkDataSource {
  Future<DsbSummaryModel> getSummary();
}
