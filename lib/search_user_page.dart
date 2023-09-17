import 'package:flutter/material.dart';
import 'package:flutter_malinlink/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchUserPage extends StatefulWidget {
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController userIdController = TextEditingController();
  final String apiUrl = usersapiUrl;

  Map<String, dynamic>? userData;

  Future<void> searchUser() async {
    final String userId = userIdController.text;
    final String apiKey = adminapiKey;

    try {
      final response = await http.get(
        Uri.parse('$apiUrl$userId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          userData = data;
        });
      } else {
        // Handle errors, e.g., show an error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to fetch user data. Please try again."),
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
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  hintText: 'Enter user ID',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: searchUser,
                child: Text('Search'),
              ),
              SizedBox(height: 16.0),
              if (userData != null)
                Column(
                  children: userData!.entries.map((entry) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        subtitle: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
