Code.require_file("utilities.ex", "./src")

defmodule Funcs do

end

start = System.os_time(:millisecond)

input = File.read!("input/day5.txt")

[rules | [updates | []]] = input |> String.split("\n\n")

ruleOrders = rules
|> String.split("\n")
|> Enum.map(fn s ->
  x = s |> String.split("|") |> Enum.map(&(String.to_integer(&1)))
  {Enum.at(x, 0), Enum.at(x, 1)}
end)
|> Enum.into(%MapSet{})

updates
  |> String.split("\n")
  |> Enum.map(fn s -> s |> String.split(",") |> Enum.map(&(String.to_integer(&1))) end)
  |> Enum.filter(fn row ->
    indexedRow = row |> Enum.sort(fn a, b ->
      if (MapSet.member?(ruleOrders, {b,a})) do
        false
      else
        true
      end
    end)

    indexedRow == row
  end)
  |> Enum.map(fn x -> Enum.at(x, floor(Enum.count(x)/2)) end)
  |> Enum.sum()
  |> IO.inspect()

updates
  |> String.split("\n")
  |> Enum.map(fn s -> s |> String.split(",") |> Enum.map(&(String.to_integer(&1))) end)
  |> Enum.filter(fn row ->
    indexedRow = row |> Enum.sort(fn a, b ->
      if (MapSet.member?(ruleOrders, {b,a})) do
        false
      else
        true
      end
    end)

    indexedRow != row
  end)
  |> Enum.map(fn row ->
    row |> Enum.sort(fn a, b ->
      if (MapSet.member?(ruleOrders, {b,a})) do
        false
      else
        true
      end
    end)
  end)
  |> Enum.map(fn x -> Enum.at(x, floor(Enum.count(x)/2)) end)
  |> Enum.sum()
  |> IO.inspect()



IO.puts(System.os_time(:millisecond) - start)
