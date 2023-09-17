// lib/onetime_login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_malinlink/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OnetimeLoginPage extends StatefulWidget {
  @override
  _OnetimeLoginPageState createState() => _OnetimeLoginPageState();
}

class _OnetimeLoginPageState extends State<OnetimeLoginPage> {
  final String apiUrl = usersapiUrl;

  TextEditingController userIdController = TextEditingController();
  String oneTimeLoginCode = "";
  String url = "";

  Future<void> generateOneTimeLoginCode() async {
    final String user_id = userIdController.text;
    final String apiKey = adminapiKey; // Replace with your API key

    try {
      final response = await http.post(
        Uri.parse('$apiUrl$user_id/one-time-login-code'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final code = data['data']['one_time_login_code'];
        final link = data['data']['url'];
        setState(() {
          oneTimeLoginCode = code;
          url = link;
        });
      } else {
        // Handle errors, e.g., show an error message
        setState(() {
          oneTimeLoginCode = "Error";
          url = "";
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        oneTimeLoginCode = "Error";
        url = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('One-Time Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: generateOneTimeLoginCode,
              child: Text('Generate One-Time Login Code'),
            ),
            SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'One-Time Login Code:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      oneTimeLoginCode,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'URL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Open the URL in a web browser
                        // You can use a package like url_launcher to achieve this
                        // Example: https://pub.dev/packages/url_launcher
                      },
                      child: Text(
                        url,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
