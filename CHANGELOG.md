# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedJotform<T>(...)` — wraps a otel_jotform call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutJotformInstrumentation()` / `Async()`.
