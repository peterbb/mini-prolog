{
open Lexing
open Parser
}

let whitespace = [' ' '\t']+
let newline = "\n" | "\r" | "\r\n"
let tail = (['a'-'z''A'-'Z''0'-'9'] | '_' | '-')*
let lid = ['a'-'z'] tail
let uid = ['A'-'Z'] tail
let command = "%" lid

rule read = 
    parse
    | whitespace                    { read lexbuf }
    | newline                       { new_line lexbuf; read lexbuf }
    | "#"                           { skip_comment lexbuf }
    | "("                           { LPAR }
    | ")"                           { RPAR }
    | "."                           { DOT }
    | ","                           { COMMA }
    | ":-"                          { COLONDASH }
    | "?"                           { QUESTIONMARK }
    | lid                           { LOWER_ID (Lexing.lexeme lexbuf) }
    | uid                           { UPPER_ID (Lexing.lexeme lexbuf) }
    | command                       { match Lexing.lexeme lexbuf with
                                      | "%unify" -> UNIFY
                                      | _ -> failwith "unknown command" }
    | eof                           { EOF }
and skip_comment =
    parse
    | newline                       { new_line lexbuf; read lexbuf }
    | _                             { skip_comment lexbuf }
    | eof                           { EOF }

