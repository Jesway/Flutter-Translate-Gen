import 'package:code_builder/code_builder.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class KeysClassGenerator
{
    static Reference get stringType => TypeReference((trb) => trb..symbol = "String");

    static Class generateClass(TranslateKeysOptions options, List<LocalizedItem> translations, String className)
    {
        return Class((x) => x
            ..docs.add("/// Contains the static localization keys")
            ..name = className.substring(2)
            ..fields.addAll(translations
                    .map((translation) => generateField(translation, options))
                    .toList()),
        );
    }

    static Field generateField(LocalizedItem item, TranslateKeysOptions options)
    {
        return Field((x) => x
                ..name = item.fieldName
                ..type = stringType
                ..static = true
                ..modifier = FieldModifier.constant
                ..assignment = literalString(item.key).code,
        );
    }
}

