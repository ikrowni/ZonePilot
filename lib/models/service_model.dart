class Service {
  final String name;
  final String imagePath;
  final String androidPackageName;
  bool isEnabled;

  Service({
    required this.name,
    required this.imagePath,
    required this.androidPackageName,
    this.isEnabled = false,
  });
}
