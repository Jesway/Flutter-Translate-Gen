import 'dart:convert';
import 'dart:io';

import 'package:example/localization/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';

main() {
  setUp(() async {
    final en = File("assets/i18n.v2/en.json");
    final json = jsonDecode(en.readAsStringSync()) as Map<String, dynamic>;
    Localization.load(json);
  });

  test("simple", () {
    expect(i18n.simple, "This is a simple example");
  });

  test("nested", () {
    expect(i18n.nested.child, "This is a nested element");
    expect(i18n.nested.nested.child, "This is an even deeper nested element");
  });

  test("params", () {
    expect(
      i18n.params(something: "parameters"),
      "This is an example with parameters",
    );
  });

  test("camelCase", () {
    expect(
      i18n.language.selectedMessage(language: i18n.language.name.es),
      "Currently selected language is Spanish",
    );
  });

  test("plurals", () {
    final expected = {
      0: "Please start pushing the 'plus' button.",
      1: "You have pushed the button one time.",
      42: "You have pushed the button 42 times."
    };

    final actual = {
      0: i18n.plural.demo(0),
      1: i18n.plural.demo(1),
      42: i18n.plural.demo(42)
    };

    expect(
      actual,
      expected,
    );
  });
}
