defmodule ArtemisLog.Behaviour.Filtered do
  @callback event_log_fields() :: List.t()
end
