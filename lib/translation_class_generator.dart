import 'package:code_builder/code_builder.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:flutter_translate_gen/json_parser.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class TranslationClassGenerator {
  final FlutterTranslate _options;

  TranslationClassGenerator(this._options);

  List<Class> generate(
    LocalizedItemBranch root,
    String className,
  ) {
    if (_options.nestingStyle == NestingStyle.nested) {
      return _generateClassRecursive(root, className);
    } else {
      return [_generateFlatClass(root, className)];
    }
  }

  List<Class> _generateClassRecursive(LocalizedItemBranch branch, String name) {
    final classes = <Class>[];
    classes.add(
      _generateClass(
        name: name,
        leafs: branch.leafs,
        plurals: branch.plurals,
        branches: branch.branches,
      ),
    );
    classes.addAll(
      branch.branches.expand(
        (items) => _generateClassRecursive(items, items.className),
      ),
    );
    return classes;
  }

  Class _generateFlatClass(LocalizedItemBranch root, String name) {
    return _generateClass(
      name: name,
      leafs: _getLeafsRecursive(root),
      plurals: _getPluralsRecursive(root),
      branches: [],
    );
  }

  Class _generateClass({
    String name,
    Iterable<LocalizedItemLeaf> leafs,
    Iterable<LocalizedItemBranch> plurals,
    Iterable<LocalizedItemBranch> branches,
  }) =>
      Class(
        (cls) {
          final generatedClass = cls
            ..name = name
            ..constructors.add(Constructor((c) => c.constant = true));

          if (_options.keysStyle == KeysStyle.withTranslate) {
            generatedClass
              ..methods.addAll(leafs.map(_generateLeaf))
              ..methods.addAll(plurals.map(_generateBranchAsPlural))
              ..fields.addAll(branches.map(_generateBranch));
          } else {
            generatedClass
              ..fields.addAll(leafs.map(_generateLeafAsField))
              ..fields.addAll(plurals.map(_generateBranchAsPluralField))
              ..fields.addAll(branches.map(_generateBranch));
          }
        },
      );

  List<LocalizedItemLeaf> _getLeafsRecursive(LocalizedItemBranch parent) {
    return parent.leafs.toList() +
        parent.branches.expand((branch) => _getLeafsRecursive(branch)).toList();
  }

  List<LocalizedItemBranch> _getPluralsRecursive(LocalizedItemBranch parent) {
    return parent.plurals.toList() +
        parent.branches
            .expand((branch) => _getPluralsRecursive(branch))
            .toList();
  }

  Field _generateBranch(LocalizedItemBranch branch) => Field(
        (f) => f
          ..name = _getName(branch)
          ..type = type(branch.className)
          ..modifier = FieldModifier.final$
          ..assignment = "const ${branch.className}()".asCode,
      );

  Method _generateLeaf(LocalizedItemLeaf leaf) {
    final params = leaf.args;
    return params.isEmpty
        ? _generateLeafAsGetter(leaf)
        : _generateLeafAsMethod(leaf, params);
  }

  Method _generateLeafAsGetter(LocalizedItemLeaf leaf) => Method(
        (m) => m
          ..name = _getName(leaf)
          ..returns = stringType
          ..type = MethodType.getter
          ..lambda = true
          ..docs.addAll(leaf.docs)
          ..body = "translate(${leaf.fullPathLiteral})".asCode,
      );

  Method _generateLeafAsMethod(LocalizedItemLeaf leaf, Set<String> args) =>
      Method(
        (m) => m
          ..name = _getName(leaf)
          ..returns = stringType
          ..lambda = true
          ..docs.addAll(leaf.docs)
          ..optionalParameters.addAll(args.asParameters)
          ..body =
              "translate(${leaf.fullPathLiteral}, args: ${args.asMap})".asCode,
      );

  Field _generateLeafAsField(LocalizedItemLeaf leaf) => Field(
        (f) => f
          ..name = _getName(leaf)
          ..type = stringType
          ..modifier = FieldModifier.final$
          ..docs.addAll(leaf.docs)
          ..assignment = leaf.fullPathLiteral,
      );

  Method _generateBranchAsPlural(LocalizedItemBranch plural) {
    final args = plural.leafs.expand((leaf) => leaf.args).toSet();
    final body = args.isEmpty
        ? "translatePlural(${plural.fullPathLiteral}, value)".asCode
        : "translatePlural(${plural.fullPathLiteral}, value, args: ${args.asMap})"
            .asCode;

    return Method(
      (m) => m
        ..name = _getName(plural)
        ..returns = stringType
        ..lambda = true
        ..docs.addAll(plural.docs)
        ..requiredParameters.add(
          Parameter((p) => p
            ..name = "value"
            ..type = intType),
        )
        ..optionalParameters.addAll(args.asParameters)
        ..body = body,
    );
  }

  Field _generateBranchAsPluralField(LocalizedItemBranch plural) => Field(
        (f) => f
          ..name = _getName(plural)
          ..modifier = FieldModifier.final$
          ..type = stringType
          ..docs.addAll(plural.docs)
          ..assignment = plural.fullPathLiteral,
      );

  String _getName(LocalizedItem item) {
    final name =
        _options.nestingStyle == NestingStyle.nested ? item.key : item.fullPath;

    switch (_options.caseStyle) {
      case CaseStyle.titleCase:
        return Casing.titleCase(name, separator: _options.separator);
      case CaseStyle.upperCase:
        return Casing.upperCase(name, separator: _options.separator);
      case CaseStyle.lowerCase:
        return Casing.lowerCase(name, separator: _options.separator);
      case CaseStyle.camelCase:
        return Casing.camelCase(name);
        break;
      default:
        throw ArgumentError("${_options.caseStyle} is not a valid caseStyle");
    }
  }
}

final Reference stringType = type("String");
final Reference intType = type("int");
final Reference dynamicType = type("dynamic");
final Reference requiredAnnotation = type("required");

Reference type(String type) => TypeReference((trb) => trb.symbol = type);

extension on LocalizedItemLeaf {
  List<String> get docs => [
        "/// Translations: ",
        for (final translation in translations.entries)
          "/// * ${translation.key}: ${translation.value.replaceAll("\n", "\\n")}",
        "///",
        "/// parsed from: $fullPath",
      ];
}

extension _Plurals on LocalizedItemBranch {
  List<String> get docs {
    final languages = leafs.expand((leaf) => leaf.translations.keys).toSet();

    final docs = <String>[];
    for (final lang in languages) {
      for (final plural in JsonParser.pluralsKeys) {
        final leaf = this[plural] as LocalizedItemLeaf;
        if (leaf != null) {
          docs.add(
              "/// * $lang:$plural: ${leaf.translations[lang].replaceAll("\n", "\\n")}");
        }
      }
    }

    return [
      "/// Translations: ",
      ...docs,
      "///",
      "/// parsed from: $fullPath",
    ];
  }
}

extension on String {
  Code get asCode => Code(this);
}

extension on Set<String> {
  String get asMap => "{${map((p) => '"$p": $p').join(",")}}";

  Iterable<Parameter> get asParameters => map((param) => Parameter(
        (p) => p
          ..name = param
          ..type = dynamicType
          ..annotations.add(requiredAnnotation)
          ..named = true,
      ));
}
