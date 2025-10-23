import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      authProvider.userData?['name'] ?? 'Пользователь',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      authProvider.userData?['email'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Редактировать профиль'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implement edit profile
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.history, color: Colors.green),
                    title: Text('История обучения'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implement learning history
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.orange),
                    title: Text('Настройки'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implement settings
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.info, color: Colors.purple),
                title: Text('О приложении'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement about
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}