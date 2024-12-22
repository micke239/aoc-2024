Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def defrag(_, _, to_count, curr_count, acc) when curr_count == to_count do
    acc
  end
  def defrag([first | input], [first2 | rest2], to_count, curr_count, acc) do
    if (first === nil) do
      defrag(input, rest2, to_count, curr_count+1, [first2 | acc])
    else
      defrag(input, [first2 | rest2], to_count, curr_count+1, [first | acc])
    end
  end

  def move_file([], _, acc) do
    acc |> Enum.reverse()
  end
  def move_file([{file1_id, file1_size} | space], {file_id, file_size}, acc) do
    cond do
      file1_id == file_id -> Enum.reverse(acc) ++ [ {file1_id, file1_size} | space]
      file1_id != nil || file1_size < file_size -> move_file(space, {file_id, file_size}, [{file1_id, file1_size} | acc])
      true ->
        added = [{nil, file1_size - file_size} | [ {file_id, file_size} | acc]] |> Enum.reverse()
        removed = space |>
          Enum.map(fn x ->
            if x == {file_id, file_size} do
              {nil, file_size}
            else
              x
            end
          end)
        added ++ removed
    end
  end
  def move_files(space, []) do
    space
  end
  def move_files(space, [file | files]) do
    move_files(move_file(space, file, []), files)
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day9.txt")

arr = input
|> String.graphemes()
|> Enum.map(&(String.to_integer(&1)))
|> Enum.with_index()
|> Enum.flat_map(fn {s, i} ->
  cond do
    s == 0 -> []
    rem(i, 2) === 0 -> 0..(s-1) |> Enum.map(fn _ -> div(i, 2) end)
    true -> 0..(s-1) |> Enum.map(fn _ -> nil end)
  end
end)

reversed_without_nil = arr |> Enum.filter(&(&1 != nil)) |> Enum.reverse()

defraged = Funcs.defrag(arr, reversed_without_nil, reversed_without_nil |> Enum.count(), 0, [])

defraged
|> Enum.reverse()
|> Enum.with_index()
|> Enum.map(fn {x,i} -> x*i end)
|> Enum.sum()
|> IO.inspect()


#### part2

arr2 = input
|> String.graphemes()
|> Enum.map(&(String.to_integer(&1)))
|> Enum.with_index()
|> Enum.map(fn {s, i} ->
  cond do
    rem(i, 2) === 0 -> {div(i,2), s}
    true -> {nil, s}
  end
end)
# |> IO.inspect()

# arr |> Enum.reverse() |> IO.inspect()

reversed_without_nil2 = arr2 |> Enum.filter(fn {x,_} -> x != nil end) |> Enum.reverse()

moved = Funcs.move_files(arr2, reversed_without_nil2)

moved
# |> IO.inspect()
|> Enum.flat_map(fn {s, i} ->
  if i == 0 do
    []
  else
    1..i |> Enum.map(fn _ -> s end)
  end
end)
# |> IO.inspect()
|> Enum.with_index()
# |> IO.inspect()
|> Enum.map(fn {x,i} ->
  if x != nil do
    x*i
  else
    0
  end
end)
|> Enum.sum()
|> IO.inspect()


IO.puts(System.os_time(:millisecond) - start)
