defmodule ExampleThermostat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExampleThermostat.Thermostat,
      {HAP,
       %HAP.AccessoryServer{
         name: "Thermostat",
         model: "Thermostat",
         identifier: "11:22:33:44:12:79",
         accessory_type: 9,
         accessories: [
           %HAP.Accessory{
             name: "Thermostat",
             services: [
               %HAP.Services.Thermostat{
                 name: "Thermostat",
                 current_state: {ExampleThermostat.Thermostat, :current_state},
                 current_temp: {ExampleThermostat.Thermostat, :current_temp},
                 target_state: {ExampleThermostat.Thermostat, :target_state},
                 target_temp: {ExampleThermostat.Thermostat, :target_temp},
                 temp_display_units: {ExampleThermostat.Thermostat, :temp_display_units}
               }
             ]
           }
         ]
       }}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExampleThermostat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
