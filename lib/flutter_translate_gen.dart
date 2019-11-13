import 'dart:async';
import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter_translate_annotations/flutter_translate_annotations.dart';
import 'package:flutter_translate_gen/annotation_generator.dart';
import 'package:flutter_translate_gen/keys_class_generator.dart';
import 'package:flutter_translate_gen/translation.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

class FlutterTranslateGen extends AnnotationGenerator<TranslateKeysOptions>
{
    const FlutterTranslateGen();

    @override
    Future<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async
    {
        validateClass(element);

        final options = parseOptions(annotation);

        var className = element.name;

        validateClassName(className);

        List<Translation> translations;

        try
        {
            translations = await getKeyMap(buildStep, options);
        }
        on FormatException catch (_)
        {
            throw InvalidGenerationSourceError("Ths JSON format is invalid.");
        }

        validateLocalizationItems(translations);

        final file = Library((lb) => lb..body.addAll([generateKeysClass(translations, className)]));

        final DartEmitter emitter = DartEmitter(Allocator());

        return DartFormatter().format('${file.accept(emitter)}');
    }

    TranslateKeysOptions parseOptions(ConstantReader annotation)
    {
        return TranslateKeysOptions(
                path: annotation.peek("path")?.stringValue,
                caseStyle: enumFromString(CaseStyle.values, annotation.peek("caseStyle").revive().accessor),
                separator: annotation.peek("separator")?.stringValue);
    }

    Future<List<Translation>> getKeyMap(BuildStep step, TranslateKeysOptions options) async
    {
        var mapping = <String, List<String>>{};

        var assets = await step.findAssets(Glob(options.path, recursive: true)).toList();

        for (var entity in assets)
        {
            Map<String, dynamic> jsonMap = json.decode(await step.readAsString(entity));

            var translationMap = getTranslationMap(jsonMap);

            translationMap.forEach((key, value) => (mapping[key] ??= <String>[]).add(value));
        }

        var translations = List<Translation>();

        mapping.forEach((id, trans) => translations.add(Translation(key: id, translations: trans, separator: options.separator),));

        return translations;
    }

    Map<String, String> getTranslationMap(Map<String, dynamic> jsonMap, {String parentKey})
    {
        final map = Map<String, String>();

        for(var entry in jsonMap.keys)
        {
            var key = parentKey != null ? "$parentKey.$entry" : entry;
            var value = jsonMap[entry];

            if(value is String)
            {
                map.putIfAbsent(key, () => value);
            }
            else
            {
                var entries = getTranslationMap(value, parentKey: key);

                map.addAll(entries);
            }
        }

        return map;
    }

    void validateLocalizationItems(List<Translation> translations)
    {
        if (translations.isEmpty) return;

        translations.sort((translation1, translation2) => translation1.translations.length - translation2.translations.length);

        int requiredLength = translations.first.translations.length;

        translations.where((trans) => trans.translations.length < requiredLength);

        List<String> invalidKeys = keysOf(translations.where((translation) => translation.translations.length < requiredLength).toList());

        if (invalidKeys.isNotEmpty)
        {
            throw InvalidGenerationSourceError("Some localization keys seem to be missing from the JSON files. Possibly missing keys: ${invalidKeys.join(", ")}.");
        }
    }

    void validateClassName(String className)
    {
        if(!className.startsWith("_\$"))
        {
            throw InvalidGenerationSourceError("The annotated class name (currently '$className') must start with _\$. For example _\$Keys or _\$LocalizationKeys");
        }
    }

    void validateClass(Element element)
    {
        if (element is! ClassElement)
        {
            throw InvalidGenerationSourceError("The annotated element is not a Class! TranslateKeyOptions should be used on Classes.", element: element);
        }
    }
}
