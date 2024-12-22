Code.require_file("utilities.ex", "./src")

:ets.new(:my_secret_test, [:set, :named_table])

defmodule Funcs do
  def find(a_x_move, b_x_move, res_x, a_y_move, b_y_move, res_y) do
    a = div((res_y*b_x_move-res_x*b_y_move),(b_x_move*a_y_move-a_x_move*b_y_move))
    left_x = res_x - a * a_x_move
    left_y = res_y - a * a_y_move

    cond do
      left_x < 0 || left_y < 0 -> :not_found
      true ->
        if (rem(left_x, b_x_move) == 0) do
          b = div(left_x, b_x_move)
          if (b*b_y_move == left_y) do
            %{:a => a, :b => b}
          else
           :not_found
          end
        else
          :not_found
        end
    end
  end
end

start = System.os_time(:millisecond)

input = File.read!("input/day13.txt")

things = input
|> String.split("\n\n")
|> Enum.map(fn line ->
  [a_text, b_text, result_text] = line |> String.split("\n")
  #Button A: X+94, Y+34
  [_,a_x, a_y] = Regex.run(~r/.*X\+(\d+).*Y\+(\d+).*/, a_text)
  [_,b_x, b_y] = Regex.run(~r/.*X\+(\d+).*Y\+(\d+).*/, b_text)

  #Prize: X=8400, Y=5400
  [_,p_x,p_y] = Regex.run(~r/.*X=(\d+).*Y=(\d+).*/, result_text)

  {
    {String.to_integer(a_x),String.to_integer(a_y)},
    {String.to_integer(b_x),String.to_integer(b_y)},
    {String.to_integer(p_x),String.to_integer(p_y)}
  }
end)

things
|> Enum.with_index()
|> Enum.map(fn {{{a_x,a_y},{b_x,b_y},{p_x,p_y}}, _i} ->
  found = Funcs.find(a_x, b_x, p_x, a_y, b_y, p_y)

  if (found == :not_found) do
    0
  else
    found[:a] * 3 + found[:b]
  end
end)
|> Enum.sum()
|> IO.inspect()

things
|> Enum.with_index()
|> Enum.map(fn {{{a_x,a_y},{b_x,b_y},{p_x,p_y}}, _i} ->
  found = Funcs.find(a_x, b_x, p_x+10000000000000, a_y, b_y, p_y+10000000000000)

  if (found == :not_found) do
    0
  else
    found[:a] * 3 + found[:b]
  end
end)
|> Enum.sum()
|> IO.inspect()

IO.puts(System.os_time(:millisecond) - start)
