import 'package:build/build.dart';
import 'package:flutter_translate_gen/flutter_translate_gen.dart';
import 'package:source_gen/source_gen.dart';

Builder staticKeysBuilder(BuilderOptions options)
{
    print(options.config.length);

    for(var key in options.config.keys) {

        var value = options.config[key];

        print("${key} - ${value}");
    }

    return SharedPartBuilder([FlutterTranslateGen()], 'static_keys_generator');
}
