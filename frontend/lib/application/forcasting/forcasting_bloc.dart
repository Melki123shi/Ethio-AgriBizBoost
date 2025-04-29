import 'package:app/application/forcasting/forcasting_event.dart';
import 'package:app/application/forcasting/forcasting_state.dart';
import 'package:app/domain/dto/forcasting_input_dto.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/domain/entity/forcasting_input_entity.dart';
import 'package:app/services/api/forcasting_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForcastingBloc
  extends Bloc<ForcastingEvent, ForcastingState> {
  final ForcastingService _forcastingService;
  ForcastingInputEntity _forcastingInputEntity = ForcastingInputEntity(
    region: [], 
    zone: [], 
    woreda: [], 
    marketname: [], 
    cropname: [], 
    varietyname: [], 
    season: [],
  );

  ForcastingBloc(this._forcastingService)
      : super(ForcastingInitial()) {
    on<UpdateInputFieldEvent>(_onUpdateInputField);
    on<SubmitForcastingEvent>(_onSubmitForcasting);
  }
  void _onUpdateInputField(
      UpdateInputFieldEvent event, Emitter<ForcastingState> emit) {
    _forcastingInputEntity = ForcastingInputEntity(
    region: event.region, 
    zone: event.zone, 
    woreda: event.woreda, 
    marketname: event.marketname, 
    cropname: event.cropname, 
    varietyname: event.varietyname, 
    season: event.season,
    );

    emit(ForcastingInputUpdated(_forcastingInputEntity));
  }

  Future<void> _onSubmitForcasting(
    SubmitForcastingEvent event,
    Emitter<ForcastingState> emit,
) async {
  emit(ForcastingLoading());

  try {
    final entity = ForcastingInputEntity.fromUserInput(
      region: event.region,
      zone: event.zone,
      woreda: event.woreda,
      marketname: event.marketname,
      cropname: event.cropname,
      varietyname: event.varietyname,
      season: event.season,
    );

    final dto = ForcastingInputDTO.fromEntity(entity);
    final result = await _forcastingService.calculateForcasting(dto);

    if (result['success'] != true || result['data'] == null) {
      throw Exception('API returned failure');
    }

    final rawData = result['data'];
    if (rawData is! Map<String, dynamic>) {
      throw Exception("Unexpected data format from API");
    }

    final forcastingResult = ForcastingResultEntity(
      predictedDemand: rawData['Predicted Demand'] ?? '',
      predictedMinPrice: (rawData['Predicted Min Price'] as num?)?.toDouble() ?? 0.0,
      predictedMaxPrice: (rawData['Predicted Max Price'] as num?)?.toDouble() ?? 0.0,
    );
    emit(ForcastingSuccess(forcastingResult));
  } catch (e) {
    emit(ForcastingFailure());
  }
}
}
