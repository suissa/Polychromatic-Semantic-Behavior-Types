:- module(forger, [get_primitive_type/2, validate/2, convert_to_primitive/2, process_value/2]).

get_primitive_type(V, V).

validate(_, false).

primitive_string_to_value(Val, Res) :-
    normalize_space(atom(Trimmed), Val),
    downcase_atom(Trimmed, Lower),
    ( Trimmed == '' -> Res = Val
    ; (Val == '{}' ; Val == '[]') -> Res = 0
    ; Lower == 'true' -> Res = true
    ; Lower == 'false' -> Res = false
    ; (Lower == 'null' ; Lower == 'undefined') -> Res = null
    ; catch(atom_number(Trimmed, Num), _, fail) -> Res = Num
    ; Res = Val
    ).

convert_to_primitive(Val, Res) :-
    ( atom(Val), \+ number(Val) -> primitive_string_to_value(Val, Res)
    ; string(Val) -> atom_string(Atom, Val), primitive_string_to_value(Atom, Res)
    ; Res = Val
    ).

forge(V, V).

process_value(Dict, Res) :-
    is_dict(Dict),
    get_dict(productPrice, Dict, PPriceRaw),
    convert_to_primitive(PPriceRaw, PPrice),
    ( get_dict(productDiscount, Dict, PDiscountRaw) -> convert_to_primitive(PDiscountRaw, PDiscount) ; PDiscount = 0 ),
    ( get_dict(deliveryPrice, Dict, DPriceRaw) -> convert_to_primitive(DPriceRaw, DPrice) ; DPrice = 0 ),
    ( get_dict(paymentFees, Dict, PFeesRaw) -> convert_to_primitive(PFeesRaw, PFees) ; PFees = 0 ),
    number(PPrice),
    FinalPrice is PPrice - PDiscount + DPrice + PFees,
    forge(FinalPrice, Res).
process_value(Val, Res) :-
    \+ is_dict(Val),
    convert_to_primitive(Val, Prim),
    forge(Prim, Res).
