defmodule SysInfoStats.Network do

  alias SysInfoStats.Utils

  def socket_stat(), do: socket_stat(Utils.os_type)

  def socket_stat(:linux) do
    regex = ~r/(?<sockets>\d+)\nTCP: inuse (?<tcp_inuse>\d+) orphan (?<tcp_orphan>\d+) tw (?<tcp_tw>\d+) alloc (?<tcp_alloc>\d+) mem (?<tcp_mem>\d+)\nUDP: inuse (?<udp_inuse>\d+) mem (?<udp_mem>\d+)/
    Regex.named_captures(regex, File.read!("/proc/net/sockstat"))
    |> Map.to_list
    |> Enum.map(fn {k,v} -> {String.to_atom(k),  Integer.parse(v) |> elem(0)} end)
    |> Map.new
  end
end
