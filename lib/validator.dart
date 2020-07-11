import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:flutter_translate_gen/localized_item.dart';

class Validator {
  const Validator();

  Result validate(FlutterTranslate options, LocalizedItemBranch root) {
    return Result();
  }
}

class Result {
  final List<String> errors = [];
  final List<String> warnings = [];

  bool get isValid => errors.isEmpty;

  Result();
}
