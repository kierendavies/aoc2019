#!/usr/bin/env swipl

:- initialization(main, main).

main :-
    read_string(user_input, "\n", "", _, Line1),
    read_string(user_input, "\n", "", _, Line2),
    split_string(Line1, ",", "", MoveStrings1),
    split_string(Line2, ",", "", MoveStrings2),
    parse_all_moves(MoveStrings1, Moves1),
    parse_all_moves(MoveStrings2, Moves2),

    reverse(Moves1, RevMoves1),
    reverse(Moves2, RevMoves2),
    path(RevMoves1, RevPoints1),
    path(RevMoves2, RevPoints2),
    list_to_ord_set(RevPoints1, PointSet1),
    list_to_ord_set(RevPoints2, PointSet2),
    ord_intersect(PointSet1, PointSet2, PointIntersection),

    delays(RevPoints1, Delays1, _),
    delays(RevPoints2, Delays2, _),
    maplist(delay_at_point(Delays1, Delays2), PointIntersection, CombinedDelays),
    sort(CombinedDelays, SortedDelays),
    [_, MinDelay | _] = SortedDelays,
    write(MinDelay), nl.

parse_move(MoveString, move(Dir, Dist)) :-
    string_chars(MoveString, [Dir|DistChars]),
    string_chars(DistString, DistChars),
    number_string(Dist, DistString).

parse_all_moves([], []).
parse_all_moves([MoveString | MoveStrings], [Move | Moves]) :-
    parse_move(MoveString, Move),
    parse_all_moves(MoveStrings, Moves).

move_point(Dir, point(X1, Y1), point(X2, Y2)) :-
    Dir = 'R',
    X2 is X1 + 1,
    Y2 is Y1.
move_point(Dir, point(X1, Y1), point(X2, Y2)) :-
    Dir = 'L',
    X2 is X1 - 1,
    Y2 is Y1.
move_point(Dir, point(X1, Y1), point(X2, Y2)) :-
    Dir = 'U',
    X2 is X1,
    Y2 is Y1 + 1.
move_point(Dir, point(X1, Y1), point(X2, Y2)) :-
    Dir = 'D',
    X2 is X1,
    Y2 is Y1 - 1.

path([], [point(0, 0)]).
path([move(_, 0) | RevMoves], RevPoints) :-
    path(RevMoves, RevPoints).
path([move(Dir, Dist) | RevMoves], [Point, LastPoint | RevPoints]) :-
    DecrDist is Dist - 1,
    path([move(Dir, DecrDist) | RevMoves], [LastPoint | RevPoints]),
    move_point(Dir, LastPoint, Point).

put_assoc_no_overwrite(Key, Assoc0, Value, Assoc) :-
    get_assoc(Key, Assoc0, Value),
    Assoc = Assoc0.
put_assoc_no_overwrite(Key, Assoc0, Value, Assoc) :-
    put_assoc(Key, Assoc0, Value, Assoc).

delays([point(0, 0)], Delays, 0) :-
    list_to_assoc([point(0, 0)-0], Delays).
delays([Point | RevPoints], Delays, MaxDelay) :-
    delays(RevPoints, PrevDelays, PrevMaxDelay),
    MaxDelay is PrevMaxDelay + 1,
    put_assoc_no_overwrite(Point, PrevDelays, MaxDelay, Delays).

delay_at_point(Delays1, Delays2, Point, Delay) :-
    get_assoc(Point, Delays1, Delay1),
    get_assoc(Point, Delays2, Delay2),
    Delay is Delay1 + Delay2.
