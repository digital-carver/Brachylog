/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
____            ____
\   \          /   /
 \   \  ____  /   /
  \   \/    \/   /
   \     /\     /     BRACHYLOG       
    \   /  \   /      A terse declarative logic programming language
    /   \  /   \    
   /     \/     \     Written by Julien Cumin - 2017
  /   /\____/\   \    https://github.com/JCumin/Brachylog
 /   /  ___   \   \
/___/  /__/    \___\
     
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


:- module(utils, [integer_value/2,
                  brachylog_prolog_variable/2,
                  length_/2,
                  prepend_string/2,
                  prepend_integer/2,
                  is_brachylog_list/1,
                  single_atom_code/2,
                  ceiled_square_root/2,
                  scompare/4,
                  if_/3,
                  (=)/3,
                  (#>)/3,
                  (===)/6
                 ]).

:- use_module(library(clpfd)).
    
    
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   INTEGER_VALUE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
integer_value('integer':Sign:I, E) :-
    integer_value('integer':Sign:I, 0, E, E).

integer_value('integer':Sign:[], N0, N, _) :-
    (   Sign = 'positive',
        N #= N0
    ;   Sign = 'negative',
        N #= - N0
    ).
integer_value('integer':Sign:[H], N0, N, M) :-
    H in 0..9,
    N1 #= H + N0 * 10,
    abs(M) #>= abs(N1),
    integer_value('integer':Sign:[], N1, N, M).
integer_value('integer':Sign:[H,I|T], N0, N, M) :-
    H in 0..9,
    N1 #= H + N0 * 10,
    abs(M) #>= abs(N1),
    integer_value('integer':Sign:[I|T], N1, N, M).
    

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_PROLOG_VARIABLE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_prolog_variable('integer':I, I) :- !.
brachylog_prolog_variable('float':F, F) :- !.
brachylog_prolog_variable('string':S, String) :- !,
    escape_string_list(S, T),
    atomic_list_concat(T, U),
    atomic_list_concat(['"',U,'"'], A),
    term_to_atom(String, A).
brachylog_prolog_variable(List, PrologList) :-
    is_list(List),
    maplist(brachylog_prolog_variable, List, PrologList).
    
escape_string_list([], []).
escape_string_list(['"'|T], ['\\','"'|T2]) :-
    escape_string_list(T, T2).
escape_string_list(['\\'|T], ['\\','\\'|T2]) :-
    escape_string_list(T, T2).
escape_string_list([H|T], [H|T2]) :-
    H \= '"',
    H \= '\\',
    escape_string_list(T, T2).

    
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LENGTH_
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
length_(Length, List) :-
    length(List, Length).
   
   
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   PREPEND_STRING
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
prepend_string(S, 'string':S).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   PREPEND_INTEGER
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
prepend_integer(I, 'integer':I).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IS_BRACHYLOG_LIST
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
is_brachylog_list([]).
is_brachylog_list([_|_]).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SINGLE_ATOM_CODE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
single_atom_code(A, C) :-
    catch(atom_codes(A, [C]), _, false).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CEILED_SQUARE_ROOT
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
ceiled_square_root(0, 0).
ceiled_square_root(N0, Root) :-
        N1 #= N0 - 1,
        Max in 0..N1,
        R0^2 #= Max,
        Root #= Root0 + 1,
        fd_sup(R0, Root0).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SCOMPARE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
scompare(@>, TypeX:X, TypeY:Y, TypeZ:Z) :-
    (   X @> Y ->
        TypeZ:Z = TypeX:X
    ;   TypeZ:Z = TypeY:Y
    ).
scompare(@<, TypeX:X, TypeY:Y, TypeZ:Z) :-
    (   X @< Y ->
        TypeZ:Z = TypeX:X
    ;   TypeZ:Z = TypeY:Y
    ).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF_/3
   Credits to Ulrich Neumerkel
   See: http://www.complang.tuwien.ac.at/ulrich/Prolog-inedit/sicstus/reif.pl
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
if_(If_1, Then_0, Else_0) :-
    call(If_1, T),
    (   T == true -> Then_0
    ;   T == false -> Else_0
    ;   nonvar(T) -> throw(error(type_error(boolean,T),
                                 type_error(call(If_1,T),2,boolean,T)))
    ;   throw(error(instantiation_error,instantiation_error(call(If_1,T),2)))
    ).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   (=)/3
   Credits to Ulrich Neumerkel
   See: http://www.complang.tuwien.ac.at/ulrich/Prolog-inedit/sicstus/reif.pl
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
=(X, Y, T) :-
    (   X == Y -> T = true
    ;   X \= Y -> T = false
    ;   T = true, X = Y
    ;   T = false,
        dif(X, Y)
    ).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   (#>)/3
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
#>(X, Y, T) :-
    zcompare(C, X, Y),
    greater_true(C, T).

greater_true(>, true).
greater_true(<, false).
greater_true(=, false).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   (===)/6
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
===(X1, Y1, X2, Y2, T1, T) :-
    (   X1 == Y1 -> T1 = true, T = true
    ;   X1 \= Y1 -> T1 = true, T = false
    ;   X2 == Y2 -> T1 = false, T = true
    ;   X2 \= Y2 -> T1 = false, T = false
    ;   T1 = true, T = true, X1 = Y1
    ;   T1 = true, T = false, dif(X1, Y1)
).
