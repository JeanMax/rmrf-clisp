(in-package :cl-user)
(defpackage rmrf-test-asd
  (:use :cl :asdf))
(in-package :rmrf-test-asd)

(defsystem rmrf-test
  :author "JeanMax"
  :license "BeerWare"
  :depends-on (:rmrf
               :prove)
  :components ((:module "t"
                :components
                ((:file "rmrf"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
