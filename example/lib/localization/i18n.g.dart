// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'i18n.dart';

// **************************************************************************
// Generator: FlutterTranslateGen
// **************************************************************************

class _$I18n {
  const _$I18n();

  final _$Nested nested = const _$Nested();

  final _$AppBar appBar = const _$AppBar();

  final _$Button button = const _$Button();

  final _$Language language = const _$Language();

  final _$Plural plural = const _$Plural();

  /// Translations:
  /// * en: This is a simple example
  ///
  /// parsed from: simple
  String get simple => translate('simple');

  /// Translations:
  /// * en: This is an example with {something}
  ///
  /// parsed from: params
  String params({@required dynamic something}) =>
      translate('params', args: {"something": something});

  /// Translations:
  /// * en: This is a multiline test\n\nThis should somehow be reflected in the docs
  ///
  /// parsed from: multiline
  String get multiline => translate('multiline');
}

class _$Nested {
  const _$Nested();

  final _$NestedNested nested = const _$NestedNested();

  /// Translations:
  /// * en: This is a nested element
  ///
  /// parsed from: nested.child
  String get child => translate('nested.child');
}

class _$NestedNested {
  const _$NestedNested();

  /// Translations:
  /// * en: This is an even deeper nested element
  ///
  /// parsed from: nested.nested.child
  String get child => translate('nested.nested.child');
}

class _$AppBar {
  const _$AppBar();

  /// Translations:
  /// * en: Welcome to the home page
  /// * es: Bienvenido a la página de inicio
  ///
  /// parsed from: app_bar.title
  String get title => translate('app_bar.title');
}

class _$Button {
  const _$Button();

  /// Translations:
  /// * en: Cancel
  /// * es: Cancelar
  ///
  /// parsed from: button.cancel
  String get cancel => translate('button.cancel');

  /// Translations:
  /// * en: Change Language
  /// * es: Cambiar idioma
  ///
  /// parsed from: button.change_language
  String get changeLanguage => translate('button.change_language');
}

class _$Language {
  const _$Language();

  final _$LanguageName name = const _$LanguageName();

  final _$LanguageSelection selection = const _$LanguageSelection();

  /// Translations:
  /// * en: Currently selected language is {language}
  /// * es: El idioma seleccionado actualmente es {language}
  ///
  /// parsed from: language.selected_message
  String selectedMessage({@required dynamic language}) =>
      translate('language.selected_message', args: {"language": language});
}

class _$LanguageName {
  const _$LanguageName();

  /// Translations:
  /// * en: English
  /// * es: Inglés
  ///
  /// parsed from: language.name.en
  String get en => translate('language.name.en');

  /// Translations:
  /// * en: Spanish
  /// * es: Español
  ///
  /// parsed from: language.name.es
  String get es => translate('language.name.es');

  /// Translations:
  /// * en: Persian
  /// * es: Persa
  ///
  /// parsed from: language.name.fa
  String get fa => translate('language.name.fa');
}

class _$LanguageSelection {
  const _$LanguageSelection();

  /// Translations:
  /// * en: Please select a language from the list
  /// * es: Por favor seleccione un idioma de la lista
  ///
  /// parsed from: language.selection.message
  String get message => translate('language.selection.message');

  /// Translations:
  /// * en: Language Selection
  /// * es: Selección de idioma
  ///
  /// parsed from: language.selection.title
  String get title => translate('language.selection.title');
}

class _$Plural {
  const _$Plural();

  /// Translations:
  /// * en:0: Please start pushing the 'plus' button.
  /// * en:1: You have pushed the button one time.
  /// * en:else: You have pushed the button {{value}} times.
  /// * es:0: Por favor, comience a presionar el botón 'más'.
  /// * es:1: Has presionado el botón una vez.
  /// * es:else: Ha presionado el botón {{value}} veces.
  ///
  /// parsed from: plural.demo
  String demo(int value) => translatePlural('plural.demo', value);

  /// Translations:
  /// * en:1: banana
  /// * en:else: bananas
  ///
  /// parsed from: plural.banana
  String banana(int value) => translatePlural('plural.banana', value);

  /// Translations:
  /// * en:0: I have no {things}.
  /// * en:1: I have one {things}.
  /// * en:else: I have {{value}} {things}.
  ///
  /// parsed from: plural.demo_with_args
  String demoWithArgs(int value, {@required dynamic things}) =>
      translatePlural('plural.demo_with_args', value, args: {"things": things});
}

class _$Keys {
  const _$Keys();

  /// Translations:
  /// * en: Welcome to the home page
  /// * es: Bienvenido a la página de inicio
  ///
  /// parsed from: app_bar.title
  final String App_Bar_Title = 'app_bar.title';

  /// Translations:
  /// * en: Cancel
  /// * es: Cancelar
  ///
  /// parsed from: button.cancel
  final String Button_Cancel = 'button.cancel';

  /// Translations:
  /// * en: Change Language
  /// * es: Cambiar idioma
  ///
  /// parsed from: button.change_language
  final String Button_Change_Language = 'button.change_language';

  /// Translations:
  /// * en: Currently selected language is {language}
  /// * es: El idioma seleccionado actualmente es {language}
  ///
  /// parsed from: language.selected_message
  final String Language_Selected_Message = 'language.selected_message';

  /// Translations:
  /// * en: English
  /// * es: Inglés
  ///
  /// parsed from: language.name.en
  final String Language_Name_En = 'language.name.en';

  /// Translations:
  /// * en: Spanish
  /// * es: Español
  ///
  /// parsed from: language.name.es
  final String Language_Name_Es = 'language.name.es';

  /// Translations:
  /// * en: Persian
  /// * es: Persa
  ///
  /// parsed from: language.name.fa
  final String Language_Name_Fa = 'language.name.fa';

  /// Translations:
  /// * en: Please select a language from the list
  /// * es: Por favor seleccione un idioma de la lista
  ///
  /// parsed from: language.selection.message
  final String Language_Selection_Message = 'language.selection.message';

  /// Translations:
  /// * en: Language Selection
  /// * es: Selección de idioma
  ///
  /// parsed from: language.selection.title
  final String Language_Selection_Title = 'language.selection.title';

  /// Translations:
  /// * en:0: Por favor, comience a presionar el botón 'más'.
  /// * en:1: Has presionado el botón una vez.
  /// * en:else: Ha presionado el botón {{value}} veces.
  /// * es:0: Por favor, comience a presionar el botón 'más'.
  /// * es:1: Has presionado el botón una vez.
  /// * es:else: Ha presionado el botón {{value}} veces.
  ///
  /// parsed from: plural.demo
  final String Plural_Demo = 'plural.demo';
}
