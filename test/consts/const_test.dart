import 'package:flutter_test/flutter_test.dart';
import 'package:mindmap_assessment/consts/const.dart';

void main(){
  test("testing date format", (){
    final res = formatDate("2025-03-18T20:02:26.174Z");
    expect(res, "18-03-2025");
  });

  test("testing date time format", (){
    final res = formatDateTime("2025-03-18T20:02:26.174Z");
    expect(res, "18-03-2025 - 20:02");
  });


  test("testing currency format", (){
    final res = formatCurrency("123456");
    expect(res, "123,456php");
  });
}