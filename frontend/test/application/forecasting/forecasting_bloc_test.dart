import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

// Import your Bloc, events, states, and entities
import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/forcasting/forcasting_event.dart';
import 'package:app/application/forcasting/forcasting_state.dart';
import 'package:app/domain/entity/forcasting_input_entity.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';

import 'forcasting_service_test.mocks.mocks.dart';


void main() {
  late MockForcastingService mockService;
  late ForcastingBloc forcastingBloc;

  setUp(() {
    mockService = MockForcastingService();
    forcastingBloc = ForcastingBloc(mockService);
  });

  tearDown(() {
    forcastingBloc.close();
  });

  group('ForcastingBloc Tests', () {
    final testInput = ForcastingInputEntity(
      region: ['Region1'],
      zone: ['Zone1'],
      woreda: ['Woreda1'],
      marketname: ['Market1'],
      cropname: ['Crop1'],
      varietyname: ['Variety1'],
      season: ['Season1'],
    );

    final testResult = ForcastingResultEntity(
      predictedDemand: '1000',
      predictedMinPrice: 10.5,
      predictedMaxPrice: 15.0,
    );

    test('initial state is ForcastingInitial', () {
      expect(forcastingBloc.state, isA<ForcastingInitial>());
    });

    blocTest<ForcastingBloc, ForcastingState>(
      'emits [ForcastingInputUpdated] when UpdateInputFieldEvent is added',
      build: () => forcastingBloc,
      act: (bloc) => bloc.add(UpdateInputFieldEvent(
        testInput.region,
        testInput.zone,
        testInput.woreda,
        testInput.marketname,
        testInput.cropname,
        testInput.varietyname,
        testInput.season,
      )),
      expect: () => [isA<ForcastingInputUpdated>()],
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<ForcastingInputUpdated>());
        if (state is ForcastingInputUpdated) {
          expect(state.inputFields.region, testInput.region);
          expect(state.inputFields.zone, testInput.zone);
          // You can add more checks here if needed
        }
      },
    );

    blocTest<ForcastingBloc, ForcastingState>(
      'emits [ForcastingLoading, ForcastingSuccess] when SubmitForcastingEvent succeeds',
      build: () {
        when(mockService.calculateForcasting(any)).thenAnswer((_) async => {
          'success': true,
          'data': {
            'Predicted Demand': testResult.predictedDemand,
            'Predicted Min Price': testResult.predictedMinPrice,
            'Predicted Max Price': testResult.predictedMaxPrice,
          }
        });
        return forcastingBloc;
      },
      act: (bloc) => bloc.add(SubmitForcastingEvent(
        region: testInput.region,
        zone: testInput.zone,
        woreda: testInput.woreda,
        marketname: testInput.marketname,
        cropname: testInput.cropname,
        varietyname: testInput.varietyname,
        season: testInput.season,
      )),
      expect: () => [
        isA<ForcastingLoading>(),
        predicate<ForcastingSuccess>((state) {
          return state.forcastingResult.predictedDemand == testResult.predictedDemand &&
                 state.forcastingResult.predictedMinPrice == testResult.predictedMinPrice &&
                 state.forcastingResult.predictedMaxPrice == testResult.predictedMaxPrice;
        }),
      ],
    );

    blocTest<ForcastingBloc, ForcastingState>(
      'emits [ForcastingLoading, ForcastingFailure] when SubmitForcastingEvent fails',
      build: () {
        when(mockService.calculateForcasting(any))
            .thenThrow(Exception('API error'));
        return forcastingBloc;
      },
      act: (bloc) => bloc.add(SubmitForcastingEvent(
        region: testInput.region,
        zone: testInput.zone,
        woreda: testInput.woreda,
        marketname: testInput.marketname,
        cropname: testInput.cropname,
        varietyname: testInput.varietyname,
        season: testInput.season,
      )),
      expect: () => [
        isA<ForcastingLoading>(),
        isA<ForcastingFailure>(),
      ],
    );
  });
}
