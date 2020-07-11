import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter_translate_gen/annotation_generator.dart';
import 'package:flutter_translate_gen/json_parser.dart';
import 'package:flutter_translate_gen/localized_item.dart';
import 'package:flutter_translate_gen/translation_class_generator.dart';
import 'package:source_gen/source_gen.dart';

class FlutterTranslate {
  final String path;

  const FlutterTranslate({
    this.path,
  }) : assert(path != null);

  FlutterTranslate._fromAnnotation(ConstantReader annotation)
      : this(path: annotation.asString("path"));
}

class FlutterTranslateGen extends AnnotationGenerator<FlutterTranslate> {
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
        "@FlutterTranslate should be used on expressions "
        "like const i18n = _\$I18N();",
        element: element,
      );
    }

    final className = "_\$${Casing.titleCase(element.name, separator: "")}";
    final options = FlutterTranslate._fromAnnotation(annotation);
    final translations = await _getTranslations(buildStep, options);

    final generatedClasses = const TranslationClassGenerator().generate(
      translations,
      className,
    );
    return Library((lib) => lib.body.addAll(generatedClasses));
  }

  Future<LocalizedItemBranch> _getTranslations(
    BuildStep step,
    FlutterTranslate options,
  ) async {
    try {
      return await JsonParser(step, options).parse();
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
