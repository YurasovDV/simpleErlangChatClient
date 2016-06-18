#!/bin/bash
erl -pa ~/Documents/Code/Erlang/simpleErlangChatClient/_build/default/lib/simpleErlangChatClient/ebin -noshell -s entry_client main -s init stop
