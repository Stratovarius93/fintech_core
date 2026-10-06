import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/core/sdui/sdui_parser.dart';
import 'package:fintech_core/core/utils/fraud_alert_simulator.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_important, color: Colors.redAccent),
            tooltip: 'Simulate Fraud Alert',
            onPressed: () => FraudAlertSimulator.instance.simulate(context),
          ),
        ],
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
                  
                  if (summary.dynamicBanner != null) ...[
                    const SizedBox(height: 16),
                    SduiParserWidget(node: summary.dynamicBanner!),
                  ],

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
            error: () {
              if (state.failure is NotInternetFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'You are offline.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No cached data available to display.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<DsbSummaryBloc>().getSummary(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.failure.message}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<DsbSummaryBloc>().getSummary(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
