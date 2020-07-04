import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

import 'localized_item.dart';

class KeyMapParser {
  static const List<String> pluralsKeys = ["0", "1", "else"];

  final BuildStep step;
  final TranslateKeysOptions options;

  KeyMapParser(this.step, this.options);

  Future<List<LocalizedItem>> parse() async {
    final mapping = <String, List<String>>{};

    final assets = step.findAssets(Glob(options.path, recursive: true));

    await for (final entity in assets) {
      final Map<String, dynamic> jsonMap = json.decode(
        await step.readAsString(entity),
      );
      getTranslationMap(jsonMap).forEach(
        (key, value) => (mapping[key] ??= []).add(value),
      );
    }

    return mapping.entries
        .map((e) => LocalizedItem(
              e.key,
              e.value,
              getKeyFieldName(e.key, options),
            ))
        .toList(growable: false);
  }

  Map<String, String> getTranslationMap(Map<String, dynamic> jsonMap,
      {String parentKey}) {
    final map = <String, String>{};

    for (final entry in jsonMap.keys) {
      String key;

      if (pluralsKeys.contains(entry)) {
        key = parentKey;
      } else {
        key = parentKey != null ? "$parentKey.$entry" : entry;
      }

      if (key == null) continue;

      final value = jsonMap[entry];

      if (value is String) {
        map.putIfAbsent(key, () => value);
      } else {
        final entries = getTranslationMap(value, parentKey: key);
        map.addAll(entries);
      }
    }

    return map;
  }

  String getKeyFieldName(String key, TranslateKeysOptions options) {
    switch (options.caseStyle) {
      case CaseStyle.titleCase:
        return Casing.titleCase(key, separator: options.separator);
      case CaseStyle.upperCase:
        return Casing.upperCase(key, separator: options.separator);
      case CaseStyle.lowerCase:
        return Casing.lowerCase(key, separator: options.separator);
      default:
        return throw InvalidGenerationSourceError(
            "Invalid CaseStyle specified: ${options.caseStyle.toString()}");
    }
  }
}
