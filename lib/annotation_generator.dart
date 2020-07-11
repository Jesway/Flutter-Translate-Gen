import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

abstract class AnnotationGenerator<T> extends Generator {
  const AnnotationGenerator();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final values = <String>{};

    for (final annotatedElement in library.annotatedWith(typeChecker)) {
      final generatedLibrary = await generateLibraryForAnnotatedElement(
        annotatedElement.element,
        annotatedElement.annotation,
        buildStep,
      );

      values.add(_createOutput(generatedLibrary));
    }

    return values.join('\n\n');
  }

  FutureOr<Library> generateLibraryForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep);

  String _createOutput(Library generatedLibrary) {
    final DartEmitter emitter = DartEmitter(Allocator());
    return DartFormatter().format(
      generatedLibrary.accept(emitter).toString(),
    );
  }
}
