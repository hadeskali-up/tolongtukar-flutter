# TolongTukar Flutter

Full Flutter architecture port of `com.tolongtukar.app` using the NeedMCP `pet-care-dashboard` neobrutalist visual language: cream canvas, hard black borders, strong yellow/teal/orange cards and direct touch targets.

## Feature parity
- Splash, home dashboard, 20 converter categories and all 223 unit/currency definitions
- Factor, reciprocal, temperature/shoe formula and numeral-system conversion
- Daily forex refresh from `https://alisuhari.top/forex.json` with offline rates
- Persisted category/unit reordering and system/light/dark themes
- AdMob banner using the existing configured test IDs
- Google Play one-time `remove_ads` purchase, restore and persistent entitlement
- Terms/privacy links

## Verification
GitHub Actions generates the Android host, preserves application ID `com.tolongtukar.app`, runs `flutter analyze`, `flutter test`, builds a release APK and uploads it as an artifact.

The current AdMob IDs are Google test IDs inherited from the original app. Replace them with production IDs before Play production rollout.
