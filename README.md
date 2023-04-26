# Faux-Racket-Interpreter

An interpreter for Faux Racket, written in Racket.

The code was modified based on the Univeristy of Waterloo CS146 Assignments. The starter code (presented in the file [AssignmentStarterCode.rkt]) was provided by CS 146 instructor team.

The abstract syntaxe tree, guildlines for using the program, and referenced assignments links are provided below.


## Table of Contents
- [Faux Racket Grammar](#faux-racket-grammar)
- [Basic Features](#basic-features)
- [Assignment Links](#assignment-links)

## Faux Racket Grammar
The Abstract Syntax Tree (presented in Haskell grammar) for Faux Racket below is provided by CS 146 instructor team on assignment page. <br>


_expr_ =  num  <br>
&emsp; &emsp; |  var  <br>
&emsp; &emsp; |  (+ _expr_ _expr_) <br>
&emsp; &emsp; |  (* _expr_ _expr_) <br>
&emsp; &emsp; |  (- _expr_ _expr_) <br>
&emsp; &emsp; |  (/ _expr_ _expr_) <br>
&emsp; &emsp; |  (fun (var) _expr_) <br>
&emsp; &emsp; |  (_expr_ _expr_) <br>
&emsp; &emsp; |  (ifzero _expr_ _expr_ _expr_) <br>
&emsp; &emsp; |  (with ((var _expr_)) _expr_) <br>
&emsp; &emsp; |  (rec ((var _expr_)) _expr_) <br>
&emsp; &emsp; |  (seq _expr_ _expr_) <br>
&emsp; &emsp; |  (set var _expr_) <br>
&emsp; &emsp; |  (box _expr_) <br>
&emsp; &emsp; |  (unbox _expr_) <br>
&emsp; &emsp; |  (setbox _expr_ _expr_) <br>



## Basic Features


## Assignment Links
