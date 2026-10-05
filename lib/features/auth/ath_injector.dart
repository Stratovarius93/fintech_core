import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/dio_client.dart';
import 'data/datasources/ath_network_data_source.dart';
import 'domain/repositories/ath_repository.dart';
import 'domain/repositories/interfaces/ath_i_repository.dart';

List<RepositoryProvider<dynamic>> athInjector(
  DioClient dioClient,
) =>
    [
      RepositoryProvider<AthIRepository>.value(
        value: AthRepository(
          AthNetworkDataSource(dioClient),
        ),
      ),
    ];
