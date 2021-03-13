defmodule Checksum.Logic do
  require Integer

  def checksum_state_pid(id) do
    {:via, Registry, {ChecksumRegistry, id}}
  end

  def checksum(numbers), do: checksum(Enum.with_index(numbers, 1), 0, 0)

  def checksum([], odd_result, even_result) do
    checksum = rem((odd_result * 3) + even_result, 10)
    if checksum == 0,
      do: checksum,
      else: 10 - checksum
  end

  def checksum([{number, pos} | rest], odd_result, even_result) do
    if Integer.is_odd(pos),
      do: checksum(rest, odd_result + number, even_result),
      else: checksum(rest, odd_result, even_result + number)
  end
end
