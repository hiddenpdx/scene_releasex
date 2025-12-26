# Publishing SceneReleasex

This guide documents the release process for SceneReleasex.

## Prerequisites

1. Access to push to the `main` branch
2. Permission to create GitHub releases
3. Rust toolchain installed (for local testing)

## Release Process

### 1. Update Version

Update the version in `mix.exs`:

```elixir
@version "0.1.0"  # Update this to the new version
```

### 2. Update Cargo.toml

Update the version in `native/scene_releasex_nif/Cargo.toml`:

```toml
[package]
name = "scene_releasex_nif"
version = "0.1.0"  # Must match mix.exs version
```

### 3. Commit Changes

```bash
git add mix.exs native/scene_releasex_nif/Cargo.toml
git commit -m "Bump version to 0.1.0"
```

### 4. Create Git Tag

The tag must be `v` prepended to the Mix project version:

```bash
git tag v0.1.0
git push --tags
```

### 5. Wait for GitHub Actions

The release workflow will automatically:
1. Build NIFs for all supported targets
2. Upload artifacts to the GitHub release
3. This process may take 10-20 minutes

### 6. Download Precompiled NIFs (Optional)

For local testing or verification:

```bash
mix rustler_precompiled.download SceneReleasex --all
```

### 7. Publish to Hex.pm (Optional)

If you want to publish to Hex:

```bash
mix hex.publish
```

Make sure to include the correct files in the package.

## Supported Targets

The following targets are built and uploaded to GitHub Releases:

- `aarch64-unknown-linux-gnu`
- `aarch64-unknown-linux-musl`
- `aarch64-apple-darwin`
- `arm-unknown-linux-gnueabihf`
- `riscv64gc-unknown-linux-gnu`
- `x86_64-apple-darwin`
- `x86_64-unknown-linux-gnu`
- `x86_64-unknown-linux-musl`
- `x86_64-pc-windows-gnu`
- `x86_64-pc-windows-msvc`

## Local Development

### Building from Source

To force a local build instead of using precompiled NIFs:

```bash
FORCE_SCENE_RELEASEX_BUILD=true mix deps.compile
```

### Testing

```bash
mix test
```

### Adding New Targets

To add a new target:

1. Update `.github/workflows/release.yml` to include the new target in the matrix
2. Update `mix.exs` if you want to change the default targets
3. Test the build locally if possible
