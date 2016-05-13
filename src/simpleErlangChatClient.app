{application, simpleErlangChatClient,
 [
  {description, ""},
  {vsn, "1"},
  {registered, []},
  {applications, [
                  kernel,
                  stdlib
                 ]},
  {mod, { simpleErlangChatClient, []}},
   {env, [
     {port, 1234},
     {addr, "localhost"}
   ]}
 ]}.
