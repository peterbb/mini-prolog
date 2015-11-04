# Mini prolog

This is an implementation of a of logical programming language with
horn clauses. It is implemented in ~350 lines of ocaml code, and
was written over the course of a few hours.

## Syntax
### Terms
A term is either a variable or a function application. A variable is
written with an initial capital letter, e.g. `X`, `Rest`.
A function name is written with an initial lower case letter,
e.g. `f`, `cons`. A function application is a function name followed
by a comma-separated list of terms which are enclosed with parenthesis,
e.g. `cons(Head, Tail)`, `zero()`.

Writing just a function name without the argument list
is shorthand for an application with the empty argument list,
e.g. `zero` is short for `zero()`. The grammar for terms is:

    <term> ::= <var> | <fun-name> <args>?
    <args> ::=  "("  ( <term> ( ", " <term> )* )?   ")"

### Formulas
A relation name is an identifiers which an initial lower case letter,
e.g. `append` and `add`.
An atomic formula is a relation name followed by a comma-separated
list of terms, enclosed in parenthesis, e.g. `append(nil, X, X)`.
A query or a body is a comma-separated list of atomic formulas.

    <atom> ::= <rel-name> <args>
    <body> ::= ( <atom> ( ", " <atom> ")* )?



### Programs and Commands
A program is a sequence of commands.
A command is always terminated by a full stop/period.
There are currently four commands: facts, rules, queries, and unification.

    <program> ::= ( <command> "." )*
    <command> ::= <fact> | <rule> | <query> | <unification>

#### Facts and rules
An atomic formula and a body separated by `:-` is a rule.
A fact is an atomic formula, and it is a short hand syntax
for a clause with an empty body, e.g. `add(z, X, X)` is 
short hand for `add(z, X, X) :-.`. The syntax of facts and rules is:

    <fact> ::= <atom>
    <rule> ::= <atom> ":-" <body>

#### Query
A query is a question mark followed by a body.
The syntax is:

    <query> ::= "?" <body>

#### Unification
A unification request has the form:

    <unification> ::= "%unify(" <term> "," <term> ")"

## Semantics
The commands in a program is executed in the order they appear, i.e. from 
top to bottom. An ordered list of clauses are stored during execution.

When encountering a fact or a rule, the clause is added to the front
of the list of the clauses. Facts are translated into rules.

When a query is encountered, a typical prolog-proof search is executed,
using the list of clauses up to this point as the program, and
the body given by the query as the goal.
The goal is solved from left to right, new goals are added to the left,
and clauses for resolution is search from the latest to the oldest.

When encountering a unification problem, the two terms are tried
unified. If they are unified, `yes` is printed, followed by the unifing
substitution. Otherwise `no` is printed.

