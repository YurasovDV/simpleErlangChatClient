-module(server_adapter).
-author("1").

%% API
-export([send_message/2, start_server_listener/1, connect/2]).

-export([event_loop/1]).

send_message(ServerSocket, MessageText) ->
  ok = gen_tcp:send(ServerSocket, MessageText).

-spec start_server_listener/1 :: (gen_tcp:socket()) -> ok.
start_server_listener(ServerSock) ->
  Pid = spawn_link(?MODULE, event_loop, [ServerSock]),
  ok = gen_tcp:controlling_process(ServerSock, Pid).

-spec event_loop/1 :: (gen_tcp:socket()) -> ok.
event_loop(ServerSock) ->
  receive
    {tcp, _Socket, String} ->
      io:format("~p~n", [String])
  %% TODO log
%%   after 10000 ->
%%     io:format("nuffin~n")
  end,
  event_loop(ServerSock).


connect(ServerAddress, ServerPort) ->
  {ok, Server} = gen_tcp:connect(ServerAddress, ServerPort, [{active, true}, {nodelay, true}], 1000),
  ok = gen_tcp:send(Server, "/login"),
  io:format("Login..: ", []),
  receive
    {tcp, _Socket, String} ->
      io:format("~p~n", [String]),
      io:format("commands: /set_nick Nick, /logout, /poll_messages~n", []),
      _Socket
  after 15000 ->
    error(timeout)
  end.
