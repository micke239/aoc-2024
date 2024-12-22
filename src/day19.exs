#Code.require_file("utilities.ex", "./src")

defmodule Funcs do
  def test_design([], "", _available, cache) do
    {cache, 1}
  end

  def test_design([], _built, _available, cache) do
    {cache, :fail}
  end

  def test_design([curr | rest], built, available, cache) do
    n_curr = "#{built}#{curr}"
    if (Map.has_key?(cache, {n_curr, rest})) do
      {cache, cache[{n_curr, rest}]}
    else
      if (!Map.has_key?(available, n_curr)) do
        {cache, :fail}
      else
        {has_exact, has_more} = available[n_curr]

        {exact_cache, exact_found} = if (has_exact) do
          test_design(rest, "", available, cache)
        else
          {cache, :fail}
        end

        {more_cache, more_found} = if (has_more) do
          test_design(rest, n_curr, available, exact_cache)
        else
          {cache, :fail}
        end

        exact_found = if (exact_found != :fail) do
          exact_found
        else
          exact_found
        end

        n_found = cond do
          exact_found == :fail && more_found == :fail -> :fail
          exact_found == :fail -> more_found
          more_found == :fail -> exact_found
          true -> more_found + exact_found
        end

        n_cache = if(has_exact) do
          Map.put(more_cache, {n_curr, rest}, n_found)
        else
          more_cache
        end


        {n_cache, n_found}
      end
    end
  end
end

start_t = System.os_time(:millisecond)

input = File.read!("input/day19.txt")

[available_input, designs_input] = input |> String.split("\n\n")

available = available_input
|> String.split(", ")
|> Enum.reduce(%{}, fn d,acc ->
  {n_acc, _} = d
  |> String.graphemes()
  |> Enum.reduce({acc, ""}, fn c, {acc, built} ->
    n_built = "#{built}#{c}"
    if (Map.has_key?(acc, n_built)) do
      {has_exact, has_more} = acc[n_built]
      {Map.put(acc, n_built, {has_exact || n_built == d, has_more || n_built != d}), n_built}
    else
      {Map.put(acc, n_built, {n_built == d, n_built != d}), n_built}
    end
  end)

  n_acc
end)

designs = designs_input
|> String.split("\n")
|> Enum.map(&(String.graphemes(&1)))

arrangement_count = designs
|> Enum.map(fn design ->
  {_, found_arrangements} = Funcs.test_design(design, "", available, %{})

  if (found_arrangements == :fail) do
    0
  else
    found_arrangements
  end
end)

arrangement_count
|> Enum.count(fn x -> x != 0 end)
|> IO.inspect()

arrangement_count
|> Enum.sum()
|> IO.inspect()


IO.puts(System.os_time(:millisecond) - start_t)
