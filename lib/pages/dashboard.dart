import 'package:flutter/material.dart';
import 'package:newlogin/pages/coverpage.dart';
import 'api_helper.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? protectedData = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue[200],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              protectedData != null && protectedData!.isNotEmpty
                  ? Text(
                      protectedData!,
                      style: TextStyle(fontSize: 16.0),
                    )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => fetchData(context),
                child: Text('Fetch Protected Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchData(BuildContext context) async {
    final result = await ApiHelper.getProtectedData(context);
    if (result != null) {
      setState(() {
        protectedData = result;
      });
      print(protectedData);
    } else {
      setState(() {
        protectedData = 'Failed to fetch data.';
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoverPage()),
        );
      });
    }
  }
}
