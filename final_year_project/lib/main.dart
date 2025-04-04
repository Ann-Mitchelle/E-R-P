import 'package:final_year_project/screens/admin/admin_dashboard.dart';

import 'package:final_year_project/screens/employee/employee_dashboard.dart';
import 'package:final_year_project/screens/employee/job_dashboard.dart';
import 'package:final_year_project/screens/employee/leave_application.dart';
import 'package:final_year_project/screens/employee/leave_applications_screen.dart';
import 'package:final_year_project/screens/employee/leave_dashboard.dart';
import 'package:final_year_project/screens/employee/profile_page.dart';
import 'package:final_year_project/screens/employee/show_training.dart';
import 'package:final_year_project/screens/employee/view_job_applications.dart';
import 'package:final_year_project/screens/employee/view_jobs_employee.dart';
import 'package:final_year_project/screens/jobs/create_jobs.dart';
import 'package:final_year_project/screens/jobs/view_jobs.dart';
import 'package:final_year_project/screens/leave_management/view_requests_admin.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/screens/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        // '/': (context) => AdminDashboard(),
        '/': (context) => LoginScreen(),
        "/admin_dashboard": (context) => AdminDashboard(),
        "/add_ad": (context) => AddJobAdvertisement(),
        "/view_jobs": (context) => ViewJobsPage(),
        "/employee_dashboard": (context) => EmployeeDashboard(),
        "/leave_application": (context) => LeaveHomeScreen(),
        "/applyleave": (context) => LeaveApplicationScreen(),
        "/training": (context) => TrainingsScreen(),
        "/applications": (context) => LeaveApplicationsScreen(),
        "/jobNotifications": (context) => JobsDashboard(), // Job Notifications
        "/jobs": (context) => JobsScreen(),
        "/myApplications": (context) => MyApplicationsPage(), // My Applications
        "/profile": (context) => ProfilePage(), // Profile Screen
        '/adminLeaveRequests': (context) => AdminLeaveRequestsPage(),
      },
    );
  }
}
