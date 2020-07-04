import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';

part 'keys.g.dart';

@TranslateKeysOptions(
  path: 'assets/i18n.v2',
  caseStyle: CaseStyle.titleCase,
  separator: "_",
)
// ignore: unused_element
class _$Keys {}

const i18n = Keys();
