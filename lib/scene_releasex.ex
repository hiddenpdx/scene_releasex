defmodule SceneReleasex do
  @moduledoc """
  A Rust-powered library for parsing scene release names into structured data.

  This library provides functions to parse scene release names for TV shows and movies,
  extracting information such as title, season, episode, group, resolution, audio format,
  and more. It wraps the `scene-release` Rust crate using Rustler for high-performance
  native code execution.

  ## Installation

  Add `scene_releasex` to your `mix.exs` dependencies:

      def deps do
        [
          {:scene_releasex, "~> 0.1.0"}
        ]
      end

  Pre-compiled NIF binaries are automatically downloaded from GitHub Releases for
  common platforms. To build from source instead, set the environment variable:

      FORCE_SCENE_RELEASEX_BUILD=true mix deps.compile

  ## Usage

  ### Parsing TV Show Releases

      iex> {:ok, result} = SceneReleasex.parse("tv", "Arrow (2012) - S05E04 - Penance [Bluray-1080p Remux][DTS-HD MA 5.1][AVC]-EPSiLON")
      iex> result["title"]
      "Arrow"
      iex> result["year"]
      2012
      iex> result["season"]
      5
      iex> result["episode"]
      4

  ### Parsing Movie Releases

      iex> {:ok, result} = SceneReleasex.parse("movie", "The.Matrix.1999.1080p.BluRay.x264-GROUP")
      iex> result["title"]
      "The Matrix"
      iex> result["year"]
      1999
      iex> result["resolution"]
      "1080p"

  ### Parsing File Paths

      iex> {:ok, result} = SceneReleasex.parse_path("tv", "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv")
      iex> result["season"]
      1
      iex> result["file"]["title"]
      "Show"
      iex> result["directory"]["title"]
      "Show"
      iex> result["full_path"]
      "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv"

  ## Supported Formats

  - TV Shows: S01E01, 1x01, Season XX Episode YY, date-based (2013-10-30), episode-only (E01E02, E780)
  - Movies: Standard scene releases, directory-based with metadata
  - Video Sources: BluRay, WEB-DL, HDTV, DVDRip, Remux, etc.
  - Audio: AAC, AC3, DTS, TrueHD, DDP, EAC3 Atmos
  - HDR: HDR10, DV HDR10, HDR10Plus, DV HDR10Plus
  - Streaming Providers: Netflix, Amazon Prime, Disney+, HBO Max, Crunchyroll, and many more
  - Languages: English, German, French, Japanese, Chinese, Korean, and more
  - Flags: PROPER, REPACK, READNFO, 10bit, 3D, IMAX, REMASTERED, etc.
  """

  source_url = Mix.Project.config()[:source_url]
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :scene_releasex,
    base_url: "#{source_url}/releases/download/v#{version}",
    force_build: System.get_env("FORCE_SCENE_RELEASEX_BUILD") in ["1", "true"],
    targets: RustlerPrecompiled.Config.default_targets(),
    version: version,
    crate: "scene_releasex_nif"

  @type release_type :: String.t()
  @type parsed_release :: %{
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

  @type path_info :: %{
    directory: parsed_release() | nil,
    season: non_neg_integer() | nil,
    file: parsed_release(),
    full_path: String.t()
  }

  @spec nif_parse(String.t(), String.t()) :: term
  defp nif_parse(_type, _release_name), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_parse_path(String.t(), String.t()) :: term
  defp nif_parse_path(_type, _file_path), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_parse_series_directory(String.t()) :: term
  defp nif_parse_series_directory(_directory_name), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_parse_movie_directory(String.t()) :: term
  defp nif_parse_movie_directory(_directory_name), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_parse_season_directory(String.t()) :: term
  defp nif_parse_season_directory(_directory_name), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Parse a scene release name.

  ## Arguments

    - `type` - The type of release: "tv", "movie", or "series"
    - `release_name` - The release name to parse

  ## Returns

    - `{:ok, parsed_release}` on success
    - `{:error, reason}` on failure

  ## Examples

      iex> {:ok, result} = SceneReleasex.parse("tv", "Arrow (2012) - S05E04 - Penance [Bluray-1080p Remux][DTS-HD MA 5.1][AVC]-EPSiLON")
      iex> result["title"]
      "Arrow"
      iex> result["season"]
      5
      iex> result["episode"]
      4

      iex> {:ok, result} = SceneReleasex.parse("movie", "The.Matrix.1999.1080p.BluRay.x264-GROUP")
      iex> result["title"]
      "The Matrix"
      iex> result["year"]
      1999
  """
  @spec parse(release_type(), String.t()) :: {:ok, parsed_release()} | {:error, String.t()}
  def parse(type, release_name) do
    {:ok, parse!(type, release_name)}
  rescue
    e -> {:error, error_string(e)}
  end

  @doc """
  Parse a scene release name, raising on error.

  ## Arguments

    - `type` - The type of release: "tv", "movie", or "series"
    - `release_name` - The release name to parse

  ## Returns

    - `parsed_release` on success
    - Raises `RuntimeError` on failure

  ## Examples

      iex> result = SceneReleasex.parse!("tv", "Arrow (2012) - S05E04 - Penance [Bluray-1080p Remux][DTS-HD MA 5.1][AVC]-EPSiLON")
      iex> result["title"]
      "Arrow"
      iex> result["season"]
      5
      iex> result["episode"]
      4
  """
  @spec parse!(release_type(), String.t()) :: parsed_release()
  def parse!(type, release_name) do
    nif_parse(type, release_name)
  end

  @doc """
  Parse a file path, extracting directory, season (if TV), and file information.

  ## Arguments

    - `type` - The type of release: "tv" or "movie"
    - `file_path` - The file path to parse

  ## Returns

    - `{:ok, path_info}` on success
    - `{:error, reason}` on failure

  ## Examples

      iex> {:ok, result} = SceneReleasex.parse_path("tv", "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv")
      iex> result["season"]
      1

      iex> {:ok, result} = SceneReleasex.parse_path("movie", "/movies/Matrix (1999)/Matrix, The (1999) [1080p].mkv")
      iex> result["file"]["title"]
      "Matrix, The"
  """
  @spec parse_path(release_type(), String.t()) :: {:ok, path_info()} | {:error, String.t()}
  def parse_path(type, file_path) do
    {:ok, parse_path!(type, file_path)}
  rescue
    e -> {:error, error_string(e)}
  end

  @doc """
  Parse a file path, raising on error.

  ## Arguments

    - `type` - The type of release: "tv" or "movie"
    - `file_path` - The file path to parse

  ## Returns

    - `path_info` on success
    - Raises `RuntimeError` on failure

  ## Examples

      iex> result = SceneReleasex.parse_path!("tv", "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv")
      iex> result["season"]
      1
  """
  @spec parse_path!(release_type(), String.t()) :: path_info()
  def parse_path!(type, file_path) do
    nif_parse_path(type, file_path)
  end

  @doc """
  Parse a series directory name.

  Extracts title, year, and metadata IDs (TMDB, TVDB, IMDB) from a series directory name.

  ## Arguments

    - `directory_name` - The directory name to parse (e.g., "The Series Title! (2010) {imdb-tt1520211}")

  ## Returns

    - `{:ok, parsed_release}` on success
    - `{:error, reason}` on failure

  ## Examples

      iex> {:ok, result} = SceneReleasex.parse_series_directory("The Series Title! (2010) {imdb-tt1520211}")
      iex> result["title"]
      "The Series Title!"
      iex> result["year"]
      2010
      iex> result["imdb_id"]
      "tt1520211"
  """
  @spec parse_series_directory(String.t()) :: {:ok, parsed_release()} | {:error, String.t()}
  def parse_series_directory(directory_name) do
    {:ok, parse_series_directory!(directory_name)}
  rescue
    e -> {:error, error_string(e)}
  end

  @doc """
  Parse a series directory name, raising on error.

  ## Arguments

    - `directory_name` - The directory name to parse

  ## Returns

    - `parsed_release` on success
    - Raises `RuntimeError` on failure

  ## Examples

      iex> result = SceneReleasex.parse_series_directory!("The Series Title! (2010) {imdb-tt1520211}")
      iex> result["title"]
      "The Series Title!"
      iex> result["year"]
      2010
  """
  @spec parse_series_directory!(String.t()) :: parsed_release()
  def parse_series_directory!(directory_name) do
    nif_parse_series_directory(directory_name)
  end

  @doc """
  Parse a movie directory name.

  Extracts title, year, and metadata IDs (TMDB, IMDB) from a movie directory name.

  ## Arguments

    - `directory_name` - The directory name to parse (e.g., "The Movie Title (2010) {tmdb-123456}")

  ## Returns

    - `{:ok, parsed_release}` on success
    - `{:error, reason}` on failure

  ## Examples

      iex> {:ok, result} = SceneReleasex.parse_movie_directory("The Movie Title (2010) {tmdb-123456}")
      iex> result["title"]
      "The Movie Title"
      iex> result["year"]
      2010
      iex> result["tmdb_id"]
      "123456"
  """
  @spec parse_movie_directory(String.t()) :: {:ok, parsed_release()} | {:error, String.t()}
  def parse_movie_directory(directory_name) do
    {:ok, parse_movie_directory!(directory_name)}
  rescue
    e -> {:error, error_string(e)}
  end

  @doc """
  Parse a movie directory name, raising on error.

  ## Arguments

    - `directory_name` - The directory name to parse

  ## Returns

    - `parsed_release` on success
    - Raises `RuntimeError` on failure

  ## Examples

      iex> result = SceneReleasex.parse_movie_directory!("The Movie Title (2010) {tmdb-123456}")
      iex> result["title"]
      "The Movie Title"
      iex> result["year"]
      2010
      iex> result["tmdb_id"]
      "123456"
  """
  @spec parse_movie_directory!(String.t()) :: parsed_release()
  def parse_movie_directory!(directory_name) do
    nif_parse_movie_directory(directory_name)
  end

  @doc """
  Parse a season directory name.

  Extracts the season number from a directory name like "Season 01" or "Season 1".

  ## Arguments

    - `directory_name` - The directory name to parse (e.g., "Season 01")

  ## Returns

    - `{:ok, season_number}` if season is found
    - `{:error, "no season found"}` if no season pattern is detected

  ## Examples

      iex> SceneReleasex.parse_season_directory("Season 01")
      {:ok, 1}

      iex> SceneReleasex.parse_season_directory("Season 10")
      {:ok, 10}

      iex> SceneReleasex.parse_season_directory("Movies")
      {:error, "no season found"}
  """
  @spec parse_season_directory(String.t()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def parse_season_directory(directory_name) do
    result = nif_parse_season_directory(directory_name)

    case result do
      nil -> {:error, "no season found"}
      season -> {:ok, season}
    end
  rescue
    e -> {:error, error_string(e)}
  end

  @doc """
  Parse a season directory name, raising on error.

  ## Arguments

    - `directory_name` - The directory name to parse

  ## Returns

    - `season_number` on success
    - Raises `RuntimeError` on failure

  ## Examples

      iex> SceneReleasex.parse_season_directory!("Season 01")
      1
  """
  @spec parse_season_directory!(String.t()) :: non_neg_integer()
  def parse_season_directory!(directory_name) do
    result = nif_parse_season_directory(directory_name)

    case result do
      nil -> raise "no season found in directory name"
      season -> season
    end
  end

  defp error_string(%ErlangError{original: err}), do: error_string(err)
  defp error_string(err) when is_exception(err), do: Exception.message(err)
  defp error_string(err), do: to_string(err)
end
