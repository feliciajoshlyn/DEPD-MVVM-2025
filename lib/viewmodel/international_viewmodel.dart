import 'dart:async'; // For Debounce (Timer)
import 'package:flutter/material.dart';

// Models
import 'package:depd_mvvm_2025/model/model.dart'; // Contains Province, City, InternationalDestination, InternationalCosts

// Responses
import 'package:depd_mvvm_2025/data/response/api_response.dart';
import 'package:depd_mvvm_2025/data/response/status.dart';

// Repositories
import 'package:depd_mvvm_2025/repository/home_repository.dart';
import 'package:depd_mvvm_2025/repository/international_repository.dart';

class InternationalViewModel with ChangeNotifier {
  // 1. We need HomeRepository for Origin (Indonesia)
  final _homeRepo = HomeRepository();
  // 2. We need InternationalRepository for Destination & Cost
  final _intlRepo = InternationalRepository();

  // ==========================
  // SECTION 1: ORIGIN (INDONESIA)
  // ==========================

  // State: List Provinsi
  ApiResponse<List<Province>> provinceList = ApiResponse.notStarted();

  void setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  Future<void> getProvinceList() async {
    if (provinceList.status == Status.completed) return;
    setProvinceList(ApiResponse.loading());
    _homeRepo.fetchProvinceList().then((value) {
      setProvinceList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setProvinceList(ApiResponse.error(error.toString()));
    });
  }

  // Cache & State: List Kota Asal
  final Map<int, List<City>> _cityCache = {};
  ApiResponse<List<City>> cityOriginList = ApiResponse.notStarted();

  void setCityOriginList(ApiResponse<List<City>> response) {
    cityOriginList = response;
    notifyListeners();
  }

  Future<void> getCityOriginList(int provId) async {
    // Check Cache first
    if (_cityCache.containsKey(provId)) {
      setCityOriginList(ApiResponse.completed(_cityCache[provId]!));
      return;
    }

    setCityOriginList(ApiResponse.loading());
    _homeRepo.fetchCityList(provId).then((value) {
      _cityCache[provId] = value; // Save to cache
      setCityOriginList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setCityOriginList(ApiResponse.error(error.toString()));
    });
  }

  // ==========================
  // SECTION 2: DESTINATION (INTERNATIONAL)
  // ==========================

  // State: List Negara Tujuan
  ApiResponse<List<Country>> destinationList = ApiResponse.notStarted();
  Timer? _debounce;

  void setDestinationList(ApiResponse<List<Country>> response) {
    destinationList = response;
    notifyListeners();
  }

  // Direct Search Logic
  void onSearchCountry(String query) {
    // If query is too short, clear list or do nothing
    if (query.length < 3) { 
       // Optional: You can choose to not search if less than 3 chars to save API calls
       // setDestinationList(ApiResponse.completed([]));
       // return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Wait 500ms after typing stops
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _getDestinations(query);
    });
  }

  Future<void> _getDestinations(String query) async {
    setDestinationList(ApiResponse.loading());
    
    _intlRepo.fetchInternationalDestinations(query: query).then((value) {
      setDestinationList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setDestinationList(ApiResponse.error(error.toString()));
    });
  }

  // ==========================
  // SECTION 3: COST CALCULATION
  // ==========================

  ApiResponse<List<InternationalCosts>> costList = ApiResponse.notStarted();
  bool isLoading = false;

  void setCostList(ApiResponse<List<InternationalCosts>> response) {
    costList = response;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> checkInternationalShippingCost({
    required int originCityId,
    required int destinationCountryId,
    required int weight,
    required String courier, // usually 'pos' or 'tiki'
  }) async {
    setLoading(true);
    setCostList(ApiResponse.loading());

    _intlRepo.checkInternationalCosts(
      originCityId: originCityId,
      destinationCountryId: destinationCountryId,
      weight: weight,
      courier: courier,
    ).then((value) {
      setCostList(ApiResponse.completed(value));
      setLoading(false);
    }).onError((error, stackTrace) {
      setCostList(ApiResponse.error(error.toString()));
      setLoading(false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}