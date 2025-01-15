import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart';
import 'package:mindmap_assessment/models/money_transfer.dart';
import 'package:mindmap_assessment/screens/money_transfer.dart';

import '../consts/const.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>{


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTransactions();
  }

  getTransactions()async{
    var res = await get(Uri.parse("${baseUrl}users/${userModelNotifier.value.id}/transactions"));
    log("res ${res.body}");
    if(res.body.isNotEmpty){
      try {
        transactions = List<Transaction>.from(jsonDecode(res.body).map<Transaction>((i) => Transaction.fromJson(i))).reversed.toList();

        setState(() {

        });
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong Creds Try again!")));
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong, Try again!")));
    }
  }


  List<Transaction> transactions = [];
  List<Payee> payees = [];

  @override
  Widget build(BuildContext context) {
    getTransactions();
    return SafeArea(
        child: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: userModelNotifier,
            builder: (_, userModel, __) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text("Hello! ${userModel.name}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    accountSection(userModel.id,  formatDate(userModel.createdAt),  userModel.balance),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: selMode,
                        builder: (_, sm, __) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              Text("Transactions"),
                              (transactions.isEmpty) ? emptyTransactionsView()
                                  : Flexible(
                                child: ListView.builder(
                                  itemCount: transactions.length,
                                    itemBuilder: (cts, ind){
                                      return transactionListItem(transactions[ind]);
                                    }
                                )
                              ),
                              /*if(tabController.index == 1)*/emptyPayeeView()
                            ],
                          );
                        }
                      ),
                    )
                  ],
                ),
              );
            }
          ),
        )
    );
  }

  transactionListItem(Transaction transaction){
    return Card(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text("Transaction ID : ${transaction.id}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transaction Amount : ${transaction.amount}$currencyCode"),
                Icon(Icons.remove, color: Colors.red,),
              ],
            ),
            Text("Transaction Date : ${formatDateTime(transaction.createdAt)}"),
          ],
        ),
      ),
    );
  }

  payeeListItem(ind){
    return Container(
      child: Text("Payee $ind"),
    );
  }

  ValueNotifier<bool> showBalance = ValueNotifier(false);
  ValueNotifier<int> selMode = ValueNotifier(1);

  headerSection(title, val, selVal){
    return Container(
      decoration: BoxDecoration(
        color: val == selVal ? Colors.blue : Colors.white,
        border: Border.all(color: Colors.black)
      ),
    );
  }

  accountSection(acId, time, balance){

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text("Account ID : $acId", style: TextStyle(fontWeight: FontWeight.bold),),
            Text("Last updated : $time", style: TextStyle(fontWeight: FontWeight.bold),),
            ValueListenableBuilder(
              valueListenable: showBalance,
              builder: (_, sb, __) {
                return Row(
                  spacing: 10,
                  children: [
                    Text("Account balance : ${sb ? balance : "****"} $currencyCode", style: TextStyle(fontWeight: FontWeight.bold),),
                    InkWell(
                      onTap: (){
                        showBalance.value = !showBalance.value;
                      },
                        child: Icon(sb ? Icons.remove_red_eye_outlined : Icons.remove_red_eye, color: Colors.blue,)
                    )
                  ],
                );
              }
            )
          ],
        ),
      ),
    );
  }

  emptyTransactionsView(){
    return Expanded(child: Text("No Transactions available"));
  }

  emptyPayeeView() {
    return Align(
      alignment: Alignment.center,
      child: OutlinedButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (builder) => MoneyTransferScreen()));
          },
          child: Text("Send Money", style: TextStyle(color: Colors.white),),
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
      ),
    );
  }
}
