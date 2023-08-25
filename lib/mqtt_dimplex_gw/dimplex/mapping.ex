defmodule MqttDimplexGw.Dimplex.Mapping do
  # GROUP_01
  def mappings(%{key: "Status_Wert", value: value}), do: %{key: "status", value: status_name(value)}
  def mappings(%{key: "WMZ_H_ST1bis4", value: value}), do: %{key: "heating_total_hours", value: value}
  def mappings(%{key: "WMZ_WW_ST1bis4", value: value}), do: %{key: "warmwater_total_hours", value: value}
  def mappings(%{key: "P_WW_SOLL", value: value}), do: %{key: "warmwater_target_temp", value: value}
  def mappings(%{key: "E_Ww_Fuehl", value: value}), do: %{key: "warmwater_current_temp", value: value}
  def mappings(%{key: "HK1_Soll_Temp", value: value}), do: %{key: "heating_target_temp", value: value}
  def mappings(%{key: "E_Vorl_T", value: value}), do: %{key: "heating_supply_temp", value: value}
  def mappings(%{key: "E_Rueckl_T", value: value}), do: %{key: "heating_return_temp", value: value}
  def mappings(%{key: "E_Aussen_T", value: value}), do: %{key: "outdoor_temp", value: value}
  # INPUTS
  def mappings(%{key: "SmartGrid_Niedrig", value: value}), do: %{key: "smartgrid_low", value: value}
  def mappings(%{key: "SmartGrid_Hoch", value: value}), do: %{key: "smartgrid_high", value: value}
  def mappings(%{key: "SmartGrid_Normal", value: value}), do: %{key: "smartgrid_normal", value: value}
  def mappings(key_value_map), do: key_value_map

  def status_name(0.1), do: "off"
  def status_name(0.2), do: "heating"
  def status_name(0.4), do: "warmwater"
  def status_name(0.5), do: "cooling"
  def status_name(3), do: "locked"
  def status_name(_code), do: "Unknown"
end
