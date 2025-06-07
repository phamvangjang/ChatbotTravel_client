import 'dart:math';

import 'package:mobilev2/models/tourist_attraction_model.dart';

class TouristAttractionService {
  // Danh sách các địa điểm du lịch nổi tiếng ở TP.HCM
  List<TouristAttraction> getHcmcAttractions() {
    return [
      TouristAttraction(
        id: 'ben-thanh-market',
        name: 'Chợ Bến Thành',
        vietnameseName: 'Chợ Bến Thành',
        englishName: 'Ben Thanh Market',
        description:
            'Chợ Bến Thành là một trong những biểu tượng của TP.HCM, nơi du khách có thể mua sắm đồ lưu niệm, thưởng thức ẩm thực địa phương và trải nghiệm văn hóa mua sắm Việt Nam.',
        address: 'Lê Lợi, Phường Bến Thành, Quận 1, TP.HCM',
        latitude: 10.772500,
        longitude: 106.698189,
        imageUrl:
            'https://en.wikipedia.org/wiki/B%E1%BA%BFn_Th%C3%A0nh_Market#/media/File:Ben_Thanh,_Ciudad_Ho_Chi_Minh,_Vietnam,_2013-08-14,_DD_01.JPG',
        keywords: [
          'chợ bến thành',
          'ben thanh market',
          'mua sắm',
          'shopping',
          'quận 1',
          'district 1',
          'ẩm thực',
          'food',
        ],
        rating: 4.3,
        category: 'shopping',
        additionalInfo: {
          'openingHours': '6:00 - 22:00',
          'bestTimeToVisit': 'Sáng sớm hoặc chiều tối',
          'entranceFee': 'Miễn phí',
        },
      ),
      TouristAttraction(
        id: 'notre-dame-cathedral',
        name: 'Nhà thờ Đức Bà',
        vietnameseName: 'Nhà thờ Đức Bà',
        englishName: 'Notre-Dame Cathedral Basilica of Saigon',
        description:
            'Nhà thờ Đức Bà là một công trình kiến trúc Gothic nổi tiếng được xây dựng trong thời kỳ Pháp thuộc. Đây là một trong những địa điểm tham quan không thể bỏ qua khi đến TP.HCM.',
        address: 'Công xã Paris, Bến Nghé, Quận 1, TP.HCM',
        latitude: 10.779986,
        longitude: 106.699091,
        imageUrl:
            'https://en.wikipedia.org/wiki/Notre-Dame_Cathedral_Basilica_of_Saigon#/media/File:Bas%C3%ADlica_de_Nuestra_Se%C3%B1ora,_Ciudad_Ho_Chi_Minh,_Vietnam,_2013-08-14,_DD_03.JPG',
        keywords: [
          'nhà thờ đức bà',
          'notre dame',
          'cathedral',
          'quận 1',
          'district 1',
          'kiến trúc pháp',
          'french architecture',
        ],
        rating: 4.5,
        category: 'historical',
        additionalInfo: {
          'openingHours': '8:00 - 17:00',
          'bestTimeToVisit': 'Sáng sớm để tránh đông người',
          'entranceFee': 'Miễn phí',
          'note': 'Đang trong quá trình trùng tu, có thể không vào bên trong',
        },
      ),
      TouristAttraction(
        id: 'independence-palace',
        name: 'Dinh Độc Lập',
        vietnameseName: 'Dinh Độc Lập',
        englishName: 'Independence Palace',
        description:
            'Dinh Độc Lập, còn được gọi là Dinh Thống Nhất, là một công trình kiến trúc lịch sử quan trọng, từng là nơi làm việc của Tổng thống Việt Nam Cộng hòa trước năm 1975.',
        address: '135 Nam Kỳ Khởi Nghĩa, Phường Bến Thành, Quận 1, TP.HCM',
        latitude: 10.777163,
        longitude: 106.695478,
        imageUrl:
            'https://en.wikipedia.org/wiki/Independence_Palace#/media/File:20190923_Independence_Palace-10.jpg',
        keywords: [
          'dinh độc lập',
          'dinh thống nhất',
          'independence palace',
          'reunification palace',
          'quận 1',
          'district 1',
          'lịch sử',
          'history',
        ],
        rating: 4.4,
        category: 'historical',
        additionalInfo: {
          'openingHours': '7:30 - 11:00, 13:00 - 16:00',
          'bestTimeToVisit': 'Sáng sớm',
          'entranceFee': '40.000 VND',
        },
      ),
      TouristAttraction(
        id: 'central-post-office',
        name: 'Bưu điện Trung tâm',
        vietnameseName: 'Bưu điện Trung tâm Sài Gòn',
        englishName: 'Saigon Central Post Office',
        description:
            'Bưu điện Trung tâm Sài Gòn là một công trình kiến trúc Gothic được thiết kế bởi kiến trúc sư Gustave Eiffel, vẫn hoạt động như một bưu điện và là điểm tham quan du lịch nổi tiếng.',
        address: '2 Công xã Paris, Bến Nghé, Quận 1, TP.HCM',
        latitude: 10.780109,
        longitude: 106.699993,
        imageUrl:
            'https://en.wikipedia.org/wiki/Saigon_Central_Post_Office#/media/File:Saigon_Central_Post_Office_(52681461470).jpg',
        keywords: [
          'bưu điện trung tâm',
          'central post office',
          'gustave eiffel',
          'quận 1',
          'district 1',
          'kiến trúc pháp',
          'french architecture',
        ],
        rating: 4.4,
        category: 'historical',
        additionalInfo: {
          'openingHours': '7:00 - 19:00',
          'bestTimeToVisit': 'Sáng sớm hoặc chiều muộn',
          'entranceFee': 'Miễn phí',
        },
      ),
      TouristAttraction(
        id: 'nguyen-hue-walking-street',
        name: 'Phố đi bộ Nguyễn Huệ',
        vietnameseName: 'Phố đi bộ Nguyễn Huệ',
        englishName: 'Nguyen Hue Walking Street',
        description:
            'Phố đi bộ Nguyễn Huệ là một trong những không gian công cộng sôi động nhất TP.HCM, nơi diễn ra nhiều hoạt động văn hóa, nghệ thuật và là điểm hẹn lý tưởng cho người dân và du khách.',
        address: 'Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
        latitude: 10.774301,
        longitude: 106.703896,
        imageUrl:
            'https://en.wikipedia.org/wiki/Nguy%E1%BB%85n_Hu%E1%BB%87_Boulevard#/media/File:Nguyen_Hue_Street_2020.jpg',
        keywords: [
          'phố đi bộ nguyễn huệ',
          'nguyen hue walking street',
          'quận 1',
          'district 1',
          'không gian công cộng',
          'public space',
        ],
        rating: 4.5,
        category: 'entertainment',
        additionalInfo: {
          'openingHours': '24/7, hoạt động sôi động nhất vào buổi tối',
          'bestTimeToVisit': 'Tối và cuối tuần',
          'entranceFee': 'Miễn phí',
        },
      ),
      TouristAttraction(
        id: 'bitexco-financial-tower',
        name: 'Tòa tháp Bitexco',
        vietnameseName: 'Tòa tháp Tài chính Bitexco',
        englishName: 'Bitexco Financial Tower',
        description:
            'Tòa tháp Bitexco là một trong những tòa nhà cao nhất Việt Nam, với thiết kế độc đáo lấy cảm hứng từ hoa sen. Đài quan sát Skydeck trên tầng 49 cung cấp tầm nhìn toàn cảnh TP.HCM.',
        address: '2 Hải Triều, Bến Nghé, Quận 1, TP.HCM',
        latitude: 10.771881,
        longitude: 106.704479,
        imageUrl:
            'https://en.wikipedia.org/wiki/Bitexco_Financial_Tower#/media/File:DJI_0550-HDR-Pano_Bitexco_Financial_Tower.jpg',
        keywords: [
          'bitexco',
          'skydeck',
          'tòa tháp',
          'tower',
          'quận 1',
          'district 1',
          'đài quan sát',
          'observation deck',
        ],
        rating: 4.3,
        category: 'modern',
        additionalInfo: {
          'openingHours': '9:30 - 21:30',
          'bestTimeToVisit': 'Hoàng hôn để ngắm thành phố lên đèn',
          'entranceFee': '200.000 VND',
        },
      ),
      TouristAttraction(
        id: 'landmark-81',
        name: 'Landmark 81',
        vietnameseName: 'Landmark 81',
        englishName: 'Landmark 81',
        description:
            'Landmark 81 là tòa nhà cao nhất Việt Nam và một trong những tòa nhà cao nhất thế giới. Tòa nhà bao gồm trung tâm thương mại, khách sạn, căn hộ và đài quan sát trên tầng cao nhất.',
        address: '720A Điện Biên Phủ, Phường 22, Quận Bình Thạnh, TP.HCM',
        latitude: 10.795021,
        longitude: 106.721684,
        imageUrl:
            'https://en.wikipedia.org/wiki/Landmark_81#/media/File:Ho_Chi_Minh_City_panorama_2019_(cropped).jpg',
        keywords: [
          'landmark 81',
          'tòa nhà cao nhất',
          'tallest building',
          'quận bình thạnh',
          'binh thanh district',
          'đài quan sát',
          'observation deck',
        ],
        rating: 4.6,
        category: 'modern',
        additionalInfo: {
          'openingHours': '9:30 - 21:30 (Đài quan sát)',
          'bestTimeToVisit': 'Hoàng hôn hoặc buổi tối',
          'entranceFee': '500.000 VND (Đài quan sát)',
        },
      ),
      TouristAttraction(
        id: 'war-remnants-museum',
        name: 'Bảo tàng Chứng tích Chiến tranh',
        vietnameseName: 'Bảo tàng Chứng tích Chiến tranh',
        englishName: 'War Remnants Museum',
        description:
            'Bảo tàng Chứng tích Chiến tranh trưng bày các hiện vật, hình ảnh và tài liệu về chiến tranh Việt Nam, là điểm đến quan trọng để hiểu về lịch sử đất nước.',
        address: '28 Võ Văn Tần, Phường 6, Quận 3, TP.HCM',
        latitude: 10.779868,
        longitude: 106.692628,
        imageUrl:
            'https://en.wikipedia.org/wiki/War_Remnants_Museum#/media/File:War_Remnants_Museum,_HCMC,_front.JPG',
        keywords: [
          'bảo tàng chứng tích chiến tranh',
          'war remnants museum',
          'quận 3',
          'district 3',
          'lịch sử',
          'history',
          'chiến tranh',
          'war',
        ],
        rating: 4.5,
        category: 'museum',
        additionalInfo: {
          'openingHours': '7:30 - 12:00, 13:30 - 17:00',
          'bestTimeToVisit': 'Sáng sớm để tránh đông',
          'entranceFee': '40.000 VND',
        },
      ),
      TouristAttraction(
        id: 'jade-emperor-pagoda',
        name: 'Chùa Ngọc Hoàng',
        vietnameseName: 'Chùa Ngọc Hoàng',
        englishName: 'Jade Emperor Pagoda',
        description:
            'Chùa Ngọc Hoàng là một ngôi chùa Đạo giáo cổ, được xây dựng vào đầu thế kỷ 20, nổi tiếng với kiến trúc độc đáo và các tượng thần linh tinh xảo.',
        address: '73 Mai Thị Lựu, Đa Kao, Quận 1, TP.HCM',
        latitude: 10.789486,
        longitude: 106.699953,
        imageUrl:
            'https://en.wikipedia.org/wiki/Jade_Emperor_Pagoda#/media/File:Jade_Emperor_Pagoda_Saigon.jpg',
        keywords: [
          'chùa ngọc hoàng',
          'jade emperor pagoda',
          'tortoise pagoda',
          'quận 1',
          'district 1',
          'đạo giáo',
          'taoism',
        ],
        rating: 4.3,
        category: 'religious',
        additionalInfo: {
          'openingHours': '8:00 - 17:00',
          'bestTimeToVisit': 'Sáng sớm',
          'entranceFee': 'Miễn phí (Tiền công đức tùy tâm)',
        },
      ),
      TouristAttraction(
        id: 'cu-chi-tunnels',
        name: 'Địa đạo Củ Chi',
        vietnameseName: 'Địa đạo Củ Chi',
        englishName: 'Cu Chi Tunnels',
        description:
            'Địa đạo Củ Chi là hệ thống đường hầm dài hơn 250km được sử dụng trong chiến tranh Việt Nam. Du khách có thể tham quan một phần của hệ thống này và tìm hiểu về cuộc sống của người dân và quân đội trong thời chiến.',
        address: 'Phú Hiệp, Huyện Củ Chi, TP.HCM',
        latitude: 11.142778,
        longitude: 106.464167,
        imageUrl:
            'https://en.wikipedia.org/wiki/C%E1%BB%A7_Chi_tunnels#/media/File:VietnamCuChiTunnels.jpg',
        keywords: [
          'địa đạo củ chi',
          'cu chi tunnels',
          'huyện củ chi',
          'cu chi district',
          'lịch sử',
          'history',
          'chiến tranh',
          'war',
        ],
        rating: 4.6,
        category: 'historical',
        additionalInfo: {
          'openingHours': '7:00 - 17:00',
          'bestTimeToVisit': 'Sáng sớm để tránh nóng',
          'entranceFee': '110.000 VND',
          'distance': 'Khoảng 70km từ trung tâm TP.HCM',
        },
      ),
      TouristAttraction(
        id: 'saigon-opera-house',
        name: 'Nhà hát Thành phố',
        vietnameseName: 'Nhà hát Thành phố',
        englishName: 'Saigon Opera House',
        description:
            'Nhà hát Thành phố là một công trình kiến trúc Pháp tuyệt đẹp, được xây dựng vào năm 1897. Hiện nay, nhà hát vẫn tổ chức các buổi biểu diễn nghệ thuật chất lượng cao.',
        address: '7 Công trường Lam Sơn, Bến Nghé, Quận 1, TP.HCM',
        latitude: 10.776944,
        longitude: 106.703056,
        imageUrl:
            'https://en.wikipedia.org/wiki/Ho_Chi_Minh_City_Opera_House#/media/File:Saigon_Opera_House_2014.jpg',
        keywords: [
          'nhà hát thành phố',
          'saigon opera house',
          'quận 1',
          'district 1',
          'kiến trúc pháp',
          'french architecture',
          'biểu diễn',
          'performance',
        ],
        rating: 4.5,
        category: 'cultural',
        additionalInfo: {
          'openingHours': 'Tùy theo lịch biểu diễn',
          'bestTimeToVisit': 'Kiểm tra lịch biểu diễn trước',
          'entranceFee': 'Tùy theo chương trình',
        },
      ),
      TouristAttraction(
        id: 'saigon-skydeck',
        name: 'Saigon Skydeck',
        vietnameseName: 'Đài quan sát Saigon Skydeck',
        englishName: 'Saigon Skydeck',
        description:
            'Saigon Skydeck nằm trên tầng 49 của tòa tháp Bitexco, cung cấp tầm nhìn 360 độ của thành phố Hồ Chí Minh. Đây là nơi lý tưởng để ngắm toàn cảnh thành phố từ trên cao.',
        address: 'Tầng 49, Tòa tháp Bitexco, 2 Hải Triều, Quận 1, TP.HCM',
        latitude: 10.771881,
        longitude: 106.704479,
        imageUrl:
            'https://en.wikipedia.org/wiki/Bitexco_Financial_Tower#/media/File:DJI_0550-HDR-Pano_Bitexco_Financial_Tower.jpg',
        keywords: [
          'saigon skydeck',
          'đài quan sát',
          'observation deck',
          'bitexco',
          'quận 1',
          'district 1',
          'tầm nhìn',
          'view',
        ],
        rating: 4.2,
        category: 'modern',
        additionalInfo: {
          'openingHours': '9:30 - 21:30',
          'bestTimeToVisit': 'Hoàng hôn để ngắm thành phố lên đèn',
          'entranceFee': '200.000 VND',
        },
      ),
    ];
  }

