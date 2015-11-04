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

let parse_command lexbuf = 
    try Parser.command_option Lexer.read lexbuf with
    | e -> report_position lexbuf.Lexing.lex_curr_p; raise e

let report_result = function
    | None ->
        printf "no.\n"
    | Some sigma ->
        printf "yes.\n";
        Unifier.print sigma

let rec parse_and_execute program lexbuf = 
    match parse_command lexbuf with
    | None -> program
    | Some (Command.Clause clause) ->
        parse_and_execute (Program.add clause program) lexbuf
    | Some (Command.Query goal) ->
        Execute.execute program goal |> report_result;
        parse_and_execute program lexbuf
    | Some (Command.Unify (t0, t1)) ->
        Term.unify t0 t1 |> report_result;
        parse_and_execute program lexbuf

let load_file program filename =
    let in_channel = open_in filename in
    try
        let lexbuf = from_channel in_channel in
        lexbuf.lex_curr_p <- init_position filename;
        let program = parse_and_execute program lexbuf in
        close_in in_channel;
        program
    with
    | e -> close_in in_channel; raise e
    

let rec load_files program = function
    | [] ->
        ()
    | filename :: filenames ->
        let program = load_file program filename in
        load_files program filenames

let main = function
    | _ :: filenames ->
        load_files Syntax.Program.empty filenames 
    | [] ->
        ()

let () = Sys.argv |> Array.to_list |> main

