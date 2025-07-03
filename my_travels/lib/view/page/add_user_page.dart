import 'package:flutter/material.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final whiteUser = false;
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios'), centerTitle: true),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: whiteUser
            ? ListView()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF666666),
                    radius: 28,
                    child: Icon(
                      Icons.add_a_photo,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('Usuario'),
                  subtitle: Text('Idade'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete),
                  ),
                ),
              ),
      ),
    );
  }
}
