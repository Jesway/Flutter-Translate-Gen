import 'dart:convert';

import 'package:build/build.dart';
import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:glob/glob.dart';

class AssetsReader {
  const AssetsReader();

  Future<Map<String, Map<String, dynamic>>> read(
    BuildStep step,
    FlutterTranslate options,
  ) async {
    final assets = step.findAssets(Glob(options.path, recursive: true));

    final result = <String, Map<String, dynamic>>{};
    await for (final entity in assets) {
      if (entity.pathSegments.last.endsWith(".json")) {
        final Map<String, dynamic> jsonMap = jsonDecode(
          await step.readAsString(entity),
        );

        final lang = entity.pathSegments.last.replaceAll(".json", "");
        result[lang] = jsonMap;
      }
    }

    return result;
  }
}
