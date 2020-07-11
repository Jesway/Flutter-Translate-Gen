import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class Validator {
  const Validator();

  Result validate(
    FlutterTranslate options,
    LocalizedItemBranch root,
    Iterable<String> allLanguages,
  ) {
    List<LocalizedItemLeaf> leafs = _flatten(root);

    final result = Result();

    for (final leaf in leafs) {
      final allArgs = leaf.args;
      for (final lang in allLanguages) {
        if (!leaf.translations.containsKey(lang)) {
          result.log(
            'Missing translation "$lang:${leaf.fullPath}"',
            options.missingTranslations,
          );
        } else {
          for (var arg in allArgs) {
            if (!leaf.argsForLang(lang).contains(arg)) {
              result.log(
                'Missing argument "$arg" in "$lang:${leaf.fullPath}"',
                options.missingArguments,
              );
            }
          }
        }
      }
    }

    return result;
  }

  List<LocalizedItemLeaf> _flatten(LocalizedItemBranch branch) {
    final translations = <LocalizedItemLeaf>[];

    translations.addAll(branch.leafs);
    translations.addAll(branch.branches.expand(_flatten));
    translations.addAll(branch.plurals.expand(_flatten));

    return translations;
  }
}

class Result {
  final List<String> errors = [];
  final List<String> warnings = [];

  bool get isValid => errors.isEmpty;

  Result();

  void log(String message, ErrorLevel level) {
    if (level == ErrorLevel.error) {
      errors.add(message);
    } else if (level == ErrorLevel.warning) {
      warnings.add(message);
    }
  }
}
