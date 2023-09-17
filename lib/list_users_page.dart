import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'user_details_page.dart'; // Import the user details page
import 'config.dart';

class ListUsersPage extends StatefulWidget {
  @override
  _ListUsersPageState createState() => _ListUsersPageState();
}

class _ListUsersPageState extends State<ListUsersPage> {
  final String apiUrl = usersapiUrl;
  final String apiKey = adminapiKey;

  List<dynamic>? usersData;
  int currentPage = 1; // Track the current page

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Internet Connection"),
            content:
                Text("Please check your internet connection and try again."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      fetchUsers();
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?page=$currentPage'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (!mounted) {
        // Check if the widget is still mounted before updating the state
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['data'];

        if (users.isNotEmpty) {
          // If there are users on this page, add them to the list
          setState(() {
            if (usersData == null) {
              usersData = [];
            }
            usersData!.addAll(users);
          });

          // Move to the next page and fetch more users
          currentPage++;
          fetchUsers();
        }
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      if (!mounted) {
        // Check if the widget is still mounted before showing the dialog
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "An error occurred while fetching data. Please try again later."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Callback function to trigger refresh
  void refreshUsers(bool deleted) {
    if (deleted) {
      // Reset the current page and re-fetch users
      currentPage = 1;
      usersData = null;
      fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Users'),
      ),
      body: usersData == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usersData!.length,
              itemBuilder: (context, index) {
                final user = usersData![index];
                final billing = user['billing'];

                return GestureDetector(
                  onTap: () async {
                    final deleted = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserDetailsPage(user, apiKey, refreshUsers),
                      ),
                    );
                    if (deleted != null && deleted) {
                      // User was deleted, trigger refresh
                      refreshUsers(true);
                    }
                  },
                  child: Card(
                    elevation: 4.0,
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        'Name: ${user['name']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${user['email']}'),
                          Text('User ID: ${user['id']}'),
                          Text('Plan ID: ${user['plan_id']}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
