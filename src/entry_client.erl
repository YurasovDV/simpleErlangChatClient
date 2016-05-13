-module(entry_client).
-author("1").

%% API
-export([main/0]).

main() ->
  ok = application:load(simpleErlangChatClient),
  application:start(simpleErlangChatClient),
  ok.