import '../models/club.dart';
import '../models/district.dart';
import '../services/api_service.dart';

class ClubRepository {
  final ApiService _apiService = ApiService();
  
  // Get all clubs
  Future<List<Club>> getAllClubs() async {
    try {
      final response = await _apiService.get('/clubs', withAuth: true);
      
      final clubs = (response['clubs'] as List)
          .map((club) => Club.fromJson(club))
          .toList();
      
      return clubs;
    } catch (e) {
      throw Exception('Failed to load clubs: $e');
    }
  }
  
  // Get club by ID
  Future<Club> getClubById(String clubId) async {
    try {
      final response = await _apiService.get('/clubs/$clubId', withAuth: true);
      return Club.fromJson(response['club']);
    } catch (e) {
      throw Exception('Failed to load club: $e');
    }
  }
  
  // Get all districts
  Future<List<District>> getAllDistricts() async {
    try {
      final response = await _apiService.get('/districts', withAuth: true);
      
      final districts = (response['districts'] as List)
          .map((district) => District.fromJson(district))
          .toList();
      
      return districts;
    } catch (e) {
      throw Exception('Failed to load districts: $e');
    }
  }
  
  // Get district by ID
  Future<District> getDistrictById(String districtId) async {
    try {
      final response = await _apiService.get(
        '/districts/$districtId',
        withAuth: true,
      );
      return District.fromJson(response['district']);
    } catch (e) {
      throw Exception('Failed to load district: $e');
    }
  }
  
  // Get clubs by district
  Future<List<Club>> getClubsByDistrict(String districtId) async {
    try {
      final response = await _apiService.get(
        '/districts/$districtId/clubs',
        withAuth: true,
      );
      
      final clubs = (response['clubs'] as List)
          .map((club) => Club.fromJson(club))
          .toList();
      
      return clubs;
    } catch (e) {
      throw Exception('Failed to load clubs: $e');
    }
  }
}
