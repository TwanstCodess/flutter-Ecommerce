import 'package:flutter/material.dart';

class Mydrawer extends StatefulWidget {
  const Mydrawer({super.key});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://images.pexels.com/photos/1642228/pexels-photo-1642228.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
              ),
              accountName: Text("Eman Baxtyar"),
              accountEmail: Text("emanbaxtyar@gmail.com")),
          Divider(
            color: Colors.black,
            endIndent: 10,
            indent: 10,
            thickness: 2,
          ),
          ListTile(
            title: Text("Product"),
            leading: Icon(Icons.shopping_bag_rounded),
            onTap: () {
              Navigator.pushNamed(context, '/Home');
            },
          ),
          ListTile(
            title: Text("Profile"),
            leading: Icon(Icons.person),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }
}
