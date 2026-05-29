:- use_module(forger).

:- initialization(main, main).

main :-
    get_primitive_type(5, R1), R1 == 5,
    convert_to_primitive(' 123 ', R2), R2 == 123,
    convert_to_primitive('true', R3), R3 == true,
    convert_to_primitive('{}', R4), R4 == 0,

    Dict = _{productPrice: '10.5', deliveryPrice: 2.5},
    process_value(Dict, R5),
    R5 == 13.0,

    validate('PersonEmail', 'test@example.com'),
    \+ validate('PersonEmail', 'invalid-email'),

    catch(forge('PersonEmail', 'invalid-email', _), error(validation_failed('PersonEmail')), true),

    writeln('Prolog tests passed').
