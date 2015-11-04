open Printf

module Var = struct
    module M = struct
        type t = string * int
        let compare (s0, n0) (s1, n1) =
            match compare s0 s1 with
            | 0 -> compare n0 n1
            | x -> x
    end
    include M

    let from_string s = (s, 0)

    let refresh k (s, _) = (s, k)

    module Map = struct 
        include Map.Make(M)
    end

    let to_string = function
        | (s, 0) -> s
        | (s, k) -> Printf.sprintf "%s#%d" s k
end

module VM = Var.Map

module TermCore = struct
    type t =
        | Var of Var.t
        | Const of string * t list

    let rec to_string = function
        | Var x -> Var.to_string x
        | Const (f, []) -> f
        | Const (f, ts) ->
            let args = String.concat ", " (List.map to_string ts) in
            Printf.sprintf "%s(%s)" f args

    let rec apply_unifier sigma = function
        | Var x when VM.mem x sigma ->
            VM.find x sigma
        | Var x ->
            Var x
        | Const (r, ts) ->
            Const (r, List.map (apply_unifier sigma) ts)
end

module Unifier = struct
    type t = TermCore.t VM.t

    let print sigma =
        let f k t = Printf.printf "%s = %s\n"
                (Var.to_string k) (TermCore.to_string t) in
        VM.iter f sigma

    let compose m0 m1 =
        let f x t0 t1 = match t0, t1 with
            | None, Some t -> Some t
            | Some t, _ -> Some (TermCore.apply_unifier m1 t)
            | _ -> failwith "Unifier.compose match"
        in Var.Map.merge f m0 m1
end

module Term = struct
    include TermCore

    let rec refresh k = function
        | Var x -> Var (Var.refresh k x)
        | Const (f, ts) -> Const (f, List.map (refresh k) ts)

    let rec free_in x = function
        | Var y -> x = y
        | Const (_, ts) -> List.exists (free_in x) ts

    let rec unify t0 t1 = match t0, t1 with
        | Var x, _ when not (free_in x t1) ->
            Some (VM.singleton x t1)
        | _, Var x when not (free_in x t0) ->
            Some (VM.singleton x t0)
        | Var x, Var y when x = y ->
            Some VM.empty
        | Const (f0, ts0), Const (f1, ts1) when f0 = f1 ->
            unify_list ts0 ts1
        | _, _ ->
            None
    and unify_list ts0 ts1 = match ts0, ts1 with
        | [], [] ->
            Some VM.empty
        | (t0::ts0), (t1::ts1) ->
            begin match unify t0 t1 with
            | None -> None
            | Some sigma ->
                let f t = apply_unifier sigma t in
                begin match unify_list (List.map f ts0) (List.map f ts1) with
                | None -> None
                | Some sigma' ->  Some (Unifier.compose sigma sigma')
                end
            end
        | _ -> None
end


module Atom = struct
    type t = Atom of string * Term.t list

    let unify a0 a1 = match a0, a1 with
        | Atom (r0, ts0), Atom (r1, ts1) when r0 = r1 ->
            Term.unify_list ts0 ts1
        | _ -> None

    let apply_unifier sigma (Atom (r, ts)) =
        Atom (r, List.map (Term.apply_unifier sigma) ts)

    let refresh k (Atom (r, ts)) =
        Atom (r, List.map (Term.refresh k) ts)

    let to_string (Atom (r, ts)) =
        sprintf "%s(%s)" r (String.concat ", " (List.map Term.to_string ts))
end

module Goal = struct
    type t = Atom.t list

    let apply_unifier sigma = List.map (Atom.apply_unifier sigma)

    let refresh k = List.map (Atom.refresh k)

    let to_string goal =
        String.concat ", " (List.map Atom.to_string goal)
end

module Clause = struct
    type t = { head : Atom.t ; body : Goal.t }

    let refresh k { head; body } = 
        let head = Atom.refresh k head in
        let body = Goal.refresh k body in
        { head; body }
end

module Program = struct
    type t = Clause.t list

    let empty = []

    let add clause program = clause :: program
end

module Command = struct
    type t = 
        | Clause of Clause.t
        | Query  of Goal.t
        | Unify  of Term.t * Term.t
end

