import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:flutter_translate_gen/json_parser.dart';
import 'package:flutter_translate_gen/validator.dart';
import 'package:test/test.dart';

main() {
  Validator validator;
  JsonParser parser;

  Result validate(
    Map<String, Map<String, dynamic>> testData, {
    String baseline = "en",
    ErrorLevel missingTranslations = ErrorLevel.error,
  }) {
    final root = parser.parse(testData);
    return validator.validate(
        FlutterTranslate(
          path: "",
          baseline: baseline,
          missingTranslations: missingTranslations,
        ),
        root,
        testData.keys);
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

    final result = validate(data);

    expect(result.isValid, true);
    expect(result.errors, []);
    expect(result.warnings, []);
  });

  test("missing translation causes error", () {
    final data = {
      "en": {"test": "This is a test"},
      "de": <String, dynamic>{},
    };

    final result = validate(data);

    expect(result.isValid, false);
    expect(result.errors, ['Missing translation "de:test"']);
    expect(result.warnings, []);
  });

  test("missing translation causes warning, if configured", () {
    final data = {
      "en": {"test": "This is a test"},
      "de": <String, dynamic>{},
    };

    final result = validate(
      data,
      missingTranslations: ErrorLevel.warning,
    );

    expect(result.isValid, true);
    expect(result.errors, []);
    expect(result.warnings, ['Missing translation "de:test"']);
  });

  test("missing translation is ignored, if configured", () {
    final data = {
      "en": {"test": "This is a test"},
      "de": <String, dynamic>{},
    };

    final result = validate(
      data,
      missingTranslations: ErrorLevel.ignore,
    );

    expect(result.isValid, true);
    expect(result.errors, []);
    expect(result.warnings, []);
  });

  test("nested missing translation causes error", () {
    final data = {
      "en": {
        "test": "This is a test",
        "nested": {
          "a": "This is A",
          "b": "This is B",
        }
      },
      "de": {
        "test": "Dies ist ein Test",
        "nested": {"a": "Dies ist A"},
      },
    };

    final result = validate(data);

    expect(result.isValid, false);
    expect(result.errors, ['Missing translation "de:nested.b"']);
    expect(result.warnings, []);
  });

  test("missing plurals translation causes error", () {
    final data = {
      "en": {
        "plurals": {
          "zero": "zero",
          "one": "one",
          "else": "more",
        }
      },
      "de": {
        "plurals": {
          "zero": "null",
          "one": "eins",
        },
      },
    };

    final result = validate(data);

    expect(result.isValid, false);
    expect(result.errors, ['Missing translation "de:plurals.else"']);
    expect(result.warnings, []);
  });

  test("missing arg causes error", () {
    final data = {
      "en": {"test": "This is a {test}"},
      "de": {"test": "Dies ist ein Test"}
    };

    final result = validate(data);

    expect(result.isValid, false);
    expect(result.errors, ['Missing argument "test" in "de:test"']);
    expect(result.warnings, []);
  });
}
