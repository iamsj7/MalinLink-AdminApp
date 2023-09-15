import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String apiKey;
  final Function(bool) refreshUsers;

  UserDetailsPage(this.userData, this.apiKey, this.refreshUsers);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final String apiUrl = usersapiUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteUser(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: [
              buildDetailRow('Name', widget.userData['name'] ?? 'N/A'),
              buildDetailRow('Email', widget.userData['email'] ?? 'N/A'),
              buildDetailRow('Phone', widget.userData['phone'] ?? 'N/A'),
              buildDetailRow('Country', widget.userData['country'] ?? 'N/A'),
              buildDetailRow('City', widget.userData['city_name'] ?? 'N/A'),
              buildDetailRow('Plan ID', widget.userData['plan_id'] ?? 'N/A'),
              buildDetailRow(
                'Plan Expiration Date',
                widget.userData['plan_expiration_date'] ?? 'N/A',
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Flexible(
            child: Text(
              value != null ? value.toString() : 'N/A',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context) async {
    final userId = widget.userData['id'].toString();
    final deleteUrl = '$apiUrl$userId';

    try {
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Authorization': 'Bearer ${widget.apiKey}',
        },
      );

      if (response.statusCode == 200) {
        widget.refreshUsers(true); // Trigger refresh of user list
        Navigator.pop(context, true); // Pop page with success signal
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to delete user."),
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
            content: Text("An error occurred while deleting the user."),
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
}
