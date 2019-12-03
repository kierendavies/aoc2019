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
    path(RevMoves1, Points1),
    path(RevMoves2, Points2),
    list_to_ord_set(Points1, PointSet1),
    list_to_ord_set(Points2, PointSet2),
    ord_intersect(PointSet1, PointSet2, PointIntersection),
    maplist(dist_from_origin, PointIntersection, Dists),
    sort(Dists, SortedDists),
    [_, MinDist | _] = SortedDists,
    write(MinDist), nl.

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

dist_from_origin(point(X, Y), D) :-
    D is abs(X) + abs(Y).
