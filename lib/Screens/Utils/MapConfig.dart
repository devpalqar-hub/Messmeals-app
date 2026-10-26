/// Mapbox access token used for the location-picker map on signup.
///
/// Supplied at build/run time via `--dart-define=MAPBOX_ACCESS_TOKEN=...`
/// (or through `.vscode/launch.json`'s `args`, which is gitignored) —
/// never hardcoded here, since this file is committed to git.
const String mapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
);

String mapboxTileUrlTemplate(String styleId) =>
    'https://api.mapbox.com/styles/v1/mapbox/$styleId/tiles/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken';
