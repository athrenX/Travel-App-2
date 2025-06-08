class Location {
  final int id;
  final String name;
  final String alamat;      // properti alamat ditambahkan
  final double latitude;
  final double longitude;

  Location({
    required this.id,
    required this.name,
    required this.alamat,   // tambahkan di constructor
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      alamat: json['alamat'] ?? '', // default '' jika tidak ada di JSON
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }
}
