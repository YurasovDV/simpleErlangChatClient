-module(client_logic).
-author("1").

-export([start/2,
  init/3]).

%% API
-export([send_message/1]).

-define(LOGIC_PROCESS, logic_proc).

start(MyPort, ServerAddress) ->
  Pid = spawn(?MODULE, init, [server_adapter, MyPort, ServerAddress]),
  true = register(?LOGIC_PROCESS, Pid),
  receive
    _ -> ok
  end,
  ok.

send_message(MessageText) ->
  WrappedResult =
    case hd(MessageText) of
    %% "/"
      $/ ->
        {IsCommand, ModifiedText} = check_if_command_and_unwrap(MessageText),
        case IsCommand of
          true ->
            ModifiedText;
          _ -> string:concat("/send ", MessageText)
        end;
      _ -> string:concat("/send ", MessageText)
    end,

  ?LOGIC_PROCESS ! {send_message, WrappedResult},
  ok.

check_if_command_and_unwrap(MessageText) ->
  IsCommand = check_if_command(MessageText),
  case IsCommand of
    false ->
      {false, MessageText};
    true ->
      % remove slash
      {true, string:substr(MessageText, 1)}
  end.

check_if_command(MessageText) ->
  %% Commands = sets:from_list(["/set_nick", "/logout", "/poll_messages"]),
  Commands = ["/set_nick", "/logout", "/poll_messages"],
  Words = string:tokens(MessageText, " "),
  Any = lists:any(fun(Constant) -> string:equal(Constant, hd(Words)) end, Commands),
  Any.

init(ServerAdapterModule, MyPort, ServerAddress) ->
  ServerSocket = try_connect(ServerAdapterModule, ServerAddress, MyPort),
  start_server_listener(ServerAdapterModule, ServerSocket),
  ok = start_listen_keyboard(),

  event_loop(ServerAdapterModule, ServerSocket).

-spec try_connect/3 :: (atom(), string(), integer()) -> gen_tcp:socket().
try_connect(ServerAdapterModule, Address, Port) ->
  apply(ServerAdapterModule, connect, [Address, Port]).


-spec start_server_listener/2 :: (atom(), gen_tcp:socket()) -> ok.
start_server_listener(ServerAdapterModule, ServerSocket) ->
  apply(ServerAdapterModule, start_server_listener, [ServerSocket]).


-spec start_listen_keyboard/0 :: () -> ok.
start_listen_keyboard() ->
  _Pid = user_input:start_listen(fun client_logic:send_message/1),
%%   io:format("~p", [Pid]),
  ok.


-spec event_loop/2 :: (atom(), gen_tcp:socket()) -> ok.
event_loop(ServerAdapterModule, ServerSocket) ->
  receive
    {send_message, MessageText} ->
      apply(ServerAdapterModule, send_message, [ServerSocket, MessageText]),
      event_loop(ServerAdapterModule, ServerSocket);
    stop ->
      ok;
    X ->
      io:format("client_logic.event_loop received ~p~n", [X])
  end.



