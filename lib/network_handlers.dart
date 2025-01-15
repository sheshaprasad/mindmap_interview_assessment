import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class ApiWrapper{

  get(Uri url)async{
    var res = await http.get(url);
    return res;
  }
}