
import 'package:intel_dashboard/provider/data_provider.dart';

class DashboardRepository {
  final DashboardDataProvider dataProvider;

  DashboardRepository({required this.dataProvider});

  Future<List<Map<String, dynamic>>> getDashboardData() async {
    return await dataProvider.fetchDashboardData();
  }
}
