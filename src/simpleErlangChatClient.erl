-module(simpleErlangChatClient).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

-spec start(_,_) -> {'error',_} | {'ok',pid()} | {'ok',pid(),_}.
start(_StartType, _StartArgs) ->

  {'ok', MyPort} = application:get_env(port),
  {'ok', ServerAddress} = application:get_env(addr),

  client_logic:start(MyPort, ServerAddress),
  {ok, self()}.

-spec stop(_) -> 'ok'.
stop(_State) ->
  ok.
