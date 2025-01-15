import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mindmap_assessment/screens/dashboard.dart';
import 'package:mindmap_assessment/screens/login.dart';

import 'database/prefs.dart';
import 'models/user_model.dart';


ValueNotifier<bool> internetAvailable = ValueNotifier(false);

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  internetAvailable.value = await InternetConnection().hasInternetAccess;

  await checkLogin();

  final listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
    switch (status) {
      case InternetStatus.connected:
      // The internet is now connected
      internetAvailable.value = true;
        break;
      case InternetStatus.disconnected:
      // The internet is now disconnected
        internetAvailable.value = false;
        break;
    }
  });

  runApp(const MyApp());

}


checkLogin()async{
  var res = await Prefs().getCreds();
  if(res != null){
    userModelNotifier = ValueNotifier(UserModel.fromJson(jsonDecode(res)[0]));
  }
}


ValueNotifier<UserModel>? userModelNotifier;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'MindMap Assessment',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: userModelNotifier!=null ? DashboardScreen() : LoginScreen()
    );
  }
}

