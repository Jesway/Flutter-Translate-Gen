import 'package:code_builder/code_builder.dart';
import 'package:dart_casing/dart_casing.dart';

abstract class LocalizedItem {
  final String path;
  final String key;

  LocalizedItem._(this.path, this.key);

  String get fullPath => path == null || path.isEmpty ? key : "$path.$key";

  Code get fullPathLiteral => literalString(fullPath).code;
}

class LocalizedItemBranch extends LocalizedItem {
  final Map<String, LocalizedItem> _children;
  bool isPlural;

  LocalizedItemBranch(String path, String key)
      : _children = {},
        isPlural = false,
        super._(path, key);

  LocalizedItem operator [](String key) => _children[key];

  void operator []=(String key, LocalizedItem item) => _children[key] = item;

  Iterable<LocalizedItemLeaf> get leafs =>
      _children.values.whereType<LocalizedItemLeaf>();

  Iterable<LocalizedItemBranch> get branches => _children.values
      .whereType<LocalizedItemBranch>()
      .where((v) => !v.isPlural);

  Iterable<LocalizedItemBranch> get plurals => _children.values
      .whereType<LocalizedItemBranch>()
      .where((v) => v.isPlural);

  LocalizedItemLeaf ensureLeaf(String child) {
    if (this[child] == null) {
      final newItem = LocalizedItemLeaf(_pathFor(key), child);
      this[child] = newItem;
      return newItem;
    } else if (this[child] is LocalizedItemLeaf) {
      return this[child] as LocalizedItemLeaf;
    } else {
      throw StateError("${_pathFor(child)} is not translated consistently");
    }
  }

  LocalizedItemBranch ensureBranch(String child) {
    if (this[child] == null) {
      final newItem = LocalizedItemBranch(_pathFor(key), child);
      this[child] = newItem;
      return newItem;
    } else if (this[child] is LocalizedItemBranch) {
      return this[child] as LocalizedItemBranch;
    } else {
      throw StateError("${_pathFor(child)} is not translated consistently");
    }
  }

  String get className => "_\$${Casing.titleCase(fullPath, separator: "")}";

  String _pathFor(String key) {
    if (path == null) {
      return "";
    } else if (path.isEmpty) {
      return key;
    } else {
      return "$path.$key";
    }
  }
}

class LocalizedItemLeaf extends LocalizedItem {
  final Map<String, String> translations;
  final _argsRegex = RegExp(r"\{([^\}]+)\}");

  LocalizedItemLeaf(String path, String key)
      : translations = {},
        super._(path, key);

  void operator []=(String lang, String translation) =>
      translations[lang] = translation;

  Set<String> get args {
    return translations.values.expand(_argsForTranslation).toSet();
  }

  Set<String> argsForLang(String lang) {
    return _argsForTranslation(translations[lang]);
  }

  Set<String> _argsForTranslation(String translation) => _argsRegex
      .allMatches(translation.replaceAll("{{value}}", "ignored"))
      .map((e) => e.group(1))
      .toSet();
}
