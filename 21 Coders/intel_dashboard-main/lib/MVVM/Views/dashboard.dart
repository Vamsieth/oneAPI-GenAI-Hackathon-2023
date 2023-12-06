import 'package:flutter/material.dart';
import 'package:intel_dashboard/MVVM/bloc/dashboard_bloc.dart';
import 'package:intel_dashboard/provider/data_provider.dart';
import 'package:intel_dashboard/repo/data_repo.dart';

class DashBoardView extends StatefulWidget {
  const DashBoardView({Key? key}) : super(key: key);

  @override
  _DashBoardViewState createState() => _DashBoardViewState();
}

class _DashBoardViewState extends State<DashBoardView> {
  final DashboardBloc _dashboardBloc = DashboardBloc(
      repository: DashboardRepository(dataProvider: DashboardDataProvider()));

  @override
  void initState() {
    super.initState();
    _dashboardBloc.getDashboardData();
    print("hello this is my boy");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: const AssetImage("assets/5144449.jpg"),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Dashboard',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(width: 50.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 20.0),
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dashboardBloc.dashboardStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> dashboardData = snapshot.data!;
            return ListView(
              scrollDirection: Axis.vertical,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.3, // Adjust the width as needed
                              height: MediaQuery.of(context).size.height *
                                  0.9, // Adjust the height as needed
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.0),
                                image: DecorationImage(
                                  image:
                                      AssetImage("assets/11235631_10848.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    20.0), // Add spacing between image and table
                            // DataTable Section
                            SingleChildScrollView(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.0),
                                  color: Colors.grey[200],
                                ),
                                child: DataTable(
                                  columns: [
                                    DataColumn(
                                      label: Container(
                                        color: Colors.transparent,
                                        child: Text('ID'),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        color: Colors.transparent,
                                        child: Text('Name'),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        color: Colors.transparent,
                                        child: Text('Order Id'),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        color: Colors.transparent,
                                        child: Text('Called At'),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        color: Colors.transparent,
                                        child: Text('Issue'),
                                      ),
                                    ),
                                  ],
                                  rows: dashboardData.map((data) {
                                    return DataRow(
                                      color: MaterialStateColor.resolveWith(
                                          (states) => Colors.white),
                                      cells: [
                                        DataCell(
                                            Text(data['id'].toString() ?? "")),
                                        DataCell(Text(data['name'] ?? "")),
                                        DataCell(Text(data['order_id'] ?? "")),
                                        DataCell(Text(data['createdAt'] ?? "")),
                                        DataCell(Text(data['issue'] ?? "")),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _dashboardBloc.dispose();
    super.dispose();
  }
}
