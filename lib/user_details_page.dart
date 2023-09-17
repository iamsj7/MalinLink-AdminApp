import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

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

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController planIdController = TextEditingController();
  final TextEditingController planExpirationDateController =
      TextEditingController();
  final TextEditingController planTrialDoneController = TextEditingController();

  DateTime selectedPlanExpirationDate = DateTime.now();

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
              buildDetailRow('User ID', widget.userData['id'] ?? 'N/A'),
              buildDetailRow('Phone', widget.userData['phone'] ?? 'N/A'),
              buildDetailRow('Country', widget.userData['country'] ?? 'N/A'),
              buildDetailRow('City', widget.userData['city_name'] ?? 'N/A'),
              buildDetailRow('Plan ID', widget.userData['plan_id'] ?? 'N/A'),
              buildDetailRow(
                'Plan Expiration Date',
                widget.userData['plan_expiration_date'] ?? 'N/A',
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _showUpdateDialog(context);
                },
                child: Text('Update'),
              )
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

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update User'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Disabled')),
                    DropdownMenuItem(value: '1', child: Text('Active')),
                    DropdownMenuItem(value: '2', child: Text('Banned')),
                  ],
                  onChanged: (String? value) {
                    statusController.text = value ?? '';
                  },
                  value: statusController.text.isNotEmpty
                      ? statusController.text
                      : null,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Normal user')),
                    DropdownMenuItem(value: '1', child: Text('Admin')),
                  ],
                  onChanged: (String? value) {
                    typeController.text = value ?? '';
                  },
                  value: typeController.text.isNotEmpty
                      ? typeController.text
                      : null,
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                // Add dropdowns for plan_id and plan_trial_done here
                TextField(
                  controller: planIdController,
                  decoration: InputDecoration(labelText: 'Plan ID'),
                ),
                ListTile(
                  title: Text('Plan Expiration Date (Y-m-d H:i:s)'),
                  subtitle: Text(
                    '${selectedPlanExpirationDate.toLocal()}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: selectedPlanExpirationDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (newDate != null) {
                      final newTime = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(selectedPlanExpirationDate),
                      );
                      if (newTime != null) {
                        setState(() {
                          selectedPlanExpirationDate = DateTime(
                            newDate.year,
                            newDate.month,
                            newDate.day,
                            newTime.hour,
                            newTime.minute,
                          ).toUtc();
                          // Update the text field with the selected date
                          planExpirationDateController.text =
                              selectedPlanExpirationDate
                                  .toLocal()
                                  .toString()
                                  .substring(0, 19); // Format as Y-m-d H:i:s
                        });
                      }
                    }
                  },
                ),
                DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(value: '0', child: Text('No')),
                    DropdownMenuItem(value: '1', child: Text('Yes')),
                  ],
                  onChanged: (String? value) {
                    planTrialDoneController.text = value ?? '';
                  },
                  value: planTrialDoneController.text.isNotEmpty
                      ? planTrialDoneController.text
                      : null,
                  decoration: InputDecoration(labelText: 'Plan Trial Done'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                _updateUser(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUser(BuildContext context) async {
    final userId = widget.userData['id'].toString();
    final updateUrl = '$apiUrl/$userId';

    final request = http.MultipartRequest('POST', Uri.parse(updateUrl));
    request.headers['Authorization'] = 'Bearer ${widget.apiKey}';

    // Add the Content-Type header
    request.headers['Content-Type'] = 'multipart/form-data';

    // Add fields to the request if they have values
    if (passwordController.text.isNotEmpty) {
      request.fields['password'] = passwordController.text;
    }

    if (statusController.text.isNotEmpty) {
      request.fields['status'] = statusController.text;
    }

    if (typeController.text.isNotEmpty) {
      request.fields['type'] = typeController.text;
    }

    if (planIdController.text.isNotEmpty) {
      request.fields['plan_id'] = planIdController.text;
    }

    if (planExpirationDateController.text.isNotEmpty) {
      request.fields['plan_expiration_date'] =
          planExpirationDateController.text;
    }

    if (planTrialDoneController.text.isNotEmpty) {
      request.fields['plan_trial_done'] = planTrialDoneController.text;
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log the response body
      print('Response Body: ${response.body}');

      // Parse the JSON response
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('data') &&
          jsonResponse['data'].containsKey('id')) {
        final updatedUserId = jsonResponse['data']['id'];

        // Close the update dialog
        Navigator.of(context).pop();

        // Show a success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Successfully updated'),
              content:
                  Text('User updated successfully with ID: $updatedUserId.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the success dialog

                    // Navigate back to the list of users and refresh
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Unauthorized'),
              content: Text('You are not authorized to update this user.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle other errors, e.g., show a generic error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Failed to update user. Please try again.'),
                  Text('Curl Request:'),
                  Text('curl --request POST \\'),
                  Text('--url $updateUrl \\'),
                  Text(
                      '--header \'Authorization: Bearer ${widget.apiKey}\' \\'),
                  if (passwordController.text.isNotEmpty)
                    Text('--form \'password=${passwordController.text}\' \\'),
                  if (statusController.text.isNotEmpty)
                    Text('--form \'status=${statusController.text}\' \\'),
                  if (typeController.text.isNotEmpty)
                    Text('--form \'type=${typeController.text}\' \\'),
                  if (planIdController.text.isNotEmpty)
                    Text('--form \'plan_id=${planIdController.text}\' \\'),
                  if (planExpirationDateController.text.isNotEmpty)
                    Text(
                        '--form \'plan_expiration_date=${planExpirationDateController.text}\' \\'),
                  if (planTrialDoneController.text.isNotEmpty)
                    Text(
                        '--form \'plan_trial_done=${planTrialDoneController.text}\''),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
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
            title: Text('Error'),
            content: Text('An error occurred while updating the user.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
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
