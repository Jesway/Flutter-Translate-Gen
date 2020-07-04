import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
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
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final className = element.name;

    _validateClass(element);
    _validateClassName(className);

    final options = _parseOptions(annotation);
    final translations = await _getTranslations(buildStep, options);

    final generatedClasses = const KeysClassGenerator().generate(
      options,
      translations,
      className,
    );
    final generatedLib = Library((lib) => lib.body.addAll(generatedClasses));

    return _createOutput(generatedLib);
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

  String _createOutput(Library generatedLib) {
    final DartEmitter emitter = DartEmitter(Allocator());
    return DartFormatter().format(generatedLib.accept(emitter).toString());
  }

  void _validateClassName(String className) {
    if (!className.startsWith("_\$")) {
      throw InvalidGenerationSourceError(
          "The annotated class name (currently '$className') must start with _\$. For example _\$Keys or _\$LocalizationKeys");
    }
  }

  void _validateClass(Element element) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        "The annotated element is not a Class! TranslateKeyOptions should be used on Classes.",
        element: element,
      );
    }
  }
}

extension on ConstantReader {
  String asString(String key) => peek(key)?.stringValue;

  T asEnum<T>(String key, List<T> values) => enumFromString(
        values,
        peek(key)?.revive()?.accessor,
      );
}
