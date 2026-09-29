# Дұрыс сөйле — Android client v2

A Jetpack Compose rewrite of `kz.nu.duryssoile`, wire-compatible with the
existing v1 API. Same package name, same endpoints, new UI.

## Building

Requires JDK 17+ and the Android SDK (compileSdk 35, build-tools 35.0.1).

```bash
./gradlew assembleRelease          # -> app/build/outputs/apk/release/app-release.apk
./gradlew testDebugUnitTest        # API-contract tests
```

`local.properties` must point at the SDK (`sdk.dir=...`).

### Backend URL

The app has no built-in server address; every build needs the backend's base
URL (the one that serves `/words` and `/audio`). The first of these wins:

```bash
./gradlew assembleRelease -PapiBaseUrl=https://example.org/api/v1.0/
API_BASE_URL=https://example.org/api/v1.0/ ./gradlew assembleRelease
echo 'apiBaseUrl=https://example.org/api/v1.0/' >> local.properties
```

The build fails if none is set. A local backend from an emulator:

```bash
./gradlew assembleDebug -PapiBaseUrl=http://10.0.2.2:8080/api/v1.0/
```

`10.0.2.2` is the host loopback as seen from an emulator.

`network_security_config.xml` is generated from that URL. An `https://` URL
permits no cleartext at all; an `http://` URL permits cleartext to that one
host. Debug builds additionally permit cleartext to `10.0.2.2` and
`localhost`.

## ⚠️ Signing before you publish

`keystore.properties` currently points at `testing.jks`, a throwaway key
generated for sideload testing. **Play will reject an update signed with it.**

To publish, replace `keystore.properties` with the original upload key:

```properties
storeFile=/path/to/original-upload-key.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Both files are gitignored. If the original key is lost, Play App Signing can
issue a new upload key — otherwise the listing cannot be updated.

## API contract

The whole backend surface is two endpoints, relative to the base URL:

```
GET words?type=&offset=&limit=&sort=&filter=
GET audio/{id}
```

Two details are load-bearing and easy to break:

- **`offset` is a page index, not a row offset.** The server computes
  `rows[offset*limit : (offset+1)*limit]`. `WordPagingSource` keys pages by
  index and increments by 1. Passing a row offset silently re-fetches
  overlapping rows.
- **`correctVersions` is absent, not empty,** for commonly-mispronounced words,
  and `incorrectUsage`/`correctUsage` are omitted when a version has no example
  sentence. Every model field is nullable for this reason.

`app/src/test/` pins both against a mock server that replays the word lists
in `app/src/test/resources/`.

## Changes from v1

- Jetpack Compose + Material 3, dark mode, edge-to-edge. Palette is seeded from
  the launcher icon (terracotta ornament, cyan headphones).
- Audio is downloaded on a background thread and played from a cached file. v1
  called `MediaPlayer.prepare()` on a remote URL from the click handler, which
  blocks the UI thread for the length of the network call. Replays are now free.
- Paging stops on a short page instead of only on an empty one, saving a round
  trip at the end of every list.
- Cleartext HTTP is scoped to the configured API host instead of enabled
  globally, and is off entirely for an `https://` URL.
- Search debounces at 300 ms; clearing the box is immediate.
- minSdk 21 -> 24, targetSdk 35. versionCode 2.
- Dropped Koin, ViewBinding, fragments, WorkManager (v1 declared
  `WAKE_LOCK`/`FOREGROUND_SERVICE`/`RECEIVE_BOOT_COMPLETED` for a WorkManager it
  never used). Permissions are now `INTERNET` + `ACCESS_NETWORK_STATE`.
- 8.5 MB -> 1.5 MB.
