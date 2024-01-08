import 'package:flutter/material.dart';
import 'package:newlogin/screens/coverpage.dart';
import 'package:newlogin/services/api_services.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? protectedData = '';
  late ApiHelper apiHelper; // Declare it here

  @override
  void initState() {
    super.initState();
    apiHelper = ApiHelper(context); // Initialize it in initState
  }

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
    final result =
        await ApiHelper.getProtectedData(context); // Using apiHelper here

    if (result != null) {
      setState(() {
        protectedData = result;
      });
      print(protectedData);
    } else {
      final refreshedToken = await ApiHelper.refreshToken(context);
      if (refreshedToken != null) {
        final newData = await ApiHelper.getProtectedData(context);
        if (newData != null) {
          setState(() {
            protectedData = newData;
          });
          print(protectedData);
        } else {
          protectedData = 'Failed to fetch data.';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CoverPage()),
          );
        }
      } else {
        protectedData = 'Failed to refresh token.';
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoverPage()),
        );
      }
    }
  }
}
