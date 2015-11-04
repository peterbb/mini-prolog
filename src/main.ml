open Printf
open Syntax
open Lexing

let report_position { pos_fname; pos_lnum; pos_bol; pos_cnum } = 
    eprintf "error in %s line %d char %d.\n"
        pos_fname pos_lnum (pos_cnum - pos_bol)

let init_position filename = {
        pos_fname = filename;
        pos_lnum = 1;
        pos_bol = 0;
        pos_cnum = 0
}

let rec run_file2 program lexbuf = 
    match Parser.command_option Lexer.read lexbuf with
    | None -> program
    | Some (Command.Clause clause) ->
        run_file2 (Program.add clause program) lexbuf
    | Some (Command.Query goal) ->
        begin match Execute.execute program goal with
        | None ->
            printf "no\n"
        | Some sigma ->
            printf "yes\n";
            Unifier.print sigma
        end;
        run_file2 program lexbuf
    | Some (Command.Unify (t0, t1)) ->
        begin match Term.unify t0 t1 with
        | None ->
            printf "no\n"
        | Some sigma ->
            printf "yes:\n";
            Unifier.print sigma
        end;
        run_file2 program lexbuf

let run_file program filename =
    let in_channel = open_in filename in
    let lexbuf = from_channel in_channel in
    lexbuf.lex_curr_p <- init_position filename;
    try
        let program = run_file2 program lexbuf in
        close_in in_channel;
        program
    with
    | e ->
        close_in in_channel;
        report_position lexbuf.Lexing.lex_curr_p;
        raise e
    

let rec run_files program = function
    | [] ->
        ()
    | filename :: filenames ->
        let program = run_file program filename in
        run_files program filenames

let main = function
    | _ :: filenames ->
        run_files Syntax.Program.empty filenames 
    | [] ->
        ()

let () = Sys.argv |> Array.to_list |> main

