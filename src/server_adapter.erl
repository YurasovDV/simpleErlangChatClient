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
print_message(String)
  %% TODO log
%%   after 10000 ->
%%     io:format("nuffin~n")
  end,
  event_loop(ServerSock).


connect(ServerAddress, ServerPort) ->
  {ok, Server} = gen_tcp:connect(ServerAddress, ServerPort, [{active, true}, {nodelay, true}, {packet, line}], 1000),
  ok = gen_tcp:send(Server, "/login"),
  io:format("commands: /set_nick Nick, /logout, /poll_messages~n", []),
  io:format("Login..: ", []),
  receive_last_messages().


receive_last_messages() ->
receive 
    {tcp, _Socket, String} ->
     io:format("~p ~p ~n", ["receive_last_messages", String]),
     {N, _} = string:to_integer(String),
     receive_message(N),
     _Socket
  end.

receive_message(0) -> ok;

receive_message(N) ->
  io:format("waiting for message #~p ~n", [N]),
  receive 
    {tcp, _Socket, String} ->
     print_message(String),
     receive_message(N - 1)
   after 3000 -> ok
  end.

print_message(String) ->
   io:format("~p~n", [String]).
