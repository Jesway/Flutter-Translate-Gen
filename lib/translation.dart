import 'package:dart_casing/dart_casing.dart';

class Translation
{
    String key;
    List<String> translations;
    List<String> groupedKey;
    String separator;

    String get keyVariable
    {
        if (separator != null)
        {
            return key
                    .split(separator)
                    .map((part) => Casing.camelCase(part))
                    .toList()
                    .join("\$");
        }
        else
        {
            return Casing.camelCase(key);
        }
    }

    Translation({String key, this.translations, this.separator})
    {
        this.key = key;

        groupedKey = List.of((this.separator == null ? [key] : key.split(this.separator)));
    }
}

List<String> keysOf(List<Translation> translations)
{
    return translations.map((translation) => translation.key).toList();
}
