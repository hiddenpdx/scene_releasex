defmodule SceneReleasex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :scene_releasex,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/hiddenpdx/scene_releasex",
      name: "SceneReleasex"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler_precompiled, "~> 0.8"},
      {:rustler, "~> 0.35", runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A Rust-powered library for parsing scene release names into structured data
    """
  end

  defp package do
    [
      maintainers: ["Scene Release Community"],
      licenses: ["WTFPL"],
      links: %{"GitHub" => "https://github.com/hiddenpdx/scene_releasex"},
      files: ["lib", "mix.exs", "README*", "native/scene_releasex_nif/src", "native/scene_releasex_nif/.cargo", "native/scene_releasex_nif/README*", "native/scene_releasex_nif/Cargo*", "checksum-*.exs"]
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "SceneReleasex",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/scene_releasex",
      source_url: "https://github.com/hiddenpdx/scene_releasex",
      extras: [
        "README.md"
      ]
    ]
  end
end
