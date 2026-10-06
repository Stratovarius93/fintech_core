import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_async_value/base_async_value_bloc.dart';
import '../bloc/ath_auth_bloc.dart';
import '../../domain/entities/ath_user_entity.dart';
import '../../../../features/dashboard/presentation/pages/dsb_dashboard_page.dart';
import '../../../../core/utils/permission_util.dart';

class AthLoginPage extends StatefulWidget {
  const AthLoginPage({super.key});

  @override
  State<AthLoginPage> createState() => _AthLoginPageState();
}

class _AthLoginPageState extends State<AthLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await PermissionUtil.instance.requestPushPermissionWithWarning(context);
              
              if (context.mounted) {
                context.read<AthAuthBloc>().login(
                      _emailController.text,
                      _passwordController.text,
                    );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AthAuthBloc, BaseAsyncValueState<AthUserEntity>>(
        listener: (context, state) {
          state.status.whenProvided(
            error: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            success: () {
              if (state.value != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Welcome ${state.value!.email}')),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const DsbDashboardPage(),
                  ),
                );
              }
            },
          );
        },
        builder: (context, state) {
          return state.status.mapProvided(
            loading: () => const Center(child: CircularProgressIndicator()),
            initial: () => _buildForm(context),
            success: () => _buildForm(context),
            error: () => _buildForm(context),
            reloading: () => _buildForm(context), // Keep the form visible if it's just a reload
          );
        },
      ),
    );
  }
}
