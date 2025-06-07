class TouristAttraction {
  final String id;
  final String name;
  final String vietnameseName;
  final String englishName;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final List<String> keywords;
  final double rating;
  final String category;
  final Map<String, dynamic> additionalInfo;

  TouristAttraction({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.englishName,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.keywords,
    this.rating = 0.0,
    required this.category,
    this.additionalInfo = const {},
  });

  // Kiểm tra xem địa điểm có khớp với từ khóa tìm kiếm không
  bool matchesKeyword(String keyword) {
    final lowerKeyword = keyword.toLowerCase();

    // Kiểm tra tên và từ khóa
    if (name.toLowerCase().contains(lowerKeyword) ||
        vietnameseName.toLowerCase().contains(lowerKeyword) ||
        englishName.toLowerCase().contains(lowerKeyword)) {
      return true;
    }

    // Kiểm tra từ khóa liên quan
    for (final word in keywords) {
      if (word.toLowerCase().contains(lowerKeyword)) {
        return true;
      }
    }

    return false;
  }

  // Tạo bản sao với các thuộc tính mới
  TouristAttraction copyWith({
    String? id,
    String? name,
    String? vietnameseName,
    String? englishName,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? keywords,
    double? rating,
    String? category,
    Map<String, dynamic>? additionalInfo,
  }) {
    return TouristAttraction(
      id: id ?? this.id,
      name: name ?? this.name,
      vietnameseName: vietnameseName ?? this.vietnameseName,
      englishName: englishName ?? this.englishName,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      keywords: keywords ?? this.keywords,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
