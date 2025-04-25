import 'package:app/domain/entity/forcasting_input_entity.dart';

class ForcastingInputDTO {
  final List<String> region;
  final List<String> zone;
  final List<String> woreda;
  final List<String> marketname;
  final List<String> cropname;
  final List<String> varietyname;
  final List<String> season;

  ForcastingInputDTO({
    required this.region,
    required this.zone,
    required this.woreda,
    required this.marketname,
    required this.cropname,
    required this.varietyname,
    required this.season,
  });

  factory ForcastingInputDTO.fromJson(Map<String, dynamic> json) {
    return ForcastingInputDTO(
      region: _toStringList(json['region']),
      zone: _toStringList(json['zone']),
      woreda: _toStringList(json['woreda']),
      marketname: _toStringList(json['marketname']),
      cropname: _toStringList(json['cropname']),
      varietyname: _toStringList(json['varietyname']),
      season: _toStringList(json['season']),
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

  static ForcastingInputDTO fromEntity(ForcastingInputEntity entity) {
    return ForcastingInputDTO(
      region: entity.region,
      zone: entity.zone,
      woreda: entity.woreda,
      marketname: entity.marketname,
      cropname: entity.cropname,
      varietyname: entity.varietyname,
      season: entity.season,
    );
  }

  ForcastingInputEntity toEntity() {
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

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is String) {
      return [value];
    }
    return [];
  }
}
