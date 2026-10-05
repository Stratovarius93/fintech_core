import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

import '../../domain/repositories/interfaces/ath_i_repository.dart';
import 'ath_auth_bloc.dart';

List<SingleChildWidget> athBlocs() => [
      BlocProvider(
        create: (context) => AthAuthBloc(
          repository: RepositoryProvider.of<AthIRepository>(context),
        ),
      ),
    ];
