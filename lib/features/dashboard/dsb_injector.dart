import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_core/core/network/dio_client.dart';
import 'package:fintech_core/features/dashboard/data/datasources/dsb_network_data_source.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/dsb_repository.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';

List<RepositoryProvider<dynamic>> dsbInjector(DioClient dioClient) {
  return [
    RepositoryProvider<DsbIRepository>(
      create: (context) => DsbRepository(
        dataSource: DsbNetworkDataSource(client: dioClient),
      ),
    ),
  ];
}
