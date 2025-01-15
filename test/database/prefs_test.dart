import 'package:flutter_test/flutter_test.dart';
import 'package:mindmap_assessment/database/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

main(){

  test("Testing Preferences", ()async{

    SharedPreferences.setMockInitialValues({});

    await Prefs().storeCreds("Hello Testing");

    var res = await Prefs().getCreds();

    expect(res, "Hello Testing");
  });
}