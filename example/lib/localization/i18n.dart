import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';

part 'i18n.g.dart';

@TranslateKeysOptions(
  path: 'assets/i18n.v2',
  caseStyle: CaseStyle.titleCase,
  separator: "_",
)
const i18n = _$I18n();
