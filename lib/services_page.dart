import 'package:flutter/material.dart';
import 'package:flutter_malinlink/create_user.dart';
import 'package:flutter_malinlink/list_plan.dart';
import 'package:flutter_malinlink/list_users_page.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          ServiceCard(
            title: 'Create User',
            subtext: 'Create a new user',
            icon: Icons.person_add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateUserPage()),
              );
            },
          ),
          ServiceCard(
            title: 'List Users',
            subtext: 'View all users',
            icon: Icons.list,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListUsersPage()),
              );
            },
          ),
          ServiceCard(
            title: 'List Plans',
            subtext: 'View available plans',
            icon: Icons.assignment,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListPlansPage()),
              );
            },
          ),
          ServiceCard(
            title: 'Delete Users',
            subtext: 'Delete user data',
            icon: Icons.delete,
            onTap: () {
              // Implement delete user functionality or navigate to the Delete Users page.
            },
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtext;
  final IconData icon;
  final VoidCallback onTap;

  ServiceCard({
    required this.title,
    required this.subtext,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.blue,
            ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
