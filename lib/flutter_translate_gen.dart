import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter_translate_gen/annotation_generator.dart';
import 'package:flutter_translate_gen/assets_reader.dart';
import 'package:flutter_translate_gen/json_parser.dart';
import 'package:flutter_translate_gen/translation_class_generator.dart';
import 'package:flutter_translate_gen/validator.dart';
import 'package:source_gen/source_gen.dart';

enum ErrorLevel { ignore, warning, error }

class FlutterTranslate {
  final String path;
  final String baseline;
  final ErrorLevel missingTranslations;
  final ErrorLevel missingArguments;

  const FlutterTranslate(
      {this.path,
      this.baseline,
      this.missingTranslations = ErrorLevel.error,
      this.missingArguments = ErrorLevel.error})
      : assert(path != null);

  FlutterTranslate._fromAnnotation(ConstantReader annotation)
      : this(
          path: annotation.asString("path"),
          baseline: annotation.asString("baseline"),
          missingTranslations: annotation.asEnum(
            "missingTranslations",
            ErrorLevel.values,
          ),
          missingArguments: annotation.asEnum(
            "missingArguments",
            ErrorLevel.values,
          ),
        );
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
    final files = await _getFiles(buildStep, options);
    final translations = const JsonParser().parse(files);

    final validationResult = const Validator().validate(
      options,
      translations,
      files.keys,
    );

    if (validationResult.isValid) {
      if (validationResult.warnings.isNotEmpty) {
        printList(validationResult.warnings);
      }

      final generatedClasses = const TranslationClassGenerator().generate(
        translations,
        className,
      );
      return Library((lib) => lib.body.addAll(generatedClasses));
    } else {
      printList(validationResult.errors + validationResult.warnings);
      throw InvalidGenerationSourceError("Validation failed");
    }
  }

  Future<Map<String, Map<String, dynamic>>> _getFiles(
    BuildStep step,
    FlutterTranslate options,
  ) async {
    try {
      return await const AssetsReader().read(step, options);
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
