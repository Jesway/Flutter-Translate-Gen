import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:flutter_translate_gen/annotation_generator.dart';
import 'package:flutter_translate_gen/key_map_parser.dart';
import 'package:flutter_translate_gen/keys_class_generator.dart';
import 'package:flutter_translate_gen/localized_item.dart';
import 'package:source_gen/source_gen.dart';

class FlutterTranslateGen extends AnnotationGenerator<TranslateKeysOptions> {
  const FlutterTranslateGen();

  @override
  Future<Library> generateLibraryForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (!element.isConstRootVariable) {
      throw InvalidGenerationSourceError(
        "The annotated element is not a root const variable! "
        "TranslateKeyOptions should be used on expressions "
        "like const i18n = _\$I18N();",
        element: element,
      );
    }

    final className = "_\$${Casing.titleCase(element.name, separator: "")}";
    final options = _parseOptions(annotation);
    final translations = await _getTranslations(buildStep, options);

    final generatedClasses = const KeysClassGenerator().generate(
      options,
      translations,
      className,
    );
    return Library((lib) => lib.body.addAll(generatedClasses));
  }

  TranslateKeysOptions _parseOptions(ConstantReader annotation) =>
      TranslateKeysOptions(
        path: annotation.asString("path"),
        caseStyle: annotation.asEnum("caseStyle", CaseStyle.values),
        separator: annotation.asString("separator"),
      );

  Future<LocalizedItems> _getTranslations(
    BuildStep step,
    TranslateKeysOptions options,
  ) async {
    try {
      return await KeyMapParser(step, options).parse();
    } catch (e) {
      throw InvalidGenerationSourceError("Ths JSON format is invalid: $e");
    }
  }
}

extension on Element {
  bool get isConstRootVariable =>
      this is VariableElement &&
      (this as VariableElement).isConst &&
      enclosingElement is CompilationUnitElement;
}

extension on ConstantReader {
  String asString(String key) => peek(key)?.stringValue;

  T asEnum<T>(String key, List<T> values) => enumFromString(
        values,
        peek(key)?.revive()?.accessor,
      );
}
