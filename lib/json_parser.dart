import 'localized_item.dart';

class JsonParser {
  static const List<String> pluralsKeys = ["0", "1", "else"];

  const JsonParser();

  LocalizedItemBranch parse(
    Map<String, Map<String, dynamic>> files,
  ) {
    final root = LocalizedItemBranch(null, null);

    for (final file in files.entries) {
      final lang = file.key;
      final jsonMap = file.value;
      _parseRecursive(lang, jsonMap, root);
    }

    return root;
  }

  void _parseRecursive(
    String lang,
    Map<String, dynamic> json,
    LocalizedItemBranch branch,
  ) {
    for (final key in json.keys) {
      if (pluralsKeys.contains(key)) {
        branch.isPlural = true;
        final translation = json[key];

        if (translation is String) {
          final leaf = branch.ensureLeaf(key);
          leaf.translations[lang] = translation;
        }
      } else {
        final translation = json[key];

        if (translation is String) {
          final leaf = branch.ensureLeaf(key);
          leaf.translations[lang] = translation;
        } else if (translation is Map<String, dynamic>) {
          final nextBranch = branch.ensureBranch(key);
          _parseRecursive(lang, translation, nextBranch);
        }
      }
    }
  }
}
