# Changelog for v1.x

## v1.0.0 (2020-4-26)

### Enhancements

  * Removed custom error structs in favor of ones from `Ecto.Repo`
  * Updated documentation to clarify purpose / function of library more clearly

### Bug Fixes

  * [Endon.get_or_create_by] is now appropriately wrapped in a transaction to prevent race conditions

### Deprecations

  * [Endon.first] and [Endon.last] both have new function signatures.
