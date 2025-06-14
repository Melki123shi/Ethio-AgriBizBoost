import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/domain/forecasting/i_forecasting_service.dart';
import 'package:app/domain/forecasting/models.dart';

class MockForecastingService extends Mock implements IForecastingService {}

void main() {
  late ForecastingBloc bloc;
  late MockForecastingService mockService;

  setUp(() {
    mockService = MockForecastingService();
    bloc = ForecastingBloc(mockService);
  });

  group('ForecastingBloc Tests', () {
    const input = ForecastingInput(crop: 'Wheat', area: 20.0, region: 'Oromia');
    final result = ForecastingResult(demand: 100.0, price: 150.0);

    blocTest<ForecastingBloc, ForecastingState>(
      'emits [loading, loaded] when forecast succeeds',
      build: () {
        when(() => mockService.forecast(input))
            .thenAnswer((_) async => result);
        return bloc;
      },
      act: (bloc) => bloc.add(ForecastingSubmitted(input)),
      expect: () => [
        ForecastingState.loading(),
        ForecastingState.loaded(result),
      ],
    );

    blocTest<ForecastingBloc, ForecastingState>(
      'emits [loading, error] when forecast fails',
      build: () {
        when(() => mockService.forecast(input))
            .thenThrow(Exception('Failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(ForecastingSubmitted(input)),
      expect: () => [
        ForecastingState.loading(),
        isA<ForecastingState>().having((s) => s.errorMessage, 'error', contains('Failed')),
      ],
    );
  });
}
