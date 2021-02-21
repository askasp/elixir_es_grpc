defmodule ElixirEsGrpc.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_es_grpc,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirEsGrpc.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    {:protobuf, "~> 0.7.1"},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},      # {:dep_from_hexpm, "~> 0.3.0"},
    {:grpc, github: "elixir-grpc/grpc"},
    { :uuid, "~> 1.1" },
    {:jason, "~> 1.2"}      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
