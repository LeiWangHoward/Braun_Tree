;;braun tree, size

;;arithmetic
(include-book "arithmetic-5/top" :dir :system)

;;stree is a list, either a nil list or a list with four elements
;;nil | size left right data

;;define tree with size, size tree
(defun streep-null (tr)
;;  (declare (xargs :guard (streep tr)))
  (endp tr))

;;selector
;; size
(defun stree-size (tr)
;;  (declare (xargs :guard (streep tr)))
  (if (streep-null tr)
    0
    (first tr)))

;; left
(defun stree-left (tr)
;;  (declare (xargs
;;            :guard (and (streep tr)
;;                        (not (streep-null tr)))))
  (second tr))

;; right
(defun stree-right (tr)
;;  (declare (xargs
;;            :guard (and (streep tr)
;;                        (not (streep-null tr)))))
  (third tr))

(defun streep (tr)
;;  (declare (xargs :guard t))
  (if (true-listp tr)
    (if (streep-null tr)
      t
      (if (equal (len tr) 4)
        (let ((sz (stree-size tr))
              (lc (stree-left tr))
              (rc (stree-right tr)))
          (if (and (natp sz)
                   (streep lc)
                   (streep rc))
            (let ((lcsz (stree-size lc))
                  (rcsz (stree-size rc)))
              (equal sz (+ 1 lcsz rcsz)))
            nil))
        nil))
    nil))

(defun streep-leaf (tr)
;;  (declare (xargs :guard (streep tr)))
  (if (streep-null tr)
    nil
    (and (equal (stree-left tr) nil)
         (equal (stree-right tr) nil))))

;;tree size, iteration
(defun stree-size-it (tr)
;;  (declare (xargs :guard (streep tr)))
  (if (streep-null tr)
    0
    (+ 1  (stree-size-it (stree-left tr))
            (stree-size-it (stree-right tr)))))

;;tree size equivalence
(defthm stree-size-it=stree-size
  (implies (streep tr)
           (equal (stree-size-it tr) (stree-size tr)))
  :rule-classes nil)

;;braun tree
(defun brtreep (brtr)
;;  (declare (xargs :guard t))
  (if (streep brtr)
    (if (streep-null brtr)
      t
      (let ((lc (stree-left brtr))
            (rc (stree-right brtr)))
        (let ((lcsz (stree-size lc))
              (rcsz (stree-size rc)))
          (if (or (equal lcsz rcsz)
                  (equal lcsz (+ rcsz 1)))
            (and (brtreep lc) (brtreep rc))
            nil))))
    nil))

;;in brtree-diff, num must satisfy the condition
;; that size = num or size = num + 1
;; this function maybe not used
(defun stree-size-nump (brtr num)
;;  (declare (xargs :guard (and (streep brtr)
;;                              (natp num))))
  (let ((sz (stree-size brtr)))
    (or (equal sz num)
        (equal sz (+ num 1)))))

;;braun tree diff
(defun brtree-diff (brtr num)
;;  (declare (xargs :guard (and (natp num) (brtreep brtr) 
;;                               (stree-size-nump brtr num))))
  (if (stree-size-nump brtr num)
    (cond
     ((and (streep-null brtr) (zp num))
      0)
     ((and (streep-leaf brtr) (zp num))
      1)
     (t
      (if (oddp num)
        (brtree-diff (stree-left brtr) (/ (- num 1) 2))
        (brtree-diff (stree-right brtr) (/ (- num 2) 2)))))
    0))

   ;;braun tree size
   ;; the guard here cannot be verified
(defun brtree-size (brtr)
;;  (declare (xargs :guard (brtreep brtr)))
  (if (streep-null brtr)
    0
    (let ((m (brtree-size (stree-right brtr)))
         (s (stree-left brtr)))
          (+ 1 (* 2 m) (brtree-diff s m)))))
(defthm stree-size-return-nat
  (implies (streep tr)
           (natp (stree-size tr))))
;;disable stree* function
;; these functions needn't be rewritten
(in-theory (disable streep streep-leaf streep-null 
                   stree-left stree-right stree-size))#|ACL2s-ToDo-Line|#


;;theory about diff
#|
(defthm size+diff
  (implies (and (brtreep tr)
                (not (streep-null tr)))
           (equal (+ (stree-size (stree-right tr))
                     (brtree-diff (stree-left tr) 
                                  (stree-size (stree-right tr))))
                  (stree-size (stree-left tr)))))
|#
;;our final target
;; 1. Try to prove it on paper
;; 2. Try to prove it via ACL2

(defthm brtee-size-correct
  (implies (brtreep brtr)
           (equal (brtree-size brtr) (stree-size brtr)))
  :rule-classes nil)

#|
1. (IMPLIES (NOT (STREEP BRTR)) (:P BRTR))
2. (IMPLIES (AND (STREEP BRTR)
                   (NOT (STREEP-NULL BRTR))
                   (NOT (OR (EQUAL (STREE-SIZE (STREE-LEFT BRTR))
                                   (STREE-SIZE (STREE-RIGHT BRTR)))
                            (EQUAL (STREE-SIZE (STREE-LEFT BRTR))
                                   (+ (STREE-SIZE (STREE-RIGHT BRTR))
                                      1)))))
              (:P BRTR))
3. (IMPLIES (AND (STREEP BRTR)
                   (NOT (STREEP-NULL BRTR))
                   (OR (EQUAL (STREE-SIZE (STREE-LEFT BRTR))
                              (STREE-SIZE (STREE-RIGHT BRTR)))
                       (EQUAL (STREE-SIZE (STREE-LEFT BRTR))
                              (+ (STREE-SIZE (STREE-RIGHT BRTR)) 1)))
                   (NOT (BRTREEP (STREE-LEFT BRTR)))
                   (:P (STREE-LEFT BRTR)))
              (:P BRTR))
4. (IMPLIES (AND (STREEP BRTR)
                   (NOT (STREEP-NULL BRTR))
                   (OR (EQUAL (STREE-SIZE (STREE-LEFT BRTR))
                              (STREE-SIZE (STREE-RIGHT BRTR)))
                       (EQUAL (STREE-SIZE (STREE-LEFT BRTR))
                              (+ (STREE-SIZE (STREE-RIGHT BRTR)) 1)))
                   (BRTREEP (STREE-LEFT BRTR))
                   (:P (STREE-LEFT BRTR))
                   (:P (STREE-RIGHT BRTR)))
              (:P BRTR))
5. (IMPLIES (AND (STREEP BRTR) (STREEP-NULL BRTR))
              (:P BRTR))
|#
#|
brtree-size brtr
=
1 + 2 brtree-size rt + brtree-diff lt (brtree-size rt)
=
1 + brtree-size rt + 
(brtree-size rt + brtree-diff lt (brtree-size rt))
=
1 + brtree-size rt + brtree-size lt
|#
















