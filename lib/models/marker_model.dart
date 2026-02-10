class MarkerModel {
  final String name;
  final Duration time;

  MarkerModel({required this.name, required this.time});

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    return MarkerModel(
      name: json['name'],
      time: Duration(
        minutes: int.parse((json['time'] as String).split(':').first),
        seconds: int.parse((json['time'] as String).split(':').last),
      ),
    );
  }
}