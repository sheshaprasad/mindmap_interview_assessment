

//currency code
import 'package:intl/intl.dart';

const currencyCode = "php";

const baseUrl = "https://67878ee0c4a42c9161075194.mockapi.io/";


formatDate(date){
  return DateFormat("dd-MM-yyyy").format(DateFormat("yyyy-MM-ddTHH:mm:ss.z").parse(date));
}

formatDateTime(date){
  return DateFormat("dd-MM-yyyy - HH:mm").format(DateFormat("yyyy-MM-ddTHH:mm:ss.z").parse(date));
}