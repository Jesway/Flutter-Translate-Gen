import 'dart:convert';

import 'package:build/build.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:glob/glob.dart';

import 'localized_item.dart';

class KeyMapParser {
  static const List<String> pluralsKeys = ["0", "1", "else"];

  final BuildStep step;
  final TranslateKeysOptions options;

  KeyMapParser(this.step, this.options);

  Future<LocalizedItemComponent> parse() async {
    final assets = step.findAssets(Glob(options.path, recursive: true));

    final root = LocalizedItems(null, null);
    await for (final entity in assets) {
      final Map<String, dynamic> jsonMap = json.decode(
        await step.readAsString(entity),
      );

      final lang = entity.pathSegments.last.replaceAll(".json", "");
      parseRecursive(lang, jsonMap, root);
    }

    return root;
  }

  void parseRecursive(
    String lang,
    Map<String, dynamic> json,
    LocalizedItems parent,
  ) {
    for (final key in json.keys) {
      if (pluralsKeys.contains(key)) {
        // TODO key = parent.key;
      } else {
        final translation = json[key];

        if (translation is String) {
          final item = parent.ensureItem(key);
          item.translations[lang] = translation;
        } else if (translation is Map<String, dynamic>) {
          final items = parent.ensureItems(key);
          parseRecursive(lang, translation, items);
        }
      }
    }
  }
}
