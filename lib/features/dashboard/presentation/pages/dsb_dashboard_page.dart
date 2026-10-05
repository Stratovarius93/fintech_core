import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_bloc.dart';

class DsbDashboardPage extends StatefulWidget {
  const DsbDashboardPage({super.key});

  @override
  State<DsbDashboardPage> createState() => _DsbDashboardPageState();
}

class _DsbDashboardPageState extends State<DsbDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DsbSummaryBloc>().getSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: BlocBuilder<DsbSummaryBloc, BaseAsyncValueState<DsbSummaryEntity>>(
        builder: (context, state) {
          return state.status.mapProvided(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: () {
              final summary = state.value;
              if (summary == null) return const SizedBox();
              
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Account: ${summary.accountNumber}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Balance: \$${summary.totalBalance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  const Text('Recent Transactions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  ...summary.recentTransactions.map((tx) {
                    return ListTile(
                      title: Text(tx.description),
                      subtitle: Text(tx.date.toLocal().toString().split(' ')[0]),
                      trailing: Text(
                        '${tx.isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: tx.isCredit ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
            error: () => Center(child: Text('Error: ${state.failure.message}')),
          );
        },
      ),
    );
  }
}
