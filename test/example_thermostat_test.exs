defmodule ExampleThermostatTest do
  use ExUnit.Case
  doctest ExampleThermostat

  test "greets the world" do
    assert ExampleThermostat.hello() == :world
  end
end
