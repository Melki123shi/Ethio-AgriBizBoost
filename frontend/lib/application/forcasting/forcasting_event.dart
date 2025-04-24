class ForcastingEvent {}

class UpdateInputFieldEvent extends ForcastingEvent {
  final List<String> region;
  final List<String> zone;
  final List<String> woreda;
  final List<String> marketname;
  final List<String> cropname;
  final List<String> varietyname;
  final List<String> season;

  UpdateInputFieldEvent(this.region, this.zone, this.woreda, this.marketname,
      this.cropname, this.varietyname, this.season);

  List<Object> get props =>
      [region, zone, woreda, marketname, cropname, varietyname, season];
}

class SubmitForcastingEvent extends ForcastingEvent {
  final List<String> region;
  final List<String> zone;
  final List<String> woreda;
  final List<String> marketname;
  final List<String> cropname;
  final List<String> varietyname;
  final List<String> season;

  SubmitForcastingEvent({
    required this.region,
    required this.zone,
    required this.woreda,
    required this.marketname,
    required this.cropname,
    required this.varietyname,
    required this.season,
  });

   List<Object> get props =>
      [region, zone, woreda, marketname, cropname, varietyname, season];
}
