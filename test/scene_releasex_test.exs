defmodule SceneReleasexTest do
  use ExUnit.Case
  doctest SceneReleasex

  describe "parse/2" do
    test "parses TV show with standard format" do
      {:ok, result} = SceneReleasex.parse("tv", "Arrow (2012) - S05E04 - Penance [Bluray-1080p Remux][DTS-HD MA 5.1][AVC]-EPSiLON")

      assert result["title"] == "Arrow"
      assert result["year"] == 2012
      assert result["season"] == 5
      assert result["episode"] == 4
      assert result["title_extra"] == "Penance"
      assert result["source"] == "Remux"
      assert result["resolution"] == "1080p"
      assert result["audio"] == "DTS-HD MA 5.1"
      assert result["format"] == "AVC"
      assert result["group"] == "EPSiLON"
      assert result["type"] == "tv"
    end

    test "parses movie with standard format" do
      {:ok, result} = SceneReleasex.parse("movie", "The.Matrix.1999.1080p.BluRay.x264-GROUP")

      assert result["title"] == "The Matrix"
      assert result["year"] == 1999
      assert result["resolution"] == "1080p"
      assert result["source"] == "BluRay"
      assert result["format"] == "x264"
      assert result["group"] == "GROUP"
      assert result["type"] == "movie"
    end

    test "parses TV show with episode range" do
      {:ok, result} = SceneReleasex.parse("tv", "Stargate Atlantis (2004) - S01E01-E02 - Rising [Bluray-1080p Remux][DTS-HD MA 5.1][AVC]-NOGRP")

      assert result["title"] == "Stargate Atlantis"
      assert result["year"] == 2004
      assert result["season"] == 1
      assert result["episode"] == nil
      assert result["episodes"] == [1, 2]
      assert result["title_extra"] == "Rising"
      assert result["type"] == "tv"
    end

    test "parses TV show with alternative season/episode format" do
      {:ok, result} = SceneReleasex.parse("tv", "Show.1x01.720p.HDTV-GROUP")

      assert result["title"] == "Show"
      assert result["season"] == 1
      assert result["episode"] == 1
      assert result["resolution"] == "720p"
      assert result["source"] == "HDTV"
    end

    test "parses movie with HDR format" do
      {:ok, result} = SceneReleasex.parse("movie", "A Nightmare on Elm Street Part 2 Freddys Revenge (1985) {tmdb-10014} [Bluray-2160p][HDR10][AC3 2.0][h265]-NERO")

      assert result["title"] == "A Nightmare on Elm Street Part 2 Freddys Revenge"
      assert result["year"] == 1985
      assert result["tmdb_id"] == "10014"
      assert result["resolution"] == "2160p"
      assert result["source"] == "BluRay"
      assert result["hdr"] == "HDR10"
      assert result["audio"] == "AC3 2.0"
      assert result["format"] == "h265"
      assert result["group"] == "NERO"
    end

    test "parses movie with DV HDR format" do
      {:ok, result} = SceneReleasex.parse("movie", "The Movie Title 2010 MA WEBDL-2160p TrueHD Atmos 7.1 DV HDR10Plus h265-RlsGrp")

      assert result["hdr"] == "DV HDR10Plus"
      assert result["source"] == "MA WEBDL"
      assert result["resolution"] == "2160p"
      assert result["format"] == "h265"
    end

    test "parses anime format" do
      {:ok, result} = SceneReleasex.parse("tv", "Ranma.1.2.2024.S02E11.GERMAN.ANiME.WEBRiP.x264-AVTOMAT")

      assert result["title"] == "Ranma 1 2"
      assert result["year"] == 2024
      assert result["season"] == 2
      assert result["episode"] == 11
      assert result["source"] == "WEBRip"
      assert result["format"] == "x264"
      assert "ANiME" in result["flags"]
    end

    test "parses streaming provider" do
      {:ok, result} = SceneReleasex.parse("tv", "Gransbevakarna.Sverige.S06E01.SWEDiSH.1080p.MAX.WEB-DL.H.265-VARiOUS")

      assert result["streaming_provider"] == "MAX"
      assert result["source"] == "WEB-DL"
      assert result["resolution"] == "1080p"
      assert result["format"] == "H.265"
      assert result["language"]["sv"] == "SWEDiSH"
    end

    test "parses flags" do
      {:ok, result} = SceneReleasex.parse("movie", "Movie.2023.PROPER.1080p-GROUP")

      assert "PROPER" in result["flags"]
    end

    test "parses language" do
      {:ok, result} = SceneReleasex.parse("movie", "Movie.2023.German.1080p-GROUP")

      assert result["language"]["de"] == "German"
    end

    test "parses group in brackets at end" do
      {:ok, result} = SceneReleasex.parse("tv", "Digimon Beatbreak (2025) S01E11 (1080p CR WEB-DL H264 AAC 2.0) [AnoZu]")

      assert result["group"] == "AnoZu"
      assert result["title"] == "Digimon Beatbreak"
      assert result["year"] == 2025
    end
  end

  describe "parse!/2" do
    test "returns parsed release for any input" do
      result = SceneReleasex.parse!("invalid", "not a release name")
      assert is_map(result)
      assert result["type"] == "invalid"
    end
  end

  describe "parse_series_directory/1" do
    test "parses series directory with IMDB ID" do
      {:ok, result} = SceneReleasex.parse_series_directory("The Series Title! (2010) {imdb-tt1520211}")

      assert result["title"] == "The Series Title!"
      assert result["year"] == 2010
      assert result["imdb_id"] == "tt1520211"
      assert result["type"] == "series"
    end

    test "parses series directory with TVDB ID" do
      {:ok, result} = SceneReleasex.parse_series_directory("The Series Title! (2010) {tvdb-79169}")

      assert result["tvdb_id"] == "79169"
    end

    test "parses series directory with bracket format" do
      {:ok, result} = SceneReleasex.parse_series_directory("The Series Title! (2010) [tvdb-1520211]")

      assert result["tvdb_id"] == "1520211"
    end
  end

  describe "parse_movie_directory/1" do
    test "parses movie directory" do
      {:ok, result} = SceneReleasex.parse_movie_directory("The Movie Title (2010)")

      assert result["title"] == "The Movie Title"
      assert result["year"] == 2010
      assert result["type"] == "movie"
    end

    test "parses movie directory with TMDB ID" do
      {:ok, result} = SceneReleasex.parse_movie_directory("The Movie Title (2010) {tmdb-123456}")

      assert result["tmdb_id"] == "123456"
    end

    test "parses movie directory with IMDB ID" do
      {:ok, result} = SceneReleasex.parse_movie_directory("The Movie Title (2010) {imdb-tt1520211}")

      assert result["imdb_id"] == "tt1520211"
    end
  end

  describe "parse_season_directory/1" do
    test "parses season directory with leading zeros" do
      {:ok, season} = SceneReleasex.parse_season_directory("Season 01")
      assert season == 1
    end

    test "parses season directory without leading zeros" do
      {:ok, season} = SceneReleasex.parse_season_directory("Season 10")
      assert season == 10
    end

    test "returns error for non-season directory" do
      {:error, reason} = SceneReleasex.parse_season_directory("Movies")
      assert reason == "no season found"
    end
  end

  describe "parse_season_directory!/1" do
    test "returns season number or raises" do
      assert_raise RuntimeError, fn ->
        SceneReleasex.parse_season_directory!("Movies")
      end
    end
  end

  describe "parse_path/2" do
    test "parses TV show path with season directory" do
      {:ok, result} = SceneReleasex.parse_path("tv", "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv")

      assert result["season"] == 1
      assert result["full_path"] == "/tv/Show (2010)/Season 01/Show - S01E01 - Pilot.mkv"
      assert result["file"]["title"] == "Show"
      assert result["file"]["season"] == 1
      assert result["file"]["episode"] == 1
      assert result["file"]["title_extra"] == "Pilot"
      assert result["directory"]["title"] == "Show"
      assert result["directory"]["year"] == 2010
    end

    test "parses TV show path without season directory" do
      {:ok, result} = SceneReleasex.parse_path("tv", "/tv/Show (2010)/Show - S01E01 - Pilot.mkv")

      assert result["season"] == nil
      assert result["file"]["season"] == 1
      assert result["file"]["episode"] == 1
    end

    test "parses movie path" do
      {:ok, result} = SceneReleasex.parse_path("movie", "/movies/Matrix, The (1999)/Matrix, The (1999) [1080p].mkv")

      assert result["season"] == nil
      assert result["file"]["title"] == "Matrix, The"
      assert result["file"]["year"] == 1999
      assert result["directory"]["title"] == "Matrix, The"
      assert result["directory"]["year"] == 1999
    end

    test "parses path with episode range" do
      {:ok, result} = SceneReleasex.parse_path("tv", "/tv/Show (2010)/Season 01/Show - S01E01-E03 - Multi.mkv")

      assert result["season"] == 1
      assert result["file"]["season"] == 1
      assert result["file"]["episode"] == nil
      assert result["file"]["episodes"] == [1, 2, 3]
    end

    test "parses path with TMDB ID" do
      {:ok, result} = SceneReleasex.parse_path("movie", "/movies/Vanilla Sky (2001) {tmdb-1903}/Vanilla Sky (2001) {tmdb-1903} [Remux-2160p].mkv")

      assert result["directory"]["tmdb_id"] == "1903"
      assert result["file"]["tmdb_id"] == "1903"
    end

    test "parses path with IMDB ID" do
      {:ok, result} = SceneReleasex.parse_path("movie", "/movies/Matrix (1999) {imdb-tt0133093}/Matrix (1999) [Bluray-1080p].mkv")

      # Note: IMDB ID in directory path is extracted from directory name
      assert result["directory"]["title"] == "Matrix"
      assert result["directory"]["imdb_id"] == "tt0133093"
      #assert result["file"]["title"] == "Matrix"
    end

    test "parses path with edition" do
      {:ok, result} = SceneReleasex.parse_path("movie", "/movies/Matrix (1999)/Matrix (1999) {edition-Director's Cut} [Bluray-1080p].mkv")

      assert result["file"]["edition"] == "Director's Cut"
    end

    test "parses path with streaming provider" do
      {:ok, result} = SceneReleasex.parse_path("tv", "/tv/Show (2020)/Season 1/Show - S01E01 [AMZN WEBDL-1080p].mkv")

      assert result["file"]["streaming_provider"] == "AMZN"
      assert result["file"]["source"] == "WEBDL"
    end

    test "handles Windows paths" do
      {:ok, result} = SceneReleasex.parse_path("tv", "C:\\tv\\Show (2020)\\Season 01\\Show - S01E01.mkv")

      assert result["season"] == 1
    end
  end

  describe "error handling" do
    test "handles empty input gracefully" do
      {:ok, result} = SceneReleasex.parse("tv", "")
      assert result["release"] == ""
      assert result["title"] == ""
      assert is_map(result)
    end
  end
end
