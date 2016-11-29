(in-package :cl-user)
(defpackage rmrf-asd
  (:use :cl :asdf))
(in-package :rmrf-asd)

(defsystem rmrf
  :version "0.1"
  :author "JeanMax"
  :license "BeerWare"
  :depends-on (:clack
               :lack
               :caveman2
               :envy
               :cl-ppcre
               :uiop

               ;; for @route annotation
               :cl-syntax-annot

               ;; HTML Template
               :djula

               ;; for DB
               :datafly
               :sxql

               ;; Password hashing
               :cl-pass)
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db" "model"))
                 (:file "web" :depends-on ("view" "model"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "model" :depends-on ("db"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (load-op rmrf-test))))
