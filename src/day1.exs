Code.require_file("utilities.ex", "./src")

start = System.os_time(:millisecond)

input = File.read!("input/day1.txt")

{firstList,secondList} = input
  |> String.split("\n")
  |> Enum.map(fn line ->
    x = line
    |> String.split(~r/\s+/)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn l2 -> l2 |> String.to_integer() end)

    {Enum.at(x, 0), Enum.at(x, 1)}
  end)
  |> Enum.unzip()

[firstList, secondList]
  |> Enum.map(&(Enum.sort(&1)))
  |> Enum.zip()
  |> Enum.map(fn {i1,i2} -> abs(i2 - i1) end)
  |> Enum.sum()
  |> IO.inspect()

secondGroup = secondList
  |> Enum.group_by(fn x -> x end)

firstList
  |> Enum.map(fn x -> x * (case secondGroup[x] do
    nil -> 0
    y -> y |> Enum.count()
  end)
end)
  |> Enum.sum()
  |> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
