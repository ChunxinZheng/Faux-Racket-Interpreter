# Pseudo-Interpreter (Faux Racket)

An interpreter for Faux Racket, written in Racket.

The code was modified based on the Univeristy of Waterloo CS146 Assignments. The starter code (presented in the file [AssignmentStarterCode.rkt]) was provided by CS 146 instructor team.

The abstract syntaxe tree, guildlines for using the program, and referenced assignments links are provided below.


## Table of Contents
- [Faux Racket Grammar](#faux-racket-grammar)
- [Basic Features](#basic-features)
- [Environment and Store](#environment-and-store)
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
&emsp; &emsp; |  (with ((var _expr_)) _expr_) <br>
&emsp; &emsp; |  (rec ((var _expr_)) _expr_) <br>
&emsp; &emsp; |  (ifzero _expr_ _expr_ _expr_) <br>
&emsp; &emsp; |  (set var _expr_) <br>
&emsp; &emsp; |  (seq _expr_ _expr_) <br>
&emsp; &emsp; |  (box _expr_) <br>
&emsp; &emsp; |  (unbox _expr_) <br>
&emsp; &emsp; |  (setbox _expr_ _expr_) <br>



## Basic Features

(fun (var) _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; Creates a [```lambda```][1] function with parameter [var] and body [expr] <br>
(_expr1_ _expr2_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  &nbsp; Takes [_expr2_] as the function argument, apply it to [_expr1_] (a ```fun```) <br>
(with ((var _expr1_)) _expr2_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; Resembles [```let```][2] in Racket <br>
(rec ((var _expr_)) _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; Remembles [```letrec```][3] in Racket <br>
(ifzero _expr1_ _expr_ _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; A special case for an [```if```][4] in Racket that checks if [_expr1_] is zero <br>
(set var _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  Remembles [```set!```][5] in Racket <br>
(seq _expr_ _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  Remembles [```begin```][6] in Racket <br>
(box _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  Remembles [```box```][7] in Racket <br>
(unbox _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  Remembles [```unbox```][8] in Racket <br>
(setbox _expr_ _expr_) &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  Remembles [```set-box!```][9] in Racket  <br>

[1]: https://docs.racket-lang.org/reference/lambda.html#%28form._%28%28lib._racket%2Fprivate%2Fbase..rkt%29._lambda%29%29
[2]: https://docs.racket-lang.org/reference/let.html#%28form._%28%28lib._racket%2Fprivate%2Fletstx-scheme..rkt%29._let%29%29
[3]: https://docs.racket-lang.org/reference/let.html#%28form._%28%28lib._racket%2Fprivate%2Fletstx-scheme..rkt%29._letrec%29%29
[4]: https://docs.racket-lang.org/reference/if.html#%28form._%28%28quote._~23~25kernel%29._if%29%29
[5]: https://docs.racket-lang.org/reference/set_.html#%28form._%28%28quote._~23~25kernel%29._set%21%29%29
[6]: https://docs.racket-lang.org/reference/begin.html#%28form._%28%28quote._~23~25kernel%29._begin%29%29
[7]: https://docs.racket-lang.org/reference/boxes.html#%28def._%28%28quote._~23~25kernel%29._box%29%29
[8]: https://docs.racket-lang.org/reference/boxes.html#%28def._%28%28quote._~23~25kernel%29._unbox%29%29
[9]: https://docs.racket-lang.org/reference/boxes.html#%28def._%28%28quote._~23~25kernel%29._set-box%21%29%29


## Environment and Store
This interpreter uses two layers of mapping, with the environment mapping a variable name to its memory location in the store, and the store mapping the address to its values). This model is a good reflection of how actual Racket is implemented by lower level languages. We will discuss below about the logistics of this model. <br>
### Env
If we have narrowed the range of the interpreter a bit more (although the subset of Racket chosen is already small enough), the store would've been unnecessary. Making the environment mapping a variable name directly to its value can perfectly handle everything except for possible aliasing brought by the boxes. Referencing a variable can be easily implemented by a lookup function. On another note, ```set``` can simply change the mapping between the variable name and the corresponding value. Apparently, there's no need for another layer of mapping at this stage. <br>
### Store
Consider the following:
```racket 
(with ((x (box 0))
      (with ((y x))
            (seq (setbox x 5)
                 (unbox y)))))
```
The code above should produce 5 when we unbox y, note there's aliasing between x and y here. This is not achievable with one layer of mapping since with that there's no way to link change in the boxed content x to change in the boxed content of y. We will thus modify environment to mapping variables to their locations, this environment is not modified, and does not need to be returned (we do not need to worry about local binding when returning). Furthermore, we will have a store mapping locations to values, values are updated while locations are not. Aliasing can thus be achieved by mapping two variables to the same location. 



## Assignment Links

CS146 Assignment [Q5][10] <br>
CS146 Assignment [Q6][11] <br>
CS146 Assignment [Q7][12] <br>

[10]: https://github.com/ChunxinZheng/Faux-Racket-Interpreter/issues/1#issue-1687570041
[11]: https://github.com/ChunxinZheng/Faux-Racket-Interpreter/issues/2#issue-1687570589
[12]: https://github.com/ChunxinZheng/Faux-Racket-Interpreter/issues/3#issue-1687571059
