import 'package:equatable/equatable.dart';

abstract class RecentAssessmentEvent extends Equatable {
  const RecentAssessmentEvent();

  @override
  List<Object> get props => [];
}

class FetchRecentAverages extends RecentAssessmentEvent {}