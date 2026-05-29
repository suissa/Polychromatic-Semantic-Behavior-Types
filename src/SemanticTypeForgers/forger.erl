-module(forger).
-export([get_primitive_type/1, validate/1, convert_to_primitive/1, forge/1, proccess_value/1]).

get_primitive_type(V) -> V.

validate(Name, Value) ->
    case Name of
        "PersonEmail" ->
            Prim = convert_to_primitive(Value),
            if
                is_list(Prim) ->
                    case re:run(Prim, "^[a-zA-Z0-9_.+\\-]+@[a-zA-Z0-9\\-]+\\.[a-zA-Z0-9\\-.]+$", [{capture, none}]) of
                        match -> true;
                        nomatch -> false
                    end;
                true -> false
            end;
        _ -> false
    end.

trim(S) -> string:trim(S).
to_lower(S) -> string:lowercase(S).

primitive_string_to_value(Val) ->
    Trimmed = trim(Val),
    Lower = to_lower(Trimmed),
    if
        Trimmed == "" -> Val;
        Val == "{}"; Val == "[]" -> 0;
        Lower == "true" -> true;
        Lower == "false" -> false;
        Lower == "null"; Lower == "undefined" -> null;
        true ->
            case re:run(Trimmed, "^[+-]?(?:(?:\\d+\\.?\\d*)|(?:\\.\\d+))(?:e[+-]?\\d+)?$", [caseless]) of
                {match, _} ->
                    HasDot = string:chr(Trimmed, $.) > 0,
                    HasE = string:chr(Lower, $e) > 0,
                    if
                        HasDot orelse HasE ->
                            {F, _} = string:to_float(Trimmed ++ if HasDot -> ""; true -> ".0" end),
                            F;
                        true ->
                            {I, _} = string:to_integer(Trimmed),
                            I
                    end;
                nomatch -> Val
            end
    end.

unwrap(Val, _Seen, Depth) when Depth > 100 -> erlang:error(recursive_unwrap_limit_exceeded);
unwrap(Val, _Seen, _Depth) when Val == null -> null;
unwrap(Val, _Seen, _Depth) when is_boolean(Val); is_integer(Val); is_float(Val) -> Val;
unwrap(Val, _Seen, _Depth) when is_list(Val) ->
    case io_lib:printable_list(Val) of
        true -> primitive_string_to_value(Val);
        false ->
            if
                length(Val) == 0 -> null;
                true -> unwrap(hd(Val), _Seen, _Depth + 1)
            end
    end;
unwrap(Val, _Seen, Depth) when is_map(Val) ->
    if
        map_size(Val) == 0 -> 0;
        true ->
            [First | _] = maps:values(Val),
            unwrap(First, _Seen, Depth + 1)
    end;
unwrap(_, _, _) -> null.

convert_to_primitive(Value) ->
    try
        unwrap(Value, sets:new(), 0)
    catch
        _:_ -> null
    end.

forge(Name, V) ->
    case Name of
        "PersonEmail" ->
            case validate(Name, V) of
                true -> V;
                false -> erlang:error("Validation failed for SemanticType: PersonEmail")
            end;
        _ -> V
    end.

proccess_value(Name, Value) ->
    case validate(Name, Value) of
        true -> Value;
        false ->
            if
                is_map(Value) ->
                    PPrice = convert_to_primitive(maps:get(<<"productPrice">>, Value, maps:get("productPrice", Value, null))),
                    PDiscount = convert_to_primitive(maps:get(<<"productDiscount">>, Value, maps:get("productDiscount", Value, 0))),
                    DPrice = convert_to_primitive(maps:get(<<"deliveryPrice">>, Value, maps:get("deliveryPrice", Value, 0))),
                    PFees = convert_to_primitive(maps:get(<<"paymentFees">>, Value, maps:get("paymentFees", Value, 0))),

                    if
                        is_integer(PPrice) orelse is_float(PPrice) ->
                            forge(Name, PPrice - PDiscount + DPrice + PFees);
                        true ->
                            forge(Name, convert_to_primitive(Value))
                    end;
                true ->
                    forge(Name, convert_to_primitive(Value))
            end
    end.
