defmodule Mix.Tasks.Deps.Add do
  @moduledoc """
   Quickly adds a dependency via hex.\n
   Optional flags are version and git for a more granular control. 

  ## Examples
      mix deps.add cowboy
      mix deps.add cowboy --version=1.0.0
      mix deps.add cowboy --git=https://github.com/elixir-lang/cowboy
  """

  @options [version: :string, git: :string]
  @mixfile "mix.exs"

  use Mix.Task

  @shortdoc "Adds a dependency via hex"
  def run(args) do
    {opts, packages, _} = OptionParser.parse(args, strict: @options)

    name = List.first(packages)
    file = parse_mixfile(name)

    verify_version(opts[:version])
    verify_git(opts[:git])

    package =
      parse_package(name)
      |> override_version(opts[:version])
      |> override_git(opts[:git])

    idx = find_deps_index(file)
    indent = find_deps_indent(file, idx)

    content =
      file
      |> List.insert_at(idx, format_output(package, indent))
      |> Enum.join("\n")

    File.write!(@mixfile, content)
    System.cmd("mix", ["deps.get"])
    System.cmd("mix", ["compile"])
    IO.puts("Package: #{package} added")
  end

  # Top Level Functions
  defp parse_mixfile(package_name) do
    File.read!(@mixfile)
    |> String.split("\n")
    |> package_added?(package_name)
  end

  defp parse_package(name) do
    System.cmd("mix", ["hex.info", name])
    |> package_exists?
    |> elem(0)
    |> String.split("\n", trim: true)
    |> Enum.filter(&String.contains?(&1, "Config"))
    |> Enum.at(0)
    |> (&Regex.run(~r/\{.+\}/, &1)).()
    |> Enum.at(0)
  end

  defp find_deps_index(file) do
    file
    |> Enum.find_index(fn x -> String.contains?(x, "defp deps do") end)
    |> (fn x -> x + 2 end).()
  end

  defp find_deps_indent(file, idx) do
    file
    |> Enum.at(idx)
    |> (fn x -> Regex.run(~r/^\s+/, x) end).()
    |> Enum.at(0)
    |> String.length()
  end

  # Helpers
  defp verify_version(version) when not is_nil(version) do
    if !Regex.match?(~r/[0-9]+\.[0-9]+\.[0-9]+/, to_string(version)) do
      stop_and_exit("Invalid version. Example: xx.xx.x")
    end
  end

  defp verify_version(nil), do: nil

  defp verify_git(git) when not is_nil(git) do
    if !Regex.match?(~r/.git$/, to_string(git)) do
      stop_and_exit("Invalid git link. Example: https://github.com/elixir-lang/my_dep.git")
    end
  end

  defp verify_git(nil), do: nil

  defp stop_and_exit(message) do
    IO.puts(message)
    System.halt(0)
  end

  defp package_added?(file, package) do
    if file |> to_string |> String.contains?(package) do
      stop_and_exit("Package already in mix file")
    end

    file
  end

  defp package_exists?(info) do
    if info |> elem(1) == 1 do
      System.halt(0)
    end

    info
  end

  defp override_version(package, nil), do: package

  defp override_version(package, version) do
    String.replace(package, ~r/~>.*\d/, "~> #{version}")
  end

  defp override_git(package, nil), do: package

  defp override_git(package, git) do
    String.replace(package, "}", ", git: \"#{git}\"}")
  end

  defp format_output(output, indent) do
    String.duplicate(" ", indent) <> output
  end
end
