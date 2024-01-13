defmodule Mix.Tasks.Deps.Rm do
  @moduledoc """
   Quickly removes a dependency and cleans up the project.

  ## Examples
      mix deps.rm cowboy
  """

  @mixfile "mix.exs"

  use Mix.Task

  @shortdoc "Removes a dependency from file"
  def run(args) do
    {_, packages, _} = OptionParser.parse(args, strict: [])

    name = List.first(packages)
    file = File.read!(@mixfile) |> String.split("\n")

    idx = file |> Enum.find_index(fn x -> String.contains?(x, name) end)

    if idx == nil do
      stop_and_exit("Package: #{name} not found in #{@mixfile}")
    end

    content = file |> List.delete_at(idx) |> Enum.join("\n")
    File.write!(@mixfile, content)
    IO.puts("Package: #{name} removed")
    System.cmd("mix", ["deps.clean", "--unused"])
  end

  # Helpers
  defp stop_and_exit(message) do
    IO.puts(message)
    System.halt(0)
  end
end
