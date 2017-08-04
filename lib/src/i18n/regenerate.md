To rebuild the i18n files:

```
pub run intl:generate_from_arb \
    --output-dir=lib/i18n --generated-file-prefix=lang_ --no-use-deferred-loading \
    lib/app_strings.dart lib/i18n/lang_*.arb
```
