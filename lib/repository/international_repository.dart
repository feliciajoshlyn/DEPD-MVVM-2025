import 'package:depd_mvvm_2025/data/network/network_api_service.dart';
import 'package:depd_mvvm_2025/model/model.dart';

// Repository untuk menangani logika bisnis terkait data ongkir internasional
class InternationalRepository {
  // NetworkApiServices hanya perlu 1 instance sehingga tidak perlu ganti service selama aplikasi berjalan
  final _apiServices = NetworkApiServices();

  // Mengambil daftar opsi pengiriman internasional dari API
  Future<List<Country>> fetchInternationalDestinations({
    String query = '',
  }) async {
    try {
      String endpoint = 'destination/international-destination';
      if (query.isNotEmpty) {
        endpoint += '?search=$query';
      }

      final response = await _apiServices.getApiResponse(endpoint);

      final meta = response['meta'];
      if (meta == null || meta['code'] != 200) {
        throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
      }

      final data = response['data'];
      if (data is! List) return [];

      return data.map((e) => Country.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch international destinations: $e");
    }
  }

  Future<List<InternationalCosts>> checkInternationalCosts({
    required int originCityId,      
    required int destinationCountryId, 
    required int weight,            
    required String courier,        
  }) async {
    try {
      final body = {
        "origin": originCityId.toString(),
        "destination": destinationCountryId.toString(),
        "weight": weight.toString(),
        "courier": courier,
      };

      final response = await _apiServices.postApiResponse(
        'calculate/international-cost', 
        body,
      );

      final meta = response['meta'];
      if (meta != null) {
        final int code = meta['code'] ?? 0;
        
        if (code != 200) {
          throw Exception("API Error: ${meta['message'] ?? 'Unknown error'}");
        }
      }

      final data = response['data'];
      
      if (data is! List) return [];

      return data.map((e) => InternationalCosts.fromJson(e)).toList();

    } catch (e) {
      rethrow;
    }
  }
}
