import 'package:fintech_core/core/network/dio_client.dart';
import 'package:fintech_core/core/network/network_handler.dart';
import 'package:fintech_core/features/dashboard/data/models/dsb_summary_model.dart';
import 'package:fintech_core/features/dashboard/data/datasources/interfaces/dsb_i_network_data_source.dart';

class DsbNetworkDataSource
    with NetworkHandler
    implements DsbINetworkDataSource {
  DsbNetworkDataSource({required this.client});

  final DioClient client;

  @override
  Future<DsbSummaryModel> getSummary() async {
    return handleRequest<DsbSummaryModel>(
      request: () => client.instance.get('/api/v1/dashboard/summary'),
      mapper: (data) => DsbSummaryModel.fromJson(data['data']),
      requestName: 'DSB_SUMMARY',
    );
  }
}
