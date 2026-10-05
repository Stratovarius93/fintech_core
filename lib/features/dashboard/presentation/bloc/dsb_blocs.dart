import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:fintech_core/features/dashboard/domain/repositories/interfaces/dsb_i_repository.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_bloc.dart';

List<SingleChildWidget> dsbBlocs() {
  return [
    BlocProvider<DsbSummaryBloc>(
      create: (context) => DsbSummaryBloc(
        repository: context.read<DsbIRepository>(),
      ),
    ),
  ];
}
