/// The backend's base URL, the prefix of `/words` and `/audio`, e.g.
/// `https://example.org/api/v1.0`. A build setting rather than part of the
/// code, so the app knows nothing about where it is deployed:
///
///     flutter run --dart-define=API_BASE_URL=https://example.org/api/v1.0
///
/// The app shows an error screen instead of starting if it is missing.
const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
