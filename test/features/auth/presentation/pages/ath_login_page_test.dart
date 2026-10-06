import 'package:bloc_test/bloc_test.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/features/auth/domain/entities/ath_user_entity.dart';
import 'package:fintech_core/features/auth/presentation/bloc/ath_auth_bloc.dart';
import 'package:fintech_core/features/auth/presentation/pages/ath_login_page.dart';
import 'package:fintech_core/features/dashboard/presentation/pages/dsb_dashboard_page.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAthAuthBloc
    extends MockBloc<BaseAsyncValueEvent, BaseAsyncValueState<AthUserEntity>>
    implements AthAuthBloc {}

class MockDsbSummaryBloc
    extends MockBloc<BaseAsyncValueEvent, BaseAsyncValueState<DsbSummaryEntity>>
    implements DsbSummaryBloc {}

void main() {
  late MockAthAuthBloc mockAuthBloc;

  late MockDsbSummaryBloc mockSummaryBloc;

  setUp(() {
    mockAuthBloc = MockAthAuthBloc();
    mockSummaryBloc = MockDsbSummaryBloc();
  });

  Widget buildWidget() {
    return BlocProvider<DsbSummaryBloc>.value(
      value: mockSummaryBloc,
      child: MaterialApp(
        home: BlocProvider<AthAuthBloc>.value(
          value: mockAuthBloc,
          child: const AthLoginPage(),
        ),
      ),
    );
  }

  testWidgets('shows form initially', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(
        const BaseAsyncValueState<AthUserEntity>(
            status: ScreenStatusType.initial));

    await tester.pumpWidget(buildWidget());

    expect(find.byKey(const Key('ath_email_field')), findsOneWidget);
    expect(find.byKey(const Key('ath_password_field')), findsOneWidget);
    expect(find.byKey(const Key('ath_login_button')), findsOneWidget);
  });

  testWidgets('shows loading indicator when status is loading', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(
        const BaseAsyncValueState<AthUserEntity>(
            status: ScreenStatusType.loading));

    await tester.pumpWidget(buildWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error SnackBar when status is error', (tester) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([
        const BaseAsyncValueState<AthUserEntity>(
          status: ScreenStatusType.error,
          failure: GeneralFailure('Invalid credentials'),
        ),
      ]),
      initialState: const BaseAsyncValueState<AthUserEntity>(
          status: ScreenStatusType.initial),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('navigates to dashboard on success', (tester) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([
        const BaseAsyncValueState<AthUserEntity>(
          status: ScreenStatusType.success,
          value: AthUserEntity(
              id: '1',
              email: 'test@test.com',
              segment: 'young',
              token: 'tok'),
        ),
      ]),
      initialState: const BaseAsyncValueState<AthUserEntity>(
          status: ScreenStatusType.initial),
    );
    
    when(() => mockSummaryBloc.state).thenReturn(
        const BaseAsyncValueState<DsbSummaryEntity>(
            status: ScreenStatusType.initial));

    await tester.pumpWidget(buildWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DsbDashboardPage), findsOneWidget);
  });
}
