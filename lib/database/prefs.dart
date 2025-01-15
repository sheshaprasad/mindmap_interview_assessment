

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Prefs{



  storeCreds(userModel)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', userModel);
  }

  getCreds()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString('user_data');
  }

}