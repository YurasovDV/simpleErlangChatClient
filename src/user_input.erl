-module(user_input).
-author("1").

%% API
-export([event_loop/1, start_listen/1]).

-spec start_listen/1 :: (SendCallback) -> pid()
  when SendCallback :: fun((Message :: string()) -> ok).
start_listen(SendCallback) ->
  io:format("start_listen~n", []),
  Pid = spawn_link(?MODULE, event_loop, [SendCallback]),
  Pid.

-spec event_loop/1 :: (SendCallback) -> ok
  when SendCallback :: fun((Message :: string()) -> ok).
event_loop(SendCallback) ->
  case io:get_line(">>") of
    "/quit" ->
      exit(0);
    eof ->
      exit(0);
    UserInput ->
      ok = SendCallback(UserInput),
      event_loop(SendCallback)
  end.

