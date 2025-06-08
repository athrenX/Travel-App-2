class Activity {
  final int id;
  final String title;
  final String? image; // properti image, bukan imageUrl

  Activity({required this.id, required this.title, this.image});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      image:
          json['image_url'], // misal dari API field-nya image_url tetap di-map ke property image
    );
  }
}
