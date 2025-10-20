defmodule MqttDimplexGw.Dimplex do
  alias MqttDimplexGw.Dimplex.API

  @spec groups(list(String.t())) :: {:error, {:error, any}} | {:ok, list}
  defdelegate groups(group_list), to: API

  @spec status :: {:error, {:error, any}} | {:ok, list}
  defdelegate status, to: API

  @spec ww_temp(temp :: integer()) :: {:error, {:error, any}} | {:ok, any}
  defdelegate ww_temp(temp), to: API

  @spec heating :: {:error, {:error, any}} | {:ok, any}
  defdelegate heating, to: API

  @spec heating_offset(offset :: integer()) :: {:error, {:error, any}} | {:ok, any}
  defdelegate heating_offset(offset), to: API

  @spec operation_mode(mode :: integer()) :: {:error, {:error, any}} | {:ok, any}
  defdelegate operation_mode(mode), to: API
end
