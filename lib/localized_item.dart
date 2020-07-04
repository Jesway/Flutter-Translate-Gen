import 'package:dart_casing/dart_casing.dart';

abstract class LocalizedItemComponent {
  final String path;
  final String key;

  LocalizedItemComponent._(this.path, this.key);

  String get fullPath => path == null || path.isEmpty ? key : "$path.$key";

  String get camelCasedKey => Casing.camelCase(key);
}

class LocalizedItems extends LocalizedItemComponent {
  final Map<String, LocalizedItemComponent> _children;
  bool isPlural;

  LocalizedItems(String path, String key)
      : _children = {},
        isPlural = false,
        super._(path, key);

  LocalizedItemComponent operator [](String key) => _children[key];

  void operator []=(String key, LocalizedItemComponent item) =>
      _children[key] = item;

  Iterable<LocalizedItem> get leafs =>
      _children.values.whereType<LocalizedItem>();

  Iterable<LocalizedItems> get branches =>
      _children.values.whereType<LocalizedItems>().where((v) => !v.isPlural);

  Iterable<LocalizedItems> get plurals =>
      _children.values.whereType<LocalizedItems>().where((v) => v.isPlural);

  LocalizedItem ensureItem(String child) {
    if (this[child] == null) {
      final newItem = LocalizedItem(_pathFor(key), child);
      this[child] = newItem;
      return newItem;
    } else if (this[child] is LocalizedItem) {
      return this[child] as LocalizedItem;
    } else {
      throw StateError("${_pathFor(child)} is not translated consistently");
    }
  }

  LocalizedItems ensureItems(String child) {
    if (this[child] == null) {
      final newItem = LocalizedItems(_pathFor(key), child);
      this[child] = newItem;
      return newItem;
    } else if (this[child] is LocalizedItems) {
      return this[child] as LocalizedItems;
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

class LocalizedItem extends LocalizedItemComponent {
  final Map<String, String> translations;

  LocalizedItem(String path, String key)
      : translations = {},
        super._(path, key);

  void operator []=(String lang, String translation) =>
      translations[lang] = translation;

  Set<String> get params {
    final regex = RegExp(r"\{([^\}]+)\}");
    return translations.values
        .expand((translation) =>
            regex.allMatches(translation.replaceAll("{{value}}", "ignored")))
        .map((e) => e.group(1))
        .toSet();
  }
}
