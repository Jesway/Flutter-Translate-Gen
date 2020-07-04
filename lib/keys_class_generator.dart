import 'package:code_builder/code_builder.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class KeysClassGenerator {
  const KeysClassGenerator();

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
          ..methods.addAll(parent.plurals.map(_generateLeafAsPlural))
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
        ..name = items.camelCasedKey
        ..type = _type(items.className)
        ..modifier = FieldModifier.final$
        ..assignment = "const ${items.className}()".asCode,
    );
  }

  Method _generateLeaf(LocalizedItem item) {
    final params = item.args;
    return params.isEmpty
        ? _generateLeafAsGetter(item)
        : _generateLeafAsMethod(item, params);
  }

  Method _generateLeafAsGetter(LocalizedItem item) {
    return Method(
      (m) => m
        ..name = item.camelCasedKey
        ..returns = _string$
        ..type = MethodType.getter
        ..lambda = true
        ..body = "translate(${item.fullPathLiteral})".asCode,
    );
  }

  Method _generateLeafAsMethod(LocalizedItem item, Set<String> args) {
    return Method(
      (m) => m
        ..name = item.camelCasedKey
        ..returns = _string$
        ..lambda = true
        ..optionalParameters.addAll(args.asParameters)
        ..body =
            "translate(${item.fullPathLiteral}, args: ${args.asMap})".asCode,
    );
  }

  Method _generateLeafAsPlural(LocalizedItems plural) {
    final args = plural.leafs.expand((leaf) => leaf.args).toSet();
    final body = args.isEmpty
        ? "translatePlural(${plural.fullPathLiteral}, value)".asCode
        : "translatePlural(${plural.fullPathLiteral}, value, args: ${args.asMap})"
            .asCode;

    return Method(
      (m) => m
        ..name = plural.camelCasedKey
        ..returns = _string$
        ..lambda = true
        ..requiredParameters.add(
          Parameter((p) => p
            ..name = "value"
            ..type = _int$),
        )
        ..optionalParameters.addAll(args.asParameters)
        ..body = body,
    );
  }
}

final Reference _string$ = _type("String");
final Reference _int$ = _type("int");
final Reference _dynamic$ = _type("dynamic");
final Reference _required$ = _type("required");

Reference _type(String type) => TypeReference((trb) => trb.symbol = type);

extension on String {
  Code get asCode => Code(this);
}

extension on Set<String> {
  String get asMap => "{${map((p) => '"$p": $p').join(",")}}";

  Iterable<Parameter> get asParameters => map((param) => Parameter(
        (p) => p
          ..name = param
          ..type = _dynamic$
          ..annotations.add(_required$)
          ..named = true,
      ));
}
