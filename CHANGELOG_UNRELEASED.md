## Unreleased

### Changed

- compileSdkVersion is now resolved from flutter.compileSdkVersion when available, with a fallback
  to API 36. This ensures backward compatibility across different build environments, whereas
  previously it was always hardcoded.