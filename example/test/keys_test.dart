import 'dart:convert';
import 'dart:io';

import 'package:example/localization/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';

main() {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final en = File("assets/i18n.v2/en.json");
    final json = jsonDecode(en.readAsStringSync()) as Map<String, dynamic>;
    Localization.load(json);
  });

  test("without keys: simple", () {
    expect(translate("simple"), "This is a simple example");
  });

  test("simple", () {
    expect(i18n.simple, "This is a simple example");
  });

  test("nested", () {
    expect(i18n.nested.child, "This is a nested element");
    expect(i18n.nested.nested.child, "This is an even deeper nested element");
  });

  test("params", () {
    expect(i18n.params(something: "parameters"),
        "This is an example with parameters");
  });
}
