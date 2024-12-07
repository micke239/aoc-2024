Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def test_operators(result, input, curr) when input == [] do
    result == curr
  end
  def test_operators(result, _, curr) when curr > result do
    false
  end
  def test_operators(result, [next | rest], curr) do
    cond do
      test_operators(result, rest, curr * next) -> true
      test_operators(result, rest, String.to_integer("#{curr}#{next}")) -> true
      test_operators(result, rest, curr + next) -> true
      true -> false
    end
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day7.txt")

equations = input
|> String.split("\n")
|> Enum.map(fn line ->
  parts = String.split(line, ":")
  numbers = parts
    |> Enum.at(1)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&(String.to_integer(&1)))

  {String.to_integer(Enum.at(parts, 0)), numbers}
end)

equations
|> Enum.filter(fn {result, [first | rest]} ->
  Funcs.test_operators(result, rest, first)
end)
|> Enum.map(fn {res, _} -> res end)
|> Enum.sum()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
