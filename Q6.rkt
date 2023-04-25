#lang racket

(require test-engine/racket-tests)

(struct bin (op fst snd) #:transparent) ; op is a symbol; fst, snd are ASTs.

(struct fun (param body) #:transparent) ; param is a symbol; body is an AST.

(struct app (fn arg) #:transparent) ; fn and arg are ASTs.

(struct seq (fst snd) #:transparent)

(struct set (var newval) #:transparent)


;; An AST is a (union bin fun app seq set).

(struct sub (name val) #:transparent)

;; A substitution is a (sub n v), where n is a symbol and v is a value.
;; An environment (env) is a list of substitutions.

(struct closure (var body envt) #:transparent)

;; A closure is a (closure v bdy env), where
;; v is a symbol, bdy is an AST, and env is a environment.
;; A value is a (union number closure void).


(struct result (val newstore) #:transparent)


;; parse: sexp -> AST

(define (parse sx)
  (match sx
    [`(with ((,nm ,nmd)) ,bdy) (app (fun nm (parse bdy)) (parse nmd))]
    [`(+ ,x ,y) (bin '+ (parse x) (parse y))]
    [`(* ,x ,y) (bin '* (parse x) (parse y))]
    [`(- ,x ,y) (bin '- (parse x) (parse y))]
    [`(/ ,x ,y) (bin '/ (parse x) (parse y))]
    [`(fun (,x) ,bdy) (fun x (parse bdy))]
    [`(seq ,x ,y) (seq (parse x) (parse y))]
    [`(set ,x ,y) (set x (parse y))]
    [`(,f ,x) (app (parse f) (parse x))]
    [x x]))

; op-trans: symbol -> (number number -> number)
; converts symbolic representation of arithmetic function to actual Racket function
(define (op-trans op)
  (match op
    ['+ +]
    ['* *]
    ['- -]
    ['/ /]))



;; lookup: symbol env -> value
;; looks up a substitution in an environment (topmost one)

(define (lookup var env)
  (cond
    [(empty? env) (error 'interp "unbound variable ~a" var)]
    [(symbol=? var (sub-name (first env))) (sub-val (first env))]
    [else (lookup var (rest env))]))

(define (lookup1 loc store)
  (cond
    [(empty? store) (error 'interp "no such address ~a" loc)]
    [(= loc (first (first store))) (second (first store))]
    [else (lookup1 loc (rest store))]))

;; interp: AST env -> value

(define (interp ast env store)
  (match ast
    [(fun v bdy) (result (closure v bdy env) store)]
    [(app fun-exp arg-exp)
       (match (interp fun-exp env store)
         [(result (closure v bdy cl-env) nstore)
          (match (interp arg-exp env nstore)
            [(result y nstore1)
             (define nl (length nstore1))
             (define ns (cons (list nl y) nstore1))
             (define ne (cons (sub v nl) cl-env))
             (interp bdy ne ns)])])]
    [(bin op x y)
     (match (interp x env store)
       [(result num1 nstore1)
        (match (interp y env nstore1)
          [(result num2 nstore2)
       (result ((op-trans op) num1 num2) nstore2)])])]
    [(seq x y)
     (match (interp x env store)
       [(result _ nstore1)
        (interp y env nstore1)])]
    [(set x y)
     (define lx (lookup x env))
     (match (interp y env store)
       [(result v nstore)
        (result (void) (cons (list lx v) nstore))])]
    [x (if (number? x)
           (result x store)
           (result (lookup1 (lookup x env) store) store))]))
             
; completely inadequate tests
(check-expect (parse '(* 2 3)) (bin '* 2 3))

(check-expect (interp (parse '(* 2 3)) empty empty) (result 6 empty))

(test)