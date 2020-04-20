defmodule SysInfoStats.Power do

  alias SysInfoStats.Utils
  def info(), do: info(Utils.os_type)

  def info(:linux) do
    case Path.wildcard("/sys/class/power_supply/*/*") do
      [] -> :power_info_not_available
      files ->
        files
        |> Enum.map(fn file -> {file, File.read!(file)} end)
        |> Enum.map(fn {k,v} -> { String.split(k, "/") |>  Enum.take(-2)|> Enum.join("_")|> String.to_atom , String.replace(v, "\n", "")} end)
        |> Map.new
    end
  end

end
