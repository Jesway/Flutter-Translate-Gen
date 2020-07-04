import 'package:code_builder/code_builder.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class KeysClassGenerator {
  const KeysClassGenerator();

  Reference get _stringType => TypeReference((trb) => trb.symbol = "String");

  Class generate(TranslateKeysOptions options, List<LocalizedItem> items,
      String className) {
    return Class(
      (x) => x
        ..name = className.substring(2)
        ..methods.addAll(items
            .map((translation) => _generateField(translation, options))
            .toList())
        ..constructors.add(Constructor((c) => c.constant = true)),
    );
  }

  Method _generateField(LocalizedItem item, TranslateKeysOptions options) {
    return Method(
      (m) => m
        ..name = item.fieldName.toLowerCase()
        ..returns = _stringType
        ..type = MethodType.getter
        ..lambda = true
        ..body = Code("translate(${literalString(item.key).code})"),
    );
  }
}
