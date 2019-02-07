-module(release_manager).

-export([migrate/0]).

-define(MANAGER, 'Elixir.ReleaseManager').

migrate() ->
  ?MANAGER:migrate().
