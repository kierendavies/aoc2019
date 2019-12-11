#!r6rs
(import (rnrs))

(define pi (atan 0 -1))

(define (curry f . xs)
  (lambda ys
    (apply f (append xs ys))))

(define (quick-sort xs lt?)
  (if (< (length xs) 2)
    xs
    (let*-values (((pivot) (car xs))
                  ((left right) (partition (lambda (x) (lt? x pivot))
                                           (cdr xs))))
      (append (quick-sort left lt?)
              (list pivot)
              (quick-sort right lt?)))))

(define (group-by key xs)
  (let ((ht (make-hashtable equal-hash equal?)))
    (for-all (lambda (x)
               (hashtable-update! ht
                                  (key x)
                                  (lambda (val) (append val (list x)))
                                  '()))
             xs)
    ht))

(define (gcd x y)
  (if (zero? y)
      x
      (gcd y (mod x y))))

(define (count-distinct xs)
  (let count-distinct-acc ((c 0)
                           (xs xs))
    (cond ((null? xs)
            c)
          ((member (car xs) (cdr xs))
            (count-distinct-acc c (cdr xs)))
          (else
            (count-distinct-acc (+ c 1) (cdr xs))))))

(define (argmax key xs)
  (let argmax-acc ((max-elem (car xs))
                   (max-key (key (car xs)))
                   (xs (cdr xs)))
    (cond ((null? xs)
            max-elem)
          ((> (key (car xs)) max-key)
            (argmax-acc (car xs)
                        (key (car xs))
                        (cdr xs)))
          (else
            (argmax-acc max-elem
                        max-key
                        (cdr xs))))))

(define (index-of xs x)
  (let index-of-acc ((i 0)
                     (xs xs))
    (cond ((null? xs)
            #f)
          ((equal? (car xs) x)
            i)
          (else
            (index-of-acc (+ i 1) (cdr xs))))))

(define (read-grid)
  (let read-grid-acc ((points '())
                      (x 0)
                      (y 0))
    (let ((c (read-char)))
      (cond ((eq? c #\#)
              (read-grid-acc (cons (list x y) points)
                             (+ x 1)
                             y))
            ((eq? c #\.)
              (read-grid-acc points
                             (+ x 1)
                             y))
            ((eq? c #\newline)
              (read-grid-acc points
                             0
                             (+ y 1)))
            ((eof-object? c)
              points)))))

(define (direction p q)
  (let* ((x (- (car q)
               (car p)))
         (y (- (cadr q)
               (cadr p)))
         (d (abs (gcd x y))))
    (if (zero? d)
      '(0 0)
      (list (/ x d) (/ y d)))))

(define (count-visible points p)
  (let ((dirs (map (curry direction p)
                   points)))
    (- (count-distinct dirs) 1)))

(define (angle dir)
  (let* ((x (car dir))
         (y (cadr dir))
         (a (atan x (- y))))
    (if (< a 0)
      (+ a pi pi)
      a)))

(define (distance p q)
  (let ((x (- (car q)
              (car p)))
        (y (- (cadr q)
              (cadr p))))
    (sqrt (+ (* x x)
             (* y y)))))

(let* ((points (reverse (read-grid)))
       (station (argmax (curry count-visible points) points))
       (targets-by-dist
         (quick-sort (filter (lambda (p) (not (equal? station p)))
                             points)
                     (lambda (p q)
                       (< (distance station p)
                          (distance station q)))))
       (direction-groups (group-by (curry direction station)
                                   targets-by-dist))
       (targets-by-vaporisation
         (quick-sort targets-by-dist
                     (lambda (p q)
                       (let* ((dir-p (direction station p))
                              (dir-q (direction station q))
                              (rank-p (index-of (hashtable-ref direction-groups dir-p '()) p))
                              (rank-q (index-of (hashtable-ref direction-groups dir-q '()) q)))
                         (or (< rank-p rank-q)
                             (and (= rank-p rank-q)
                                  (< (angle dir-p) (angle dir-q))))))))
       (target-200 (list-ref targets-by-vaporisation 199)))
  (display (+ (* (car target-200) 100) (cadr target-200)))
  (display "\n")
)
