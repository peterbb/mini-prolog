add(z, X, X).
add(s(X), Y, s(Z)) :- add(X, Y, Z).

%unify(X, z).
%unify(X, Y).
%unify(X, X).
%unify(X, s(X)).

? add(s(s(z)), s(s(s(s(z)))), X).

append(nil, X, X).
append(cons(X, XS), YS, cons(X, ZS)) :- append(XS, YS, ZS).
? append(cons(a, cons(b, nil)), cons(c, cond(d, nil)), Y).

? append(nil, X, Y).

append2(diff(I, M), diff(M, O), diff(I, O)).
? append2(diff(cons(a, cons(b, cons(c, E))), E),
          diff(cond(d, cons(e, cons(f, M))), M),
          O).

## Meta programming.

solve(true).
solve(and(A, B)) :- solve(A), solve(B).
solve(atom(Head)) :- clause(Head, Body), solve(Body).

#clause(add(z, X, X), true).
clause(add(z, X, X), true).
clause(add(s(X), Y, s(Z)), atom(add(X, Y, Z))).

? solve(atom(add(s(z), z, X))).


