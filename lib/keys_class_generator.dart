import 'package:code_builder/code_builder.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class KeysClassGenerator {
  const KeysClassGenerator();

  Reference get _stringType => TypeReference((trb) => trb.symbol = "String");

  List<Class> generate(
      TranslateKeysOptions options, LocalizedItems items, String className) {
    return _createClassRecursive(items, "_\$$className");
  }

  List<Class> _createClassRecursive(LocalizedItems parent, String name) {
    final classes = <Class>[];
    classes.add(
      Class(
        (cls) => cls
          ..name = name
          ..methods.addAll(parent.leafs.map(_generateLeaf))
          ..fields.addAll(parent.branches.map(_generateBranch))
          ..constructors.add(Constructor((c) => c.constant = true)),
      ),
    );
    classes.addAll(parent.branches
        .expand((items) => _createClassRecursive(items, items.className)));
    return classes;
  }

  Field _generateBranch(LocalizedItems items) {
    return Field(
      (f) => f
        ..name = items.key.toLowerCase()
        ..type = TypeReference((ref) => ref.symbol = items.className)
        ..modifier = FieldModifier.final$
        ..assignment = Code("const ${items.className}()"),
    );
  }

  Method _generateLeaf(LocalizedItem item) {
    final params = item.params;
    return params.isEmpty
        ? _generateLeafAsGetter(item)
        : _generateLeafAsMethod(item, params);
  }

  Method _generateLeafAsMethod(LocalizedItem item, Set<String> params) {
    String args = params.map((p) => '"$p": $p').join(",");

    return Method(
      (m) => m
        ..name = item.key.toLowerCase()
        ..returns = _stringType
        ..lambda = true
        ..optionalParameters.addAll(params.map((param) => Parameter(
              (p) => p
                ..name = param
                ..type = TypeReference((ref) => ref.symbol = "dynamic")
                ..annotations
                    .add(TypeReference((ref) => ref.symbol = "required"))
                ..named = true,
            )))
        ..body = Code(
            "translate(${literalString(item.fullPath).code}, args: {$args})"),
    );
  }

  Method _generateLeafAsGetter(LocalizedItem item) {
    return Method(
      (m) => m
        ..name = item.key.toLowerCase()
        ..returns = _stringType
        ..type = MethodType.getter
        ..lambda = true
        ..body = Code("translate(${literalString(item.fullPath).code})"),
    );
  }
}
