import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ListPlansPage extends StatefulWidget {
  @override
  _ListPlansPageState createState() => _ListPlansPageState();
}

class _ListPlansPageState extends State<ListPlansPage> {
  final String apiUrl = plansapiUrl;
  final String apiKey = adminapiKey;

  List<dynamic>? plansData;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          plansData = data['data'];
        });
      } else {
        // Handle errors, e.g., show an error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to fetch plans. Please try again."),
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "An error occurred while fetching plans. Please try again later."),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Plans'),
      ),
      body: plansData == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: plansData!.length,
              itemBuilder: (context, index) {
                final plan = plansData![index];
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Name: ${plan['name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${plan['description']}'),
                        Text('Monthly Price: \$${plan['monthly_price']}'),
                        Text('Annual Price: \$${plan['annual_price']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
