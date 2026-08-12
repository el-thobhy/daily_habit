import 'dart:convert';
import 'package:daily_habit/core/network/api_client.dart';

abstract class SyncRemoteDataSource {
  Future<Map<String, dynamic>> postSyncPayload(Map<String, dynamic> payload);
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  final ApiClient apiClient;

  SyncRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> postSyncPayload(Map<String, dynamic> payload) async {
    final response = await apiClient.post(
      'https://dailyhabit.el-thobhy.my.id/api/v1/sync',
      body: payload,
      withAuth: true,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Sync failed with status code ${response.statusCode}');
    }
  }
}
