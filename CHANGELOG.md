# Changelog for v1.x

## v1.0.1 (2020-10-15)

### Bug Fixes

 * `Kernel.get_in/2` was failing on any module that used Endon due to overriding `fetch/2`, this is now fixed

## v1.0.0 (2020-4-26)

### Enhancements

  * Removed custom error structs in favor of ones from `Ecto.Repo`
  * Updated documentation to clarify purpose / function of library more clearly

### Bug Fixes

  * [Endon.get_or_create_by] is now appropriately wrapped in a transaction to prevent race conditions

### Deprecations

  * [Endon.first] and [Endon.last] both have new function signatures.
