defmodule Funcs do

 def find_input(test, count, program, expected_output, output_length) do
  output = execute_program(0, [], %{"A" => test, "B" => 0, "C" => 0}, program)

  cond do
    (expected_output |> Enum.take(count) == output |> Enum.take(count)) ->
      if (count == output_length) do
        test
      else
        find_input(test, count+1, program,expected_output,output_length)
      end
    output_length-count < 1 -> find_input(test+1,count,program,expected_output,output_length)
    true -> find_input(test+(8**(output_length-count-1)),count,program,expected_output,output_length)
  end
 end

  def execute_program(instruction, output, registry, program) do
    if !Map.has_key?(program, instruction) do
      output
    else
      op = program[instruction]
      operand = program[instruction + 1]

      {n_instruction, n_output, n_registry} = case op do
        0 -> {instruction + 2, output, Map.put(registry, "A", div(registry["A"], 2 ** combo_operand(operand, registry)))}
        1 -> {instruction + 2, output, Map.put(registry, "B", Bitwise.bxor(registry["B"], operand))}
        2 -> {instruction + 2, output, Map.put(registry, "B", rem(combo_operand(operand, registry), 8))}
        3 -> if (registry["A"] == 0) do
          {instruction + 2, output, registry}
        else
          {operand, output, registry}
        end
        4 -> {instruction + 2, output, Map.put(registry, "B", Bitwise.bxor(registry["B"], registry["C"]))}
        5 -> {instruction + 2, [rem(combo_operand(operand, registry),8) | output], registry}
        6 -> {instruction + 2, output, Map.put(registry, "B", div(registry["A"], 2 ** combo_operand(operand, registry)))}
        7 -> {instruction + 2, output, Map.put(registry, "C", div(registry["A"], 2 ** combo_operand(operand, registry)))}
      end

      #1 -> B = B % 8
      #2 -> B = A / 2^B
      #3 -> C = A ^ B
      #4 -> A = A / 2^3
      #5 -> B = B ^ 6
      #6 -> B = B ^ C
      #7 -> >>>> B % 8

      execute_program(n_instruction, n_output, n_registry, program)
    end
  end

  def combo_operand(operand, registry) do
    case operand do
      0 -> operand
      1 -> operand
      2 -> operand
      3 -> operand
      4 -> registry["A"]
      5 -> registry["B"]
      6 -> registry["C"]
    end
  end
end

start_t = System.os_time(:millisecond)

input = File.read!("input/day17.txt")

[registry_input, program_input] = input |> String.split("\n\n")

registry = registry_input
|> String.split("\n")
|> Enum.reduce(%{}, fn line, acc ->
  [_,name, value] = Regex.run(~r/Register (.): (\d+)/, line)
  Map.put(acc, name, String.to_integer(value))
end)

program_list = program_input
|> String.split(" ")
|> Enum.at(1)
|> String.split(",")
|> Enum.map(&(String.to_integer(&1)))

program = program_list
|> Enum.with_index()
|> Enum.map(fn {x,y} -> {y,x} end)
|> Enum.into(%{})

Funcs.execute_program(0, [], registry, program)
|> Enum.reverse()
|> Enum.join(",")
|> IO.puts()

program_length = program_list |> Enum.count() |> IO.inspect()

Funcs.find_input(8**(program_length-1), 1, program, program_list |> Enum.reverse(), program_length) |> IO.inspect()

IO.puts(System.os_time(:millisecond) - start_t)
