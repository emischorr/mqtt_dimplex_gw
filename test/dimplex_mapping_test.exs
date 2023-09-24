defmodule DimplexMappingTest do
  use ExUnit.Case, async: true

  alias MqttDimplexGw.Dimplex.Mapping

  describe "status_name/1" do
    test "returns off status", do: assert "off" == Mapping.status_name(0.1)
    test "returns heating status", do: assert "heating" == Mapping.status_name(0.2)
    test "returns warmwater status", do: assert "warmwater" == Mapping.status_name(0.4)
    test "returns cooling status", do: assert "cooling" == Mapping.status_name(0.5)
    test "returns locked status", do: assert "locked" == Mapping.status_name(3)
    test "returns unknown status", do: assert "unkown" == Mapping.status_name(20)
  end
end
