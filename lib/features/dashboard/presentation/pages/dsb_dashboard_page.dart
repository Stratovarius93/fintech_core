import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/core/sdui/sdui_parser.dart';
import 'package:fintech_core/core/utils/fraud_alert_simulator.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_bloc.dart';
import 'package:fintech_core/features/auth/presentation/pages/ath_login_page.dart';

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
            icon: const Icon(
              Icons.notification_important,
              color: Colors.redAccent,
            ),
            tooltip: 'Simulate Fraud Alert',
            onPressed: () => FraudAlertSimulator.instance.simulate(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Real-world scenario would clear Hive tokens and emit Logout event to Bloc
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AthLoginPage()),
              );
            },
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
              if (summary == null || summary.accounts.isEmpty) {
                return const SizedBox();
              }

              return Column(
                children: [
                  if (summary.dynamicBanner != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SduiParserWidget(node: summary.dynamicBanner!),
                    ),
                  Expanded(
                    child: PageView.builder(
                      itemCount: summary.accounts.length,
                      itemBuilder: (context, index) {
                        final account = summary.accounts[index];
                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          account.accountName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Icon(
                                          account.isActive
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: account.isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Balance',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                    Text(
                                      '\$${account.balance.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Acc: ${account.accountNumber}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        Text(
                                          'Since: ${account.createdAt.toLocal().toString().split(' ')[0]}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Recent Transactions:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(),
                            ...account.transactions.map((tx) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: tx.isCredit
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  child: Icon(
                                    tx.isCredit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: tx.isCredit
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  tx.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  tx.date.toLocal().toString().split(' ')[0],
                                ),
                                trailing: Text(
                                  '${tx.isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: tx.isCredit
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
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
                        onPressed: () =>
                            context.read<DsbSummaryBloc>().getSummary(),
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
                    Text(
                      'Error: ${state.failure.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<DsbSummaryBloc>().getSummary(),
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
