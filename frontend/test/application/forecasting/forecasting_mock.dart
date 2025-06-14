import 'package:mocktail/mocktail.dart';
import 'package:frontend/application/forecasting/forecasting_bloc.dart';
import 'package:frontend/infrastructure/forecasting/forecasting_service.dart';

class MockForecastingService extends Mock implements ForecastingService {}
