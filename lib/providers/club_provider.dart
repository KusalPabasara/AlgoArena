import 'package:flutter/foundation.dart';
import '../data/models/club.dart';
import '../data/models/district.dart';
import '../data/repositories/club_repository.dart';

class ClubProvider with ChangeNotifier {
  final ClubRepository _clubRepository = ClubRepository();
  
  List<Club> _clubs = [];
  List<District> _districts = [];
  bool _isLoading = false;
  String? _error;

  List<Club> get clubs => _clubs;
  List<District> get districts => _districts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all clubs
  Future<void> loadClubs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clubs = await _clubRepository.getAllClubs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all districts
  Future<void> loadDistricts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _districts = await _clubRepository.getAllDistricts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load both clubs and districts
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _clubRepository.getAllClubs(),
        _clubRepository.getAllDistricts(),
      ]);
      
      _clubs = results[0] as List<Club>;
      _districts = results[1] as List<District>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get club by ID
  Future<Club?> getClubById(String clubId) async {
    try {
      return await _clubRepository.getClubById(clubId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // Get district by ID
  Future<District?> getDistrictById(String districtId) async {
    try {
      return await _clubRepository.getDistrictById(districtId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
