-module(forger_tests).
-export([start/0]).

start() ->
    5 = forger:get_primitive_type(5),
    123 = forger:convert_to_primitive(" 123 "),
    true = forger:convert_to_primitive("true"),
    0 = forger:convert_to_primitive("{}"),

    Map = #{"productPrice" => "10.5", "deliveryPrice" => 2.5},
    13.0 = forger:proccess_value("test", Map),

    true = forger:validate("PersonEmail", "test@example.com"),
    false = forger:validate("PersonEmail", "invalid-email"),

    try
        forger:forge("PersonEmail", "invalid-email"),
        erlang:error(should_have_thrown)
    catch
        error:"Validation failed for SemanticType: PersonEmail" -> ok
    end,

    io:format("Erlang tests passed~n"),
    halt(0).
