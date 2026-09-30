# Дұрыс сөйле — mobile app

Flutter app for Android and iOS: the Kazakh pronunciation reference with
two word lists (commonly mispronounced words, and foreign words with their
Kazakh equivalents), search, pronunciation playback, and favourites that
work offline. Interface in Kazakh, Russian and English; the dictionary
itself is Kazakh.

It talks to the Дұрыс сөйле API (`/words`, `/audio`) and knows nothing about
where that is deployed: the base URL is a build setting.

## Building

```bash
flutter run   --dart-define=API_BASE_URL=https://example.org/api/v1.0
flutter build apk --release --dart-define=API_BASE_URL=https://example.org/api/v1.0
flutter build ipa --release --dart-define=API_BASE_URL=https://example.org/api/v1.0  # macOS only
flutter test
```

A build without `API_BASE_URL` starts with an error screen saying so.

Without a local Flutter install, Linux can build and test the Android app
through Docker: `tool/flutter.Dockerfile` pins the Flutter release and the
Android SDK parts the build needs, and `tool/flutter` runs Flutter in it.

```bash
docker build -t durys-soile-flutter:3.47.5 -f tool/flutter.Dockerfile tool
tool/flutter test
tool/flutter build apk --dart-define=API_BASE_URL=https://example.org/api/v1.0
```

iOS builds need macOS and Xcode.

## Favourites

A favourite stores the word as the API returned it and its MP3 on the
device, so it plays without a network. On every start, and on pull-to-refresh
in the Favourites tab, each favourite is checked against the API with a
conditional request (`If-None-Match` with the stored `ETag`): unchanged words
and clips answer `304` and are not downloaded again; changed ones are
replaced. A word deleted from the dictionary (`404`) stays, flagged, until
the user removes it.

## API contract

Two details are load-bearing:

- **`offset` is a page number, not a row offset**: the API returns rows
  `[offset*limit, (offset+1)*limit)`. `WordListController` pages by index and
  stops at a short page.
- **`correctVersions` is absent, not empty,** for commonly mispronounced
  words, and `incorrectUsage` / `correctUsage` are absent when a version has
  no example sentence.

`test/fake_backend.dart` replays this contract, ETags included, over real
entries from the backend's seed data (`test/fixtures`).

## Localisation

Strings live in `lib/l10n/app_{kk,ru,en}.arb`; Kazakh is the template.
The About screen lets the user override the device language.