  // Tìm kiếm địa điểm theo từ khóa
  List<TouristAttraction> searchAttractions(String keyword) {
    final attractions = getHcmcAttractions();
    if (keyword.isEmpty) {
      return attractions;
    }

    return attractions
        .where((attraction) => attraction.matchesKeyword(keyword))
        .toList();
  }

  // Lấy địa điểm theo ID
  TouristAttraction? getAttractionById(String id) {
    final attractions = getHcmcAttractions();
    try {
      return attractions.firstWhere((attraction) => attraction.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy các địa điểm theo danh mục
  List<TouristAttraction> getAttractionsByCategory(String category) {
    final attractions = getHcmcAttractions();
    return attractions
        .where(
          (attraction) =>
              attraction.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // Lấy các địa điểm gần vị trí hiện tại (giả lập)
  List<TouristAttraction> getNearbyAttractions(
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    final attractions = getHcmcAttractions();
    return attractions.where((attraction) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        attraction.latitude,
        attraction.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  // Tính khoảng cách giữa hai điểm (công thức Haversine)
  double _calculateDistance(
    double latitude,
    double longitude,
    double latitude2,
    double longitude2,
  ) {
    const R = 6371.0; // Bán kính trái đất tính bằng km
    final dLat = _toRadians(latitude2 - latitude);
    final dLon = _toRadians(longitude2 - longitude);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(latitude) * cos(latitude2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(param0) {
    return param0 * (3.141592653589793 / 180);
  }
}
