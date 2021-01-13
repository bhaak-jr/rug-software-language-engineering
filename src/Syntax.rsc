module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id name "{" Question* questions "}";

syntax Question
  = Str Id ":" Type
  | Str Id ":" Type "=" Expr
  | "if" "(" Expr ")" "{" Question* "}"
  | "if" "(" Expr ")" "{" Question* "}" "else" "{" Question* "}"
  ;

// Based on: https://en.cppreference.com/w/c/language/operator_precedence
syntax Expr 
  = Id \ Reserved
  | Bool
  | Int
  | Str
  > bracket "(" Expr ")"
  > right "!" Expr
  > left (
    Expr "*" Expr |
    Expr "/" Expr )
  > left (
    Expr "+" Expr |
    Expr "-" Expr )
  > left (
    Expr "\<" Expr |
    Expr "\<=" Expr |
    Expr "\>" Expr |
    Expr "\>=" Expr )
  > left (
    Expr "==" Expr |
    Expr "!=" Expr )
  > left Expr "&&" Expr
  > left Expr "||" Expr
  ;
  
syntax Type
  = "boolean"
  | "integer"
  | "string"
  ;
  
lexical Str = [\"] ![\"]* [\"];

lexical Int
  = [\-]?[1-9][0-9]*
  | [0]
  ;

lexical Bool
  = "true"
  | "false"
  ;
  
keyword Reserved
  = "true"
  | "false"
  | "form"
  | "boolean"
  | "integer"
  | "string"
  ;
