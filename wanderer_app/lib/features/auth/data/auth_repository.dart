import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<bool> sendOtp(String phone) async {
    final response = await _api.post('/api/v1/auth/send-otp', data: {'phone': phone});
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final response = await _api.post('/api/v1/auth/verify-otp', data: {
      'phone': phone,
      'code': code,
    });
    return response.data as Map<String, dynamic>;
  }
}
