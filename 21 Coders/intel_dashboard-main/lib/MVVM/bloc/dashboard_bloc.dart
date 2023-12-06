// dashboard_bloc.dart

import 'dart:async';
import 'package:intel_dashboard/repo/data_repo.dart';

class DashboardBloc {
  final DashboardRepository repository;

  DashboardBloc({required this.repository});

  final _dashboardController = StreamController<List<Map<String, dynamic>>>();

  Stream<List<Map<String, dynamic>>> get dashboardStream =>
      _dashboardController.stream;

  void getDashboardData() async {
    print("the process is started");
    try {
      final data = await repository.getDashboardData();
      print("the data is $data");
      _dashboardController.sink.add(data);
    } catch (e) {
      print("there was an error processing the data $e");
      _dashboardController.addError(e.toString());
    }
  }

  void dispose() {
    _dashboardController.close();
  }
}
