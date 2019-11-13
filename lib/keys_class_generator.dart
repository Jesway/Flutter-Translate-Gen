import 'package:code_builder/code_builder.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:flutter_translate_gen/translation.dart';

const String strKeysClassName = "_\$Keys";

Reference get stringType => TypeReference((trb) => trb..symbol = "String");

Class generateKeysClass(List<Translation> translations, String className)
{
    return Class((x) => x
            ..docs.add("/// Contains the static localization keys")
            ..name = className.substring(2)
            ..fields.addAll(translations
                    .map((translation) => generateField(translation))
                    .toList()),
    );
}

Field generateField(Translation translation)
{
    var a = translation.keyVariable;

    var key = translation.keyVariable.replaceAll("\$", "\\");
    var name = Casing.titleCase(key, separator: translation.separator);

    return Field(
                (fb) => fb
            ..name = name //translation.keyVariable.replaceAll("\$", '_')
            ..type = stringType
            ..static = true
            ..modifier = FieldModifier.final$
            ..assignment = literalString(translation.key).code,
    );
}


