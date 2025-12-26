# SceneReleasex

A Rust-powered library for parsing scene release names into structured data.

## Installation

Add `scene_releasex` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:scene_releasex, "~> 0.1.0"}
  ]
end
```

Pre-compiled NIF binaries are automatically downloaded from GitHub Releases for common platforms. To build from source instead, set the environment variable:

```bash
FORCE_SCENE_RELEASEX_BUILD=true mix deps.compile
```

## Usage

### Parsing TV Show Releases

```elixir
iex> SceneReleasex.parse("tv", "Arrow (2012) - S05E04 - Penance [Bluray-1080p Remux][DTS-HD MA 5.1][AVC]-EPSiLON")
{:ok, %{
  title: "Arrow",
  year: 2012,
  season: 5,
  episode: 4,
  episode_title: "Penance",
  source: "Remux",
  resolution: "1080p",
  audio: "DTS-HD MA 5.1",
  format: "AVC",
  group: "EPSiLON",
  type: "tv"
}}
```

### Parsing Movie Releases

```elixir
iex> SceneReleasex.parse("movie", "The.Matrix.1999.1080p.BluRay.x264-GROUP")
{:ok, %{
  title: "The Matrix",
  year: 1999,
  resolution: "1080p",
  source: "BluRay",
  format: "x264",
  group: "GROUP",
  type: "movie"
}}
```

### Parsing File Paths

```elixir
iex> SceneReleasex.parse_path("tv", "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv")
{:ok, %{
  season: 1,
  file: %{...},
  directory: %{...},
  full_path: "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv"
}}
```

## Supported Formats

### TV Shows
- Standard: `S01E01`, `1x01`, `Season XX Episode YY`
- Date-based: `2013-10-30`
- Episode-only: `E01E02`, `E780`

### Movies
- Standard scene releases
- Directory-based with metadata

### Video Sources
- BluRay, WEB-DL, HDTV, DVDRip, Remux, etc.

### Audio
- AAC, AC3, DTS, TrueHD, DDP, EAC3 Atmos

### HDR
- HDR10, DV HDR10, HDR10Plus, DV HDR10Plus

### Streaming Providers
- Netflix (NF), Amazon Prime (AMZN), Disney+ (DSNP), HBO Max (HMAX), Crunchyroll (CR), and many more

### Languages
- English, German, French, Japanese, Chinese, Korean, and more

### Flags
- PROPER, REPACK, READNFO, 10bit, 3D, IMAX, REMASTERED, etc.

## API Reference

### parse(type, release_name)
Parse a scene release name.

### parse!(type, release_name)
Parse a scene release name, raising on error.

### parse_path(type, file_path)
Parse a file path, extracting directory, season (if TV), and file information.

### parse_path!(type, file_path)
Parse a file path, raising on error.

### parse_series_directory(directory_name)
Parse a series directory name.

### parse_movie_directory(directory_name)
Parse a movie directory name.

### parse_season_directory(directory_name)
Parse a season directory name.

## Return Values

### Parsed Release Map

```elixir
%{
  release: String.t(),
  title: String.t(),
  title_extra: String.t(),
  group: String.t(),
  year: non_neg_integer() | nil,
  date: String.t() | nil,
  season: non_neg_integer() | nil,
  episode: non_neg_integer() | nil,
  episodes: [non_neg_integer()],
  disc: non_neg_integer() | nil,
  flags: [String.t()],
  source: String.t(),
  format: String.t(),
  resolution: String.t(),
  audio: String.t(),
  device: String.t(),
  os: String.t(),
  version: String.t(),
  language: %{String.t() => String.t()},
  tmdb_id: String.t() | nil,
  tvdb_id: String.t() | nil,
  imdb_id: String.t() | nil,
  edition: String.t() | nil,
  hdr: String.t(),
  streaming_provider: String.t(),
  type: String.t()
}
```

### Path Info Map

```elixir
%{
  directory: parsed_release() | nil,
  season: non_neg_integer() | nil,
  file: parsed_release(),
  full_path: String.t()
}
```

## License

This project is licensed under the WTFPL - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [scene-release](https://github.com/hiddenpdx/scene-release) - The Rust library this project wraps
- [Rustler](https://github.com/rusterlium/rustler) - For making NIFs in Elixir easy
- [rustler_precompiled](https://github.com/philss/rustler_precompiled) - For pre-compiled NIF support
