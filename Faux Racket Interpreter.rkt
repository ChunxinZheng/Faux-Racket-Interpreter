#lang racket

(require test-engine/racket-tests)

;; ---------------- Basic introduction ----------------

;; The code is modified based on the University of Waterloo CS146
;; Assignment Q5, Q6, and Q7. The starter code was provided by the CS146 instructor team.
;; This is an interpreter for Faux Racket (a pseudocode based on Racket).
;; More detailed information, including the grammar of Faux Racket,
;; is stated in the README file

;; --- Usage Examples ---

(check-expect (interp (parse '(with ((x 3)) (* x x))) empty empty) (result 9 '((0 3))))
(check-expect (interp (parse '(with ((y 5))
                                    (+ (with ((x 3)) (seq (set x 6) (+ y x))) y))) empty empty)
              (result 16 '((1 6) (1 3) (0 5))))


;; --- Basic Structures ---

(struct bin (op fst snd) #:transparent) ; op is a symbol; fst, snd are ASTs.
(struct fun (param body) #:transparent) ; param is a symbol; body is an AST.
(struct app (fn arg) #:transparent) ; fn and arg are ASTs.
(struct rec (nm nmd body) #:transparent)
(struct ifzero (t tb fb) #:transparent)
(struct seq (fst snd) #:transparent)
(struct set (var newval) #:transparent)
(struct newbox (exp) #:transparent)
(struct openbox (exp) #:transparent)
(struct setbox (bexp vexp) #:transparent)
;; An AST is a (union bin fun app seq newbox openbox setbox).

(struct sub (name val) #:transparent)
;; A substitution is a (sub n v), where n is a symbol and v is a value.
;; An environment (env) is a list of substitutions.

;; A store is a list of (list number value)
;; that maps addresses of variables to thire values.

(struct closure (var body envt) #:transparent)
;; A closure is a (closure v bdy env), where
;; v is a symbol, bdy is an AST, and env is a environment.
;; A value is a (result store (union number closure void)).

(struct result (val newstore) #:transparent)


;; ------------------- Parsing -------------------

;; parse: sexp -> AST
;; (parse sx) parses [sx] recursively for future interpretation

(define (parse sx)
  (match sx
    [`(with ((,nm ,nmd)) ,bdy) (app (fun nm (parse bdy)) (parse nmd))]
    [`(+ ,x ,y) (bin '+ (parse x) (parse y))]
    [`(* ,x ,y) (bin '* (parse x) (parse y))]
    [`(- ,x ,y) (bin '- (parse x) (parse y))]
    [`(/ ,x ,y) (bin '/ (parse x) (parse y))]
    [`(fun (,x) ,bdy) (fun x (parse bdy))]
    [`(rec ((,nm ,nmd)) ,body) (rec nm (parse nmd) (parse body))]
    [`(ifzero ,t ,tb ,fb) (ifzero (parse t) (parse tb) (parse fb))]
    [`(set ,x ,y) (set x (parse y))]
    [`(seq ,x ,y) (seq (parse x) (parse y))]
    [`(box ,x) (newbox (parse x))]
    [`(unbox ,x) (openbox (parse x))]
    [`(setbox ,x ,y) (setbox (parse x) (parse y))]
    [`(,f ,x) (app (parse f) (parse x))]
    [x x]))


;; ------------------- Interpreting -------------------

;; 
;; interp: AST env store -> value

(define (interp ast env store)
  (match ast
    [(fun v bdy) (result (closure v bdy env) store)]
    [(app fun-exp arg-exp)
       (match (interp fun-exp env store)
         [(result (closure v bdy cl-env) nstore)
          (match (interp arg-exp env nstore)
            [(result y nstore1)
             (define nl (length nstore1)) ;; creates a new address
             (define ns (cons (list nl y) nstore1)) ;; adds the address-value map to the store
             (define ne (cons (sub v nl) cl-env)) ;; adds the variable-address map to the environment
             (interp bdy ne ns)])])]
    [(bin op x y)
     (match (interp x env store)
       [(result num1 nstore1)
        (match (interp y env nstore1)
          [(result num2 nstore2)
       (result ((op-trans op) num1 num2) nstore2)])])]
    [(set x y)
     (define lx (lookup x env))
     (match (interp y env store)
       [(result v nstore)
        (result (void) (cons (list lx v) nstore))])]
    [(seq x y)
     (match (interp x env store)
       [(result _ nstore1)
        (interp y env nstore1)])]
    [(ifzero t tb fb)
     (match (interp t env store)
       [(result ans nstore) 
        (if (zero? ans) (interp tb env nstore) (interp fb env nstore))])]
    [(rec nm nmd body)
     (interp body (cons (sub nm (length store)) env) (cons (list (length store) nmd) store))]
    [(newbox x)
     (match (interp x env store)
     [(result v nstore)
      (define nl (length nstore))
      (result nl (cons (list nl v) nstore))])]
    [(openbox x)
     (match (interp x env store)
       [(result addr nstore)
     (result (lookup1 addr nstore) nstore)])]     
    [(setbox x y)
     (match (interp x env store)
       [(result addr _)
       (match (interp y env store)
       [(result v nstore)
     (result (void) (changeval addr v nstore))])])]
    [x (cond [(number? x) (result x store)]
             [else (define res (lookup1 (lookup x env) store))
                   (if (closure? res) res
                       (interp res env store))])]))



;; ------------------- Helper Functions -------------------

; op-trans: symbol -> (number number -> number)
; converts symbolic representation of arithmetic function to actual Racket function
(define (op-trans op)
  (match op
    ['+ +]
    ['* *]
    ['- -]
    ['/ /]))


;; lookup: symbol env -> number
;; looks up the address of a given variable in an environment (topmost one)
(define (lookup var env)
  (cond
    [(empty? env) (error 'interp "unbound variable ~a" var)]
    [(symbol=? var (sub-name (first env))) (sub-val (first env))]
    [else (lookup var (rest env))]))

;; lookup1: number store -> value
;; looks up the value of a given address in a store (topmost one)
(define (lookup1 loc store)
  (cond
    [(empty? store) (error 'interp "no such address ~a" loc)]
    [(= loc (first (first store))) (second (first store))]
    [else (lookup1 loc (rest store))]))

;; changeval: number value store -> store
;; produces a new store with the value of [nl] be changed into [v]
(define (changeval nl v store)
  (cond
    [(empty? store) (error 'interp "no such address ~a" nl)]
    [(= nl (first (first store))) (cons (list nl v) (rest store))]
    [else (cons (first store) (changeval nl v (rest store)))]))



;(test)