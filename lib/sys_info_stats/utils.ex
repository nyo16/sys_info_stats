defmodule SysInfoStats.Utils do

  def os_type do
    case :os.type() do
      {:unix, :linux} -> :linux
      {:unix, :darwin} -> :macos
      {:unix, :freebsd} -> :freebsd
      {:win32, _} -> :windows
      _ -> :unknown
    end
  end

  def os_release(:linux) do
    File.read!("/etc/os-release")
    |> String.split("\n")
    |> Enum.reverse()
    |> tl
    |> Enum.reverse()
    |> Enum.map(&String.split(&1, "="))
    |> Enum.map(fn [k, v] -> {k, v |> String.trim("\"")} end)
    |> Map.new()
  end

  def os_release(), do: :not_found


  def is_executable?(executable) do
    case System.find_executable(executable) do
      nil -> false
      _path -> true
    end
  end

end
