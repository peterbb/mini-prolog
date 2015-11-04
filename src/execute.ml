open Printf
open Syntax

let unify {Clause. head; body } atom rest_goal =
    match Atom.unify head atom with
    | None -> None
    | Some sigma -> Some (sigma, Goal.apply_unifier sigma (body @ rest_goal))

let execute program goal = 
    let open Syntax in

    let fresh = ref 0 in

    let refresh clause = 
        fresh := 1 + !fresh;
        Clause.refresh !fresh clause in

    let rec exec goal sigma =
        match goal with
        | [] -> Some sigma
        | atom :: goal -> try_clauses atom goal sigma program
    and try_clauses atom goal sigma = function
        | [] -> None
        | clause :: rest_clauses ->
            begin match unify (refresh clause) atom goal with
            | None -> try_clauses atom goal sigma rest_clauses
            | Some (sigma', new_goal) ->
                let sigma'' = Unifier.compose sigma sigma' in
                begin match exec new_goal sigma'' with
                | Some sigma -> Some sigma
                | None -> try_clauses atom goal sigma rest_clauses
                end
            end
    in exec goal VM.empty

