defmodule Checksum.Logic do
  require Integer

  def read_command(<<"CS">>) do
    {:ok, :checksum}
  end

  def read_command(<<"C">>) do
    {:ok, :clear}
  end

  def read_command(<<"A", number_str::binary>>) do
    only_digits = Regex.replace(~r/\D/, number_str, "")

    case Integer.parse(only_digits) do
      {number, _} -> {:ok, {:add, number}}
      :error -> {:error, :not_a_number}
    end
  end

  def read_command(_) do
    {:error, :unknown_command}
  end

  def checksum_id(nil), do: {:via, Registry, {ChecksumRegistry, "default-checksum"}}
  def checksum_id(id), do: {:via, Registry, {ChecksumRegistry, id}}

  def checksum(numbers), do: checksum(Enum.with_index(numbers, 1), 0, 0)

  def checksum([], odd_result, even_result) do
    checksum = rem(odd_result * 3 + even_result, 10)

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
