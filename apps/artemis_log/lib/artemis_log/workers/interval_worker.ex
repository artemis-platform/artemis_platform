defmodule ArtemisLog.IntervalWorker do
  @moduledoc """
  A `use` able module for creating GenServer instances that perform tasks on a
  set interval.

  ## Callbacks

  Define a `call/1` function to be executed at the interval. Receives the
  current `state.data`.

  Must return a tuple `{:ok, _}` or `{:error, _}`.

  ## Options

  Takes the following options:

    :name - Required. Name of the server.
    :enabled - Optional. If set to false, starts in paused state.
    :interval - Optional. Interval between calls.
    :log_limit - Optional. Number of log entries to keep.
    :delayed_start - Optional. Wait until timer expires for initial call.

  For example:

    use ArtemisLog.IntervalWorker,
      interval: 15_000,
      log_limit: 500,
      name: :repo_reset_on_interval

  """

  @callback call(map(), any()) :: {:ok, any()} | {:error, any()}
  @callback handle_info_callback(any(), any()) :: {:ok, any()} | {:error, any()}

  @optional_callbacks handle_info_callback: 2

  defmacro __using__(options) do
    quote do
      require Logger

      use GenServer

      defmodule State do
        defstruct [
          :config,
          :data,
          :timer,
          log: []
        ]
      end

      defmodule Log do
        defstruct [
          :details,
          :duration,
          :ended_at,
          :started_at,
          :success
        ]
      end

      @behaviour ArtemisLog.IntervalWorker
      @default_interval 60_000
      @default_log_limit 500

      def start_link(config \\ []) do
        initial_state = %State{
          config: config
        }

        dynamic_name = Keyword.get(config, :name)
        configured_name = get_name()

        options = [
          name: dynamic_name || configured_name
        ]

        GenServer.start_link(__MODULE__, initial_state, options)
      end

      def get_name(name \\ nil), do: name || get_option(:name)

      def get_config(name \\ nil), do: GenServer.call(get_name(name), :config)

      def get_data(name \\ nil), do: GenServer.call(get_name(name), :data)

      def get_log(name \\ nil), do: GenServer.call(get_name(name), :log)

      def get_options(), do: unquote(options)

      def get_option(key, default \\ nil), do: Keyword.get(get_options(), key, default)

      def get_result(name \\ nil), do: GenServer.call(get_name(name), :result)

      def get_state(name \\ nil), do: GenServer.call(get_name(name), :state)

      def pause(name \\ nil), do: GenServer.call(get_name(name), :pause)

      def resume(name \\ nil), do: GenServer.call(get_name(name), :resume)

      def update(options \\ [], name \\ nil) do
        case Keyword.get(options, :async) do
          true -> Process.send(get_name(name), :update, [])
          _ -> GenServer.call(get_name(name), :update)
        end
      end

      # Callbacks

      @impl true
      def init(state) do
        state = initial_actions(state)

        {:ok, state}
      end

      @impl true
      def handle_call(:config, _from, state) do
        {:reply, state.config, state}
      end

      @impl true
      def handle_call(:data, _from, state) do
        {:reply, state.data, state}
      end

      @impl true
      def handle_call(:log, _from, state) do
        {:reply, state.log, state}
      end

      @impl true
      def handle_call(:pause, _from, state) do
        if state.timer && state.timer != :paused do
          Process.cancel_timer(state.timer)
        end

        {:reply, true, %State{state | timer: :paused}}
      end

      @impl true
      def handle_call(:result, _from, state) do
        result = Artemis.Helpers.deep_get(state, [:data, :result])

        {:reply, result, state}
      end

      @impl true
      def handle_call(:resume, _from, state) do
        if state.timer && state.timer != :paused do
          Process.cancel_timer(state.timer)
        end

        {:reply, true, %State{state | timer: schedule_update()}}
      end

      @impl true
      def handle_call(:state, _from, state) do
        {:reply, state, state}
      end

      @impl true
      @doc "Synchronous"
      def handle_call(:update, _from, state) do
        state = update_state(state)

        {:reply, state, state}
      end

      @impl true
      @doc "Asynchronous"
      def handle_info(:update, state) do
        state = update_state(state)

        {:noreply, state}
      end

      def handle_info(data, state) do
        handle_info_callback(data, state)
      end

      def handle_info_callback(_, state) do
        {:no_reply, state}
      end

      # Callback Helpers

      defp initial_actions(state) do
        case get_option(:enabled, true) do
          true -> schedule_or_execute_initial_call(state)
          false -> Map.put(state, :timer, :paused)
        end
      end

      defp schedule_or_execute_initial_call(state) do
        case get_option(:delayed_start, false) do
          true ->
            Map.put(state, :timer, schedule_update())

          false ->
            # Make an asynchronous call instead of a blocking synchronous one.
            # Important to prevent loading delays on application start.
            Map.put(state, :timer, schedule_update(10))
        end
      end

      defp update_state(state) do
        started_at = Timex.now()
        result = call(state.data, state.config)
        ended_at = Timex.now()

        state
        |> Map.put(:data, parse_data(state, result))
        |> Map.put(:log, update_log(state, result, started_at, ended_at))
        |> Map.put(:timer, schedule_update_unless_paused(state))
      end

      defp schedule_update(custom_interval \\ nil) do
        interval = custom_interval || get_option(:interval, @default_interval)

        Process.send_after(self(), :update, interval)
      end

      defp schedule_update_unless_paused(%{timer: timer}) when timer == :paused, do: nil
      defp schedule_update_unless_paused(%{timer: timer}) when is_nil(timer), do: schedule_update()

      defp schedule_update_unless_paused(%{timer: timer}) do
        Process.cancel_timer(timer)

        schedule_update()
      end

      def parse_data(_state, {:ok, data}), do: data
      def parse_data(%{data: current_data}, _), do: current_data

      defp update_log(%{log: log}, result, started_at, ended_at) do
        entry = %Log{
          details: elem(result, 1),
          duration: Timex.diff(ended_at, started_at),
          ended_at: ended_at,
          started_at: started_at,
          success: success?(result)
        }

        log_limit = get_option(:log_limit, @default_log_limit)
        truncated = Enum.slice(log, 0, log_limit)

        [entry | truncated]
      end

      defp success?({:ok, _}), do: true
      defp success?(_), do: false

      # Allow defined `@callback`s to be overwritten

      defoverridable ArtemisLog.IntervalWorker
    end
  end
end
