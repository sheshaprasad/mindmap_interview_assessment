
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mindmap_assessment/network_handlers.dart';
import 'package:mindmap_assessment/screens/dashboard.dart';

import '../consts/const.dart';
import '../main.dart';
import '../models/user_model.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String username = "", password = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  login()async{
    var res = await get(Uri.parse("${baseUrl}users?username=$username&password=$password"));
    log("Response ${res.body}");
    if(res.body.isNotEmpty){
      try {
        userModelNotifier = ValueNotifier(UserModel.fromJson(jsonDecode(res.body)[0]));
        Navigator.push(context, MaterialPageRoute(
            builder: (builder) => DashboardScreen()));
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong Creds Try again!")));
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong, Try again!")));
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 25,
              children: [
                Text("MindMap Assessment - Shesha Prasad", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    spacing: 15,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          label: Text("Username"),
                          hintText: "Enter Username",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))
                        ),
                        onChanged: (val){
                          username = val;
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          label: Text("Password"),
                          hintText: "Enter Password",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))
                        ),
                        onChanged: (val){
                          password = val;
                        },
                      ),
                      OutlinedButton(
                          onPressed: (){
                            if(username.isEmpty || password.isEmpty){
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter both username and password")));
                            }else {
                              login();
                            }
                          },
                          child: Text("Login", style: TextStyle(color: Colors.white),),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.blue)
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
