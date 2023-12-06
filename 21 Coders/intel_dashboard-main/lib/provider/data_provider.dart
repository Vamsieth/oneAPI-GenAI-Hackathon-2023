// data_provider.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardDataProvider {
  final String baseUrl = 'http://192.168.1.6:3000/get-all-data';

  Future<List<Map<String, dynamic>>> fetchDashboardData() async {
    final response = await http.get(Uri.parse('$baseUrl'));
    print("the process is started");
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print("the data is $jsonData");
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      print("there is an errror try to find out");
      throw Exception('Failed to load dashboard data');
    }
  }
}
