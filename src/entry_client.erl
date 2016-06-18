-module(entry_client).
-author("1").

%% API
-export([main/0]).

-spec main() -> 'ok'.
main() ->
  ok = application:load(simpleErlangChatClient),
  application:start(simpleErlangChatClient),
  ok.