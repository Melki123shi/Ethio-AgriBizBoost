class ForcastingInputEntity {
  final List<String> region;
  final List<String> zone;
  final List<String> woreda;
  final List<String> marketname;
  final List<String> cropname;
  final List<String> varietyname;
  final List<String> season;

  ForcastingInputEntity({
    required this.region,
    required this.zone,
    required this.woreda,
    required this.marketname,
    required this.cropname,
    required this.varietyname,
    required this.season,
  });

  static ForcastingInputEntity fromUserInput({
    required List<String> region,
    required List<String> zone,
    required List<String> woreda,
    required List<String> marketname,
    required List<String> cropname,
    required List<String> varietyname,
    required List<String> season,
  }) {
    return ForcastingInputEntity(
      region: region,
      zone: zone,
      woreda: woreda,
      marketname: marketname,
      cropname: cropname,
      varietyname: varietyname,
      season: season,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'marketname': marketname,
      'cropname': cropname,
      'varietyname': varietyname,
      'season': season,
    };
  }
}
