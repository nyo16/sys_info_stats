defmodule SysInfoStats.Memory do

  alias SysInfoStats.Utils

  @giga_bytes 1_000_000

  def info(), do: info(Utils.os_type)

  def info(:linux) do
    r = ~r/[^\d]/
    mem_map = File.read!("/proc/meminfo")
    |> String.split("\n")
    |> Enum.map(fn item ->
      String.split(item, ":", trim: true)
    end)
    |> Enum.filter(fn i -> i != [] end)
    |> Enum.map(fn [k,v] -> {k, String.replace(v, r,"")  |> Integer.parse |> elem(0) } end)
    |> Map.new()


    %{
      total: Map.get(mem_map, "MemTotal") / @giga_bytes |> Float.round(2),
      available: Map.get(mem_map, "MemAvailable") / @giga_bytes |> Float.round(2),
      free: Map.get(mem_map, "MemFree")  / @giga_bytes |> Float.round(2),
      swap_free: Map.get(mem_map, "SwapFree") / @giga_bytes |> Float.round(2),
      swap_total: Map.get(mem_map, "SwapTotal")  / @giga_bytes |> Float.round(2)
    }
  end
end
