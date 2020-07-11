import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class Validator {
  const Validator();

  Result validate(
    FlutterTranslate options,
    LocalizedItemBranch root,
    Iterable<String> knownLanguages,
  ) {
    List<LocalizedItemLeaf> leafs = _flatten(root);

    final result = Result();

    for (final leaf in leafs) {
      final languages = leaf.translations.keys;
      if (knownLanguages.length != languages.length) {
        for (final lang in knownLanguages) {
          if (!leaf.translations.containsKey(lang)) {
            result.log(
              'Missing translation "$lang:${leaf.fullPath}"',
              options.missingTranslations,
            );
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
