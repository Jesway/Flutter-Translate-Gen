import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:flutter_translate_gen/json_parser.dart';
import 'package:flutter_translate_gen/validator.dart';
import 'package:test/test.dart';

main() {
  Validator validator;
  JsonParser parser;

  Result validate(Map<String, Map<String, dynamic>> testData,
      {String baseline = "en"}) {
    final root = parser.parse(testData);
    return validator.validate(
      FlutterTranslate(path: "", baseline: baseline),
      root,
    );
  }

  setUp(() async {
    validator = const Validator();
    parser = const JsonParser();
  });

  test("identical trees are fine", () {
    final data = {
      "en": {"test": "This is a test"},
      "de": {"test": "Dies ist ein Test"},
    };

    expect(validate(data).isValid, true);
  });
}
