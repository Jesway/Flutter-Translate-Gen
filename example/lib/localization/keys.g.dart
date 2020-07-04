// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keys.dart';

// **************************************************************************
// Generator: FlutterTranslateGen
// **************************************************************************

class _$_$Keys {
  const _$_$Keys();

  final _$Nested nested = const _$Nested();

  final _$AppBar appBar = const _$AppBar();

  final _$Button button = const _$Button();

  final _$Language language = const _$Language();

  final _$Plural plural = const _$Plural();

  String get simple => translate('simple');
  String params({@required dynamic something}) =>
      translate('params', args: {"something": something});
}

class _$Nested {
  const _$Nested();

  final _$NestedNested nested = const _$NestedNested();

  String get child => translate('nested.child');
}

class _$NestedNested {
  const _$NestedNested();

  String get child => translate('nested.nested.child');
}

class _$AppBar {
  const _$AppBar();

  String get title => translate('app_bar.title');
}

class _$Button {
  const _$Button();

  String get cancel => translate('button.cancel');
  String get changeLanguage => translate('button.change_language');
}

class _$Language {
  const _$Language();

  final _$LanguageName name = const _$LanguageName();

  final _$LanguageSelection selection = const _$LanguageSelection();

  String selectedMessage({@required dynamic language}) =>
      translate('language.selected_message', args: {"language": language});
}

class _$LanguageName {
  const _$LanguageName();

  String get en => translate('language.name.en');
  String get es => translate('language.name.es');
  String get fa => translate('language.name.fa');
}

class _$LanguageSelection {
  const _$LanguageSelection();

  String get message => translate('language.selection.message');
  String get title => translate('language.selection.title');
}

class _$Plural {
  const _$Plural();

  final _$PluralDemo demo = const _$PluralDemo();
}

class _$PluralDemo {
  const _$PluralDemo();
}
