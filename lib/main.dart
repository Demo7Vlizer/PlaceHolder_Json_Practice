import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/home/home_view.dart';
import 'controllers/app_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JSONPlaceholder Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AppController());
      }),
      home: const HomeView(),
    );
  }
}
