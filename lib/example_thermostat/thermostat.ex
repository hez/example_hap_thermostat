defmodule ExampleThermostat.Thermostat do
  @moduledoc """
  Responsible for representing a HAP thermostat
  """

  @behaviour HAP.ValueStore

  use GenServer

  require Logger

  def start_link(config),
    do: GenServer.start_link(__MODULE__, config, name: __MODULE__)

  def on, do: put_value(1, :current_state)
  def off, do: put_value(0, :current_state)

  def status, do: GenServer.call(__MODULE__, :status)

  @impl HAP.ValueStore
  def get_value(:target_state), do: get_value(:current_state)
  def get_value(:temp_display_units), do: {:ok, 0}
  def get_value(opts), do: GenServer.call(__MODULE__, {:get, opts})

  @impl HAP.ValueStore
  def put_value(value, opts), do: GenServer.call(__MODULE__, {:put, value, opts})

  @impl HAP.ValueStore
  def set_change_token(change_token, event),
    do: GenServer.call(__MODULE__, {:set_change_token, change_token, event})

  @impl GenServer
  def init(_), do: {:ok, %{current_temp: 10.0, target_temp: 10.0, current_state: 0, change_tokens: %{}}}

  @impl GenServer
  def handle_call(:status, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_call({:get, event}, _from, state) do
    Logger.debug("Getting state for #{inspect(event)} #{inspect(state)}")
    {:reply, {:ok, Map.get(state, event)}, state}
  end

  @impl GenServer
  def handle_call({:put, value, name}, _from, state) do
    Logger.debug("put state for #{inspect(name)} #{inspect(state)} new #{value}")
    state = Map.put(state, name, value)
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:set_change_token, change_token, event}, _from, state) do
    Logger.debug("new change token for #{inspect(event)} #{inspect(change_token)}")
    {:reply, :ok, %{state | change_tokens: Map.put(state.change_tokens, event, change_token)}}
  end

  def handle_call({:toggle, name}, _from, state) do
    Logger.debug("toggling #{name}")
    new_on_state = if state.on == 1, do: 0, else: 1
    HAP.value_changed(state.change_token)
    {:reply, :ok, %{state | on: new_on_state}}
  end
end
