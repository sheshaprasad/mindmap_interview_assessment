import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart';
import 'package:mindmap_assessment/database/database.dart';
import 'package:mindmap_assessment/database/prefs.dart';
import 'package:mindmap_assessment/models/money_transfer.dart';
import 'package:mindmap_assessment/screens/login.dart';
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
    TransactionDatabase transactionDatabase = TransactionDatabase.instance;
    try{
      var res = await get(Uri.parse(
          "${baseUrl}users/${userModelNotifier!.value.id}/transactions"));
      log("res ${res.body}");
      if (res.statusCode == 200) {
        try {
          await transactionDatabase.create(List<Transaction>.from(
              jsonDecode(res.body)
                  .map<Transaction>((i) => Transaction.fromJson(i))));
        } catch (e) {
          log(e.toString());
          //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Transactions found")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Something went wrong, Try again!")));
      }
    }catch(e){}
    transactions = (await transactionDatabase.getTransactions()).reversed.toList();

    loading = false;
    selMode.value = selMode.value++;
  }


  List<Transaction> transactions = [];
  List<Payee> payees = [];
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    getTransactions();
    return SafeArea(
        child: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: userModelNotifier!,
            builder: (_, userModel, __) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Hello! ${userModel.name}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                        IconButton(
                            tooltip: "Logout",
                            onPressed: ()async{
                          await Prefs().remove();
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => LoginScreen(),
                            ),
                                (route) => false,//if you want to disable back feature set to false
                          );
                        }, icon: Icon(Icons.logout, color: Colors.red,))
                      ],
                    ),
                    accountSection(userModel.id,  formatDateTime(userModel.createdAt),  userModel.balance),
                    Flexible(
                      child: ValueListenableBuilder(
                        valueListenable: selMode,
                        builder: (_, sm, __) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              Text("Transactions"),
                              loading ? Expanded(
                                child: Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator()),
                              ) : (transactions.isEmpty) ? emptyTransactionsView()
                                  : Flexible(
                                child: ListView.builder(
                                  itemCount: transactions.length,
                                    itemBuilder: (cts, ind){
                                      return transactionListItem(transactions[ind]);
                                    }
                                )
                              ),
                              ValueListenableBuilder(
                                  valueListenable: internetAvailable,
                                  builder: (_, iA, __){
                                    return iA ? sendMoneyButton() : SizedBox.shrink();
                                  }
                              )
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transaction ID"),
                Text("${transaction.id}", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transaction Amount"),
                Text("${transaction.amount}$currencyCode", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transaction Date"),
                Text("${formatDateTime(transaction.createdAt)}", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
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
                    IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: "Show/Hide Balance",
                      onPressed: (){
                        showBalance.value = !showBalance.value;
                      },
                        icon: Icon(sb ? Icons.remove_red_eye_outlined : Icons.remove_red_eye, color: Colors.blue,)
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

  sendMoneyButton() {
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
