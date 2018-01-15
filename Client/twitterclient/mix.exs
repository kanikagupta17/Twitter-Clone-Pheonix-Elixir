defmodule Twitterclient.Mixfile do
  use Mix.Project

  def project do
    [
      app: :twitterclient,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def escript do
    [main_module: Twitterclient]
  end


  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_gen_socket_client, "~> 2.0.0"},
      {:websocket_client, "~> 1.2"},
      {:poison, "~> 2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
