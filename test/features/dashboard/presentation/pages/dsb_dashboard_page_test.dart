import 'package:bloc_test/bloc_test.dart';
import 'package:fintech_core/core/data_async_value/base_async_value_bloc.dart';
import 'package:fintech_core/core/errors/failures.dart';
import 'package:fintech_core/features/dashboard/domain/entities/dsb_summary_entity.dart';
import 'package:fintech_core/features/dashboard/presentation/bloc/dsb_summary_bloc.dart';
import 'package:fintech_core/features/dashboard/presentation/pages/dsb_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDsbSummaryBloc extends MockBloc<BaseAsyncValueEvent,
    BaseAsyncValueState<DsbSummaryEntity>> implements DsbSummaryBloc {}

void main() {
  late MockDsbSummaryBloc mockSummaryBloc;

  setUp(() {
    mockSummaryBloc = MockDsbSummaryBloc();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<DsbSummaryBloc>.value(
        value: mockSummaryBloc,
        child: const DsbDashboardPage(),
      ),
    );
  }

  testWidgets('shows loading indicator when status is loading', (tester) async {
    when(() => mockSummaryBloc.state).thenReturn(
        const BaseAsyncValueState<DsbSummaryEntity>(
            status: ScreenStatusType.loading));

    await tester.pumpWidget(buildWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows accounts when status is success', (tester) async {
    when(() => mockSummaryBloc.state).thenReturn(
      BaseAsyncValueState<DsbSummaryEntity>(
        status: ScreenStatusType.success,
        value: DsbSummaryEntity(
          accounts: [
            DsbAccountEntity(
              accountNumber: '123456',
              accountName: 'Checking',
              balance: 1000.0,
              isActive: true,
              createdAt: DateTime(2020),
              transactions: const [],
            ),
          ],
          dynamicBanner: null,
          isFromCache: false,
        ),
      ),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.text('Checking'), findsOneWidget);
    expect(find.text('\$1000.00'), findsOneWidget);
    expect(find.byKey(const Key('dsb_offline_banner')), findsNothing);
  });

  testWidgets('shows offline banner when data is from cache', (tester) async {
    when(() => mockSummaryBloc.state).thenReturn(
      BaseAsyncValueState<DsbSummaryEntity>(
        status: ScreenStatusType.success,
        value: DsbSummaryEntity(
          accounts: [
            DsbAccountEntity(
              accountNumber: '123456',
              accountName: 'Checking',
              balance: 1000.0,
              isActive: true,
              createdAt: DateTime(2020),
              transactions: const [],
            ),
          ],
          dynamicBanner: null,
          isFromCache: true,
        ),
      ),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.text('Checking'), findsOneWidget);
    expect(find.byKey(const Key('dsb_offline_banner')), findsOneWidget);
  });

  testWidgets('shows no internet view when NotInternetFailure occurs',
      (tester) async {
    when(() => mockSummaryBloc.state).thenReturn(
      const BaseAsyncValueState<DsbSummaryEntity>(
        status: ScreenStatusType.error,
        failure: NotInternetFailure('No internet'),
      ),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.byKey(const Key('dsb_no_internet_view')), findsOneWidget);
    expect(find.text('You are offline.'), findsOneWidget);
    expect(find.byKey(const Key('dsb_no_internet_retry_button')), findsOneWidget);
  });

  testWidgets('shows general error view when GeneralFailure occurs',
      (tester) async {
    when(() => mockSummaryBloc.state).thenReturn(
      const BaseAsyncValueState<DsbSummaryEntity>(
        status: ScreenStatusType.error,
        failure: GeneralFailure('Something went wrong'),
      ),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.text('Error: Something went wrong'), findsOneWidget);
    expect(find.byKey(const Key('dsb_error_retry_button')), findsOneWidget);
  });

  testWidgets('calls getSummary on retry from error view', (tester) async {
    when(() => mockSummaryBloc.state).thenReturn(
      const BaseAsyncValueState<DsbSummaryEntity>(
        status: ScreenStatusType.error,
        failure: GeneralFailure('Something went wrong'),
      ),
    );

    await tester.pumpWidget(buildWidget());

    await tester.tap(find.byKey(const Key('dsb_error_retry_button')));
    verify(() => mockSummaryBloc.getSummary()).called(2);
  });
}
