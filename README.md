# safelink

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Backend schema

This app consumes Supabase at runtime (auth + Postgres). The canonical schema
and migrations live in a separate repo / project-root `supabase/` folder, not
in this repo. Run `supabase` CLI commands (`supabase migration new`,
`supabase db reset`, `supabase db diff`) from the schema folder, not from here.

## Maps setup (Android)

The Google Maps Android SDK reads its API key from a manifest placeholder
(`${MAPS_API_KEY}`) injected at build time. The value lives in
`android/key.properties`, which is **gitignored**.

1. Copy the template:

   ```
   cp android/key.properties.example android/key.properties
   ```

2. Edit `android/key.properties` and replace the placeholder with your key:

   ```
   MAPS_API_KEY=AIzaSy...
   ```

3. Rebuild. If `MAPS_API_KEY` is missing the build still succeeds, but the
   in-app map surface will fail to render with no crash.

### Google Cloud restrictions

Restrict the key in Google Cloud Console:
- **Application restriction**: Android apps → package `com.example.safelink`
  + your debug/release SHA-1 fingerprints.
- **API restriction**: "Maps SDK for Android" only.

Never put the key in source files, comments, dialog messages, or test fixtures.
