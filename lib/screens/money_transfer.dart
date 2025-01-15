import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mindmap_assessment/consts/const.dart';

import '../main.dart';
import '../models/user_model.dart';

class MoneyTransferScreen extends StatefulWidget {
  const MoneyTransferScreen({super.key});

  @override
  State<MoneyTransferScreen> createState() => _MoneyTransferScreenState();
}

class _MoneyTransferScreenState extends State<MoneyTransferScreen> {
  String amount = "";
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Positioned(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Send Money", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        smartDashesType: SmartDashesType.enabled,
                        decoration: InputDecoration(
                          label: Text("Amount to send"),
                          hintText: "Enter the amount you want to send",
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                          helperText: "Available balance ${formatCurrency(userModelNotifier!.value.balance)}"
                        ),
                        onChanged: (val){
                          amount = val;
                        },
                      ),
                      Spacer(),
                      ValueListenableBuilder(
                        valueListenable: internetAvailable,
                        builder: (_, iA, __) {
                          return iA ? Align(
                            alignment: Alignment.center,
                            child: OutlinedButton(
                                onPressed: (){
                                  if(loading)return;
                                  if(amount.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Amount")));
                                  }else {
                                    if(double.parse(amount) < double.parse(userModelNotifier!.value.balance??"0")){
                                      sendAmount();
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You don't have sufficient balance")));
                                    }
                                  }
                                },
                                child: Text("Send", style: TextStyle(color: Colors.white),),
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                            ),
                          ) : Align(
                            alignment: Alignment.center,
                              child: Text("No Internet Connection", style: TextStyle(fontWeight: FontWeight.bold))
                          );
                        }
                      )
                    ],
                  ),
                ),
              ),
              if(loading)Align(
                alignment: Alignment.center,
                  child: Container(
                    child: CircularProgressIndicator(),
                  )
              )
            ],
          ),
        )
    );
  }

  sendAmount(){
    Random().nextInt(2) == 1 ? success() : failure();
  }

  success()async{
    loading = true;
    setState(() {

    });
    FocusScope.of(context).unfocus();

    var res = await post(Uri.parse("${baseUrl}users/${userModelNotifier!.value.id}/transactions"), body: {
      "amount" : amount,
      "userId" : userModelNotifier!.value.id!
    });
    dev.log("Resss ${res.body}");

    var res1 = await put(Uri.parse("${baseUrl}users/${userModelNotifier!.value.id}"), body: {
      "balance" : (double.parse(userModelNotifier!.value.balance??"0") - double.parse(amount)).toString()
    });
    loading = false;
    setState(() {

    });
    dev.log("Resss ${res1.body}");
    userModelNotifier!.value = UserModel.fromJson(jsonDecode(res1.body));
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: <Widget>[
                    Image.asset("assets/success.png", height: 100, width: 100,),
                    Text("Transfer Successful"),
                    Text("Sent $amount$currencyCode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),

                    OutlinedButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: Text("Home", style: TextStyle(color: Colors.white),), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),)
                  ],
                ),
              ),
            ),
          );
        }).whenComplete((){
        Navigator.pop(context);
    });
  }

  failure(){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: <Widget>[
                    Image.asset("assets/failed.png", height: 100, width: 100,),
                    Text("Transfer Failed"),
                    OutlinedButton(onPressed: (){Navigator.pop(context);}, child: Text("Try Again!", style: TextStyle(color: Colors.white),), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),)
                  ],
                ),
              ),
            ),
          );
        });
  }
}
