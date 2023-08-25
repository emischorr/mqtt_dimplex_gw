defmodule MqttDimplexGw.Dimplex.API do
  @moduledoc """
  Wrapper module for the Dimplex API
  """
  use Tesla

  alias MqttDimplexGw.Dimplex.Mapping

  import Mapping

  plug Tesla.Middleware.JSON

  @groups [
    {:inputs, "INPUTS"},
    {:outputs, "OUTPUTS"},
    {:misc, "MISC"},
    {:values, "GROUP_01"},
    {:display, "DATEN_DISPLAY_BETREIBER"},
    {:statistics, "WAERMEMENGEN"}
  ]

  for {name, group} <- @groups do
    def unquote(name)() do
      case get("#{base_url()}/functiondata/group/#{unquote(group)}") do
        {:ok, %Tesla.Env{:body => body}} when is_map(body) or is_list(body) ->
          {:ok, body
            |> Enum.map(&( %{key: &1["key"], value: &1["value"]} ))
            |> Enum.map(&mappings/1)
          }

        error ->
          {:error, error}
      end
    end
  end

  @spec groups(list(String.t())) :: {:error, {:error, any}} | {:ok, list}
  def groups(group_list) do
    group_query = group_list|> Enum.join(",")

    case get("#{base_url()}/functiondata/groups?groups=#{group_query}") do
      {:ok, %Tesla.Env{:body => body}} when is_map(body) or is_list(body) ->
        {:ok, body
          |> Map.values()
          |> List.flatten()
          |> Enum.map(&( %{key: &1["key"], value: &1["value"]} ))
          |> Enum.map(&mappings/1)
          |> Enum.dedup()
        }

      error ->
        {:error, error}
    end
  end

  @spec status :: {:error, {:error, any}} | {:ok, list}
  def status do
    case get("#{base_url()}/system/status") do
      {:ok, %Tesla.Env{:body => body}} when is_map(body) -> {:ok, body}
      error -> {:error, error}
    end
  end

  @spec operation_modes :: {:error, {:error, any}} | {:ok, list}
  def operation_modes do
    case get("#{base_url()}/operationmode/list") do
      {:ok, %Tesla.Env{:body => body}} when is_list(body) ->
        {:ok, Enum.map(body, &( %{&1["id"] => &1["name"]} ))}

      error ->
        {:error, error}
    end
  end

  @spec operation_mode :: {:error, {:error, any}} | {:ok, any}
  def operation_mode do
    case get("#{base_url()}/operationmode") do
      {:ok, %Tesla.Env{:body => body}} -> {:ok, body}
      error -> {:error, error}
    end
  end

  @spec operation_mode(integer) :: {:error, {:error, any}} | {:ok, any}
  def operation_mode(mode) when is_integer(mode) do
    case put("#{base_url()}/operationmode", %{id: mode}) do
      {:ok, %Tesla.Env{:body => body}} -> {:ok, body}
      error -> {:error, error}
    end
  end

  @spec ww_temp :: {:error, {:error, any}} | {:ok, any}
  def ww_temp do
    case get("#{base_url()}/heatingunit/WW/temperature") do
      {:ok, %Tesla.Env{:body => body}} -> {:ok, body}
      error -> {:error, error}
    end
  end

  @spec ww_temp(integer) :: {:error, {:error, any}} | {:ok, any}
  def ww_temp(temp) when is_integer(temp), do: ww_temp(to_string(temp))

  @spec ww_temp(String.t()) :: {:error, {:error, any}} | {:ok, any}
  def ww_temp(temp) when is_binary(temp) do
    case put("#{base_url()}/heatingunit/WW/temperature", %{target: temp}) do
      {:ok, %Tesla.Env{:body => body}} -> {:ok, body}
      error -> {:error, error}
    end
  end

  @spec heating :: {:error, {:error, any}} | {:ok, any}
  def heating do
    case get("#{base_url()}/heatingunit/HK1/temperature") do
      {:ok, %Tesla.Env{:body => body}} -> {:ok, body}
      error -> {:error, error}
    end
  end

  @spec heating_offset(integer) :: {:error, {:error, any}} | {:ok, any}
  def heating_offset(offset) when is_integer(offset), do: heating_offset(to_string(offset))

  @spec heating_offset(String.t()) :: {:error, {:error, any}} | {:ok, any}
  def heating_offset(offset) when is_binary(offset) do
    case put("#{base_url()}/heatingunit/HK1/temperature", %{target: offset}) do
      {:ok, %Tesla.Env{:body => body}} -> {:ok, body}
      error -> {:error, error}
    end
  end

  defp base_url do
    "http://#{Application.get_env(:mqtt_dimplex_gw, :dimplex)[:host]}/api"
  end
end
