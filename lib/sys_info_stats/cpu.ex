defmodule SysInfoStats.Cpu do
  @moduledoc """
  This is the Cpu module. Got some inspiration from https://github.com/zeam-vm/cpu_info kudos.
  """

  alias SysInfoStats.Utils

  def info(), do: info(Utils.os_type)

  def info(:linux) do
     cpu_type =
      :erlang.system_info(:system_architecture) |> List.to_string() |> String.split("-") |> hd

    info =
    File.read!("/proc/cpuinfo")
    |> String.split("\n\n")
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
    |> Enum.map(fn cpuinfo ->
      String.split(cpuinfo, "\n")
      |> Enum.map(fn item ->
        [k | v] = String.split(item, ~r"\t+: ")
        {k, v}
      end)
      |> Map.new()
    end)


    cpu_models = Enum.map(info, &Map.get(&1, "model name")) |> List.flatten()

    cpu_model = hd(cpu_models)

    num_of_processors =
      Enum.map(info, &Map.get(&1, "physical id"))
      |> Enum.uniq()
      |> Enum.count()

    t1 =
      Enum.map(info, &Map.get(&1, "processor"))
      |> Enum.uniq()
      |> Enum.reject(&is_nil(&1))
      |> length

    t =
      Enum.map(info, &Map.get(&1, "cpu cores"))
      |> Enum.uniq()
      |> Enum.reject(&is_nil(&1))
      |> Enum.map(&(&1 |> hd |> String.to_integer()))
      |> Enum.sum()

    total_num_of_cores = if t == 0, do: t1, else: t

    num_of_cores_of_a_processor = div(total_num_of_cores, num_of_processors)

    total_num_of_threads =
      Enum.map(info, &Map.get(&1, "processor"))
      |> Enum.count()

    num_of_threads_of_a_processor = div(total_num_of_threads, num_of_processors)

    ht =
      if total_num_of_cores < total_num_of_threads do
        :enabled
      else
        :disabled
      end

    %{
      cpu_type: cpu_type,
      cpu_model: cpu_model,
      cpu_models: cpu_models,
      num_of_processors: num_of_processors,
      num_of_cores_of_a_processor: num_of_cores_of_a_processor,
      total_num_of_cores: total_num_of_cores,
      num_of_threads_of_a_processor: num_of_threads_of_a_processor,
      total_num_of_threads: total_num_of_threads,
      hyper_threading: ht
    }
end

def info(sys), do: {:error, "not implemented for os type #{sys}"}


def uptime(), do: uptime(Utils.os_type)

def uptime(:linux) do
  case System.cmd("uptime", []) do
    {results, 0} ->
      regex = ~r/(?<timeHour>\d{1,2}):(?<timeMinute>\d{2})(?:\:(?<timeSecond>\d{2}))?\s+up\s+(?:(?<upDays>\d+)\s+days?,\s+)?\b(?:(?<upHours>\d+):)?(?<upMinutes>\d+)(?:\s+minutes?)?,\s+(?<users>\d+).+?(?<load1m>\d+\.\d+),?\s+(?<load5m>\d+\.\d+),?\s+(?<load15m>\d+\.\d+)/

      parsed_results = Regex.named_captures(regex, results)

      %{
        load_1m: parsed_results["load1m"] |> Float.parse |> elem(0),
        load_5m: parsed_results["load5m"] |> Float.parse |> elem(0),
        load_15m: parsed_results["load15m"] |> Float.parse |> elem(0),
        uptime_days: parsed_results["upDays"] |>  Integer.parse |> elem(0)
      }
    _ -> {:error, "load cannot be fetched at this moment"}
    end
end

def uptime(sys), do:   {:error, "not implemented for os type #{sys}"}

end
