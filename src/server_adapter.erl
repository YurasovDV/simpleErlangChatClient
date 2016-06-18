-module(server_adapter).
-author("1").

%% API
-export([send_message/2, start_server_listener/1, connect/2]).

-export([event_loop/1]).

-spec send_message(port(),binary() | maybe_improper_list(binary() | maybe_improper_list(any(),binary() | []) | byte(),binary() | [])) -> 'ok'.
send_message(ServerSocket, MessageText) ->
case  gen_tcp:send(ServerSocket, MessageText) of
ok -> ok;
{error, Reason} ->
	 io:format("server_adapter:send_message ~p~n", [Reason]),
	 error(Reason)
end.

-spec start_server_listener/1 :: (gen_tcp:socket()) -> ok.

start_server_listener(ServerSock) ->
  Pid = spawn_link(?MODULE, event_loop, [ServerSock]),
  ok = gen_tcp:controlling_process(ServerSock, Pid).

-spec event_loop/1 :: (gen_tcp:socket()) -> ok.

event_loop(ServerSock) ->
  receive
    {tcp, _Socket, String} ->
	print_message(String)
  end,
  event_loop(ServerSock).


-spec connect(atom() | string() | {byte(),byte(),byte(),byte()} | {char(),char(),char(),char(),char(),char(),char(),char()},char()) -> any().
connect(ServerAddress, ServerPort) ->
ConnectResult = gen_tcp:connect(ServerAddress, ServerPort, [{active, true}, {nodelay, true}, {packet, line}], 1000),
 case ConnectResult of
  {ok, Server} ->  
	ok = gen_tcp:send(Server, "/login"),
  	io:format("commands: /set_nick Nick, /logout, /poll_messages~n", []),
  	io:format("Login..: ", []),
  	receive_last_messages();
  {error, Reason} ->
	 io:format("server_adapter:connect ~p~n", [Reason]),
	 error(Reason)
end.


-spec receive_last_messages() -> any().
receive_last_messages() ->
receive 
    {tcp, _Socket, String} ->
     io:format("~p ~p ~n", ["receive_last_messages", String]),
     {N, _} = string:to_integer(String),
     receive_message(N),
     _Socket
  end.

-spec receive_message('error' | integer()) -> 'ok'.
receive_message(0) -> ok;

receive_message(N) ->
  io:format("waiting for message #~p ~n", [N]),
  receive 
    {tcp, _Socket, String} ->
     print_message(String),
     receive_message(N - 1)
   after 3000 -> ok
  end.

-spec print_message(_) -> 'ok'.
print_message(String) ->
   %% TODO parse messages as sender/time/text
   io:format("~p~n", [String]).
