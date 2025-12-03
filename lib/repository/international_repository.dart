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
      // Construct the URL with the search parameter
      // Note: You might need to handle URL encoding for spaces
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
    required int originCityId,      // 'origin' from request
    required int destinationCountryId, // 'destination' from request
    required int weight,            // 'weight' from request
    required String courier,        // 'courier' from request
  }) async {
    try {
      // 1. Prepare the Body
      final body = {
        "origin": originCityId.toString(),
        "destination": destinationCountryId.toString(),
        "weight": weight.toString(),
        "courier": courier,
      };

      // 2. POST Request
      final response = await _apiServices.postApiResponse(
        'calculate/international-cost', 
        body,
      );

      // 3. Parse 'meta' (Validation)
      final meta = response['meta'];
      if (meta != null) {
        // According to your structure, 'code' holds the success status (usually 200)
        final int code = meta['code'] ?? 0;
        
        if (code != 200) {
          throw Exception("API Error: ${meta['message'] ?? 'Unknown error'}");
        }
      }

      // 4. Parse 'data' (The List)
      final data = response['data'];
      
      // If data is null or not a list, return empty
      if (data is! List) return [];

      // 5. Map to Model
      return data.map((e) => InternationalCosts.fromJson(e)).toList();

    } catch (e) {
      rethrow;
    }
  }
}
