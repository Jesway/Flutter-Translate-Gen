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
        ..fields.addAll(items
            .map((translation) => _generateField(translation, options))
            .toList()),
    );
  }

  Field _generateField(LocalizedItem item, TranslateKeysOptions options) {
    return Field(
      (field) => field
        ..name = item.fieldName
        ..type = _stringType
        ..static = true
        ..modifier = FieldModifier.constant
        ..assignment = literalString(item.key).code,
    );
  }
}
