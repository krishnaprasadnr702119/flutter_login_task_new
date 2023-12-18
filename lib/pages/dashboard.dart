import 'package:flutter/material.dart';
import 'package:newlogin/pages/coverpage.dart';
import 'api_helper.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? protectedData = '';
  ApiHelper apiHelper = ApiHelper();

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
    // Fetch protected data with the current token
    final result = await ApiHelper.getProtectedData(context);

    if (result != null) {
      setState(() {
        protectedData = result;
      });
      print(protectedData);
    } else {
      // If the initial token fails or expired, try refreshing it
      final refreshedToken = await ApiHelper.refreshToken();
      if (refreshedToken != null) {
        // Retry fetching data with the new token
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
