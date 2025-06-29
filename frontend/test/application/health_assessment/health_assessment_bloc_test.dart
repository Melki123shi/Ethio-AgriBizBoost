import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'health_assessment_mock.mocks.dart'; 
import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_event.dart';
import 'package:app/application/health_assessment/health_assessment_state.dart';
import 'package:app/domain/entity/assessment_input_entity.dart';
import 'package:app/domain/entity/assessment_result_entity.dart';

void main() {
  late MockHealthAssessmentService mockService;
  late HealthAssessmentBloc bloc;

  setUp(() {
    mockService = MockHealthAssessmentService();
    bloc = HealthAssessmentBloc(mockService);
  });

  tearDown(() {
    bloc.close();
  });

  group('HealthAssessmentBloc Tests', () {
    const testCropType = 'Maize';
    const testSubsidy = 100.0;
    const testPrice = 500.0;
    const testCost = 300.0;
    const testQuantity = 5.0;

    final testInput = AssessmentInputEntity(
      cropType: testCropType,
      governmentSubsidy: testSubsidy,
      salePricePerQuintal: testPrice,
      totalCost: testCost,
      quantitySold: testQuantity,
    );

    final testResult = AssessmentResultEntity(
      totalIncome: 2500.0,
      profit: 1000.0,
      financialStability: 85.0,
      cashFlow: 600.0,
      totalExpense: 1500.0,
    );

    test('initial state is HealthAssessmentInitial', () {
      expect(bloc.state, isA<HealthAssessmentInitial>());
    });

    blocTest<HealthAssessmentBloc, HealthAssessmentState>(
      'emits [HealthAssessmentInputUpdated] when UpdateInputFieldEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(UpdateInputFieldEvent(
        testCropType,
        testSubsidy,
        testPrice,
        testCost,
        testQuantity,
      )),
      expect: () => [
        isA<HealthAssessmentInputUpdated>()
      ],
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<HealthAssessmentInputUpdated>());
        if (state is HealthAssessmentInputUpdated) {
          expect(state.inputFields.cropType, testCropType);
          expect(state.inputFields.governmentSubsidy, testSubsidy);
        }
      },
    );

    blocTest<HealthAssessmentBloc, HealthAssessmentState>(
      'emits [Loading, Success] when SubmitHealthAssessmentEvent succeeds',
      build: () {
        when(mockService.calculateHealthAssessment(any)).thenAnswer(
          (_) async => {
            'totalIncome': testResult.totalIncome,
            'profit': testResult.profit,
            'financialStability': testResult.financialStability,
            'cashFlow': testResult.cashFlow,
            'totalExpense': testResult.totalExpense,
          },
        );
        return bloc;
      },
      act: (bloc) => bloc.add(SubmitHealthAssessmentEvent(
        cropType: testCropType,
        governmentSubsidy: testSubsidy,
        salePricePerQuintal: testPrice,
        totalCost: testCost,
        quantitySold: testQuantity,
      )),
      expect: () => [
        isA<HealthAssessmentLoading>(),
        predicate<HealthAssessmentSuccess>((state) {
          return state.assessmentResult.totalIncome == testResult.totalIncome &&
                 state.assessmentResult.profit == testResult.profit &&
                 state.assessmentResult.cashFlow == testResult.cashFlow;
        }),
      ],
    );

    blocTest<HealthAssessmentBloc, HealthAssessmentState>(
      'emits [Loading, Failure] when SubmitHealthAssessmentEvent fails',
      build: () {
        when(mockService.calculateHealthAssessment(any))
            .thenThrow(Exception('API error'));
        return bloc;
      },
      act: (bloc) => bloc.add(SubmitHealthAssessmentEvent(
        cropType: testCropType,
        governmentSubsidy: testSubsidy,
        salePricePerQuintal: testPrice,
        totalCost: testCost,
        quantitySold: testQuantity,
      )),
      expect: () => [
        isA<HealthAssessmentLoading>(),
        isA<HealthAssessmentFailure>(),
      ],
    );
  });
}
