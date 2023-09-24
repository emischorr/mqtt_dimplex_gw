defmodule DimplexApiTest do
  use ExUnit.Case, async: true

  import Mox
  import ApiResponseFixtures

  alias MqttDimplexGw.Dimplex.API
  alias MqttDimplexGw.Dimplex.API.ProdHost

  defmock(MqttDimplexGw.Dimplex.API.TestHost, for: MqttDimplexGw.Dimplex.API.Host)
  Application.put_env(:mqtt_dimplex_gw, :dimplex_host_impl, MqttDimplexGw.Dimplex.API.TestHost)

  setup do
    bypass = Bypass.open()
    url = "http://127.0.0.1:#{bypass.port()}/api"
    expect(MqttDimplexGw.Dimplex.API.TestHost, :base_url, fn -> url end)
    {:ok, bypass: bypass}
  end


  test "production host uses config" do
    Application.put_env(:mqtt_dimplex_gw, :dimplex, [host: "192.168.0.10"])
    assert "http://192.168.0.10/api" = ProdHost.base_url()
  end

  test "statistics can be retrieved", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/functiondata/group/WAERMEMENGEN", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, statistics_response())
    end)

    expected_response = [
      %{value: 9947, key: "heating_total_hours"}, %{value: 0, key: "WMZ_H_ST5bis8"},
      %{value: 0, key: "WMZ_H_ST9bis12"}, %{value: 1345, key: "warmwater_total_hours"},
      %{value: 0, key: "WMZ_WW_ST5bis8"}, %{value: 0, key: "WMZ_WW_ST9bis12"}
    ]
    assert {:ok, ^expected_response} = API.statistics()
  end

  test "inputs can be retrieved", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/functiondata/group/INPUTS", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, inputs_response())
    end)

    expected_response = [
      %{value: 0, key: "E_NDP"}, %{value: 0, key: "E_HDP"},
      %{value: 1, key: "E_HGT"}, %{value: 0, key: "smartgrid_low"},
      %{value: 0, key: "smartgrid_high"}, %{value: 1, key: "smartgrid_normal"},
      %{value: 0, key: "SmartGrid_Problem"}, %{value: 0, key: "E_MSVD"},
      %{value: 0, key: "E_EVS"}, %{value: 0, key: "E_TPW"}, %{value: 0, key: "E_BAKUE"}
    ]
    assert {:ok, ^expected_response} = API.inputs()
  end

  test "display values can be retrieved", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/functiondata/group/DATEN_DISPLAY_BETREIBER", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, display_response())
    end)

    expected_response = [
      %{value: 23.4, key: "outdoor_temp"},
      %{value: 48.9, key: "warmwater_current_temp"},
      %{value: 48, key: "Ww_Soll_Anz"},
      %{value: 27.2, key: "E_Vorl_T_WP"},
      %{value: 28, key: "E_Rueckl_T_WP"},
      %{value: 27.5, key: "Anz_Hk1_Ist_Temp"},
      %{value: 15, key: "Anz_HK1_Soll_Temp"},
      %{value: 1.4, key: "E_Sek_Druck"},
      %{value: 0, key: "E_DfSen_Sek"},
      %{value: 17.1, key: "E_DRUCK_HD"},
      %{value: 17, key: "E_DRUCK_ND"},
      %{value: "heating", key: "status"},
      %{value: 0, key: "Sperr_Wp_Wert"},
      %{value: 0, key: "Stoerung_Wert"},
      %{value: 0, key: "Fehler_Wert"}
    ]
    assert {:ok, ^expected_response} = API.display()
  end

  test "status of heatpump can be retrieved", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/system/status", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, status_response())
    end)

    expected_response = %{
      "cloud_connection" => true,
      "current_error" => nil,
      "has_internet" => true,
      "simulation_mode" => false,
      "uptime" => 470544.34
    }
    assert {:ok, ^expected_response} = API.status()
  end

  test "list of operation modes can be retrieved", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/operationmode/list", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, operation_modes_response())
    end)

    expected_response = [%{"0" => "Sommer"}, %{"1" => "Winter"}, %{"3" => "Party"}, %{"4" => "2. Wärmeerzeuger"}]
    assert {:ok, ^expected_response} = API.operation_modes()
  end

  test "multiple GROUPS can be queried", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/functiondata/groups", fn conn ->
      %{"groups" => "GROUP_01,DATEN_DISPLAY_BETREIBER"} = URI.decode_query(conn.query_string)

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, groups_response())
    end)

    expected_values = [
      %{value: 19.1, key: "outdoor_temp"},
      %{value: 26.5, key: "heating_supply_temp"},
      %{value: 26.1, key: "heating_return_temp"},
      %{value: 15, key: "heating_target_temp"},
      %{value: 48.1, key: "warmwater_current_temp"},
      %{value: 48, key: "warmwater_target_temp"},
      %{value: "off", key: "status"},
    ]

    {:ok, values} = API.groups(["GROUP_01", "DATEN_DISPLAY_BETREIBER"])
    Enum.each(expected_values, fn value ->
      assert Enum.member?(values, value)
    end)
  end

  test "warmwater temp can be retrieved", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/heatingunit/WW/temperature", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, ww_temp_response())
    end)

    expected_response = %{"current" => 47.9, "target" => 48, "offset" => 0}
    assert {:ok, ^expected_response} = API.ww_temp()
  end
end
