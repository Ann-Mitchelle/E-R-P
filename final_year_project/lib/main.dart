import 'package:final_year_project/screens/admin/admin_dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/', // Define the default route
      routes: {
        '/': (context) => AdminDashboard(),
        //'/admin_dashboard':(context) => AdminDashboard(),
        // Pass email argument
      },
    );
  }
}
