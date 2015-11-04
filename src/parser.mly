%token <string> LOWER_ID UPPER_ID
%token COLONDASH COMMA DOT QUESTIONMARK
%token LPAR RPAR
%token UNIFY
%token EOF

%{ open Syntax %}

%start <Syntax.Command.t option> command_option
%%

command_option:
    | command = command
        { Some command }
    | EOF
        { None }

command :
    | head = atom DOT
        { let open Clause in Command.Clause { head; body = [] } }
    | head = atom COLONDASH body = atom_list DOT
        { let open Clause in Command.Clause { head; body } }
    | QUESTIONMARK atom_list = atom_list DOT
        { Command.Query atom_list }
    | UNIFY LPAR t0 = term COMMA t1 = term RPAR DOT
        { Command.Unify (t0, t1) }

atom_list:
    | atom_list = separated_nonempty_list(COMMA, atom)
        { atom_list }

atom :
    | r = LOWER_ID LPAR ts = term_list RPAR
        { Atom.Atom (r, ts) }

term_list:
    | ts = separated_nonempty_list(COMMA, term)
        { ts }

term:
    | x = UPPER_ID
        { Term.Var (Var.from_string x) }
    | f = LOWER_ID
        { Term.Const (f, []) }
    | f = LOWER_ID LPAR ts = term_list RPAR
        { Term.Const (f, ts) }

