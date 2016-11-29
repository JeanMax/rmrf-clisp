(ql:quickload :rmrf)

(defpackage rmrf.app
  (:use :cl)
  (:import-from :lack.builder
                :builder)
  (:import-from :ppcre
                :scan
                :regex-replace)
  (:import-from :rmrf.web
                :*web*)
  (:import-from :rmrf.config
                :config
                :productionp
                :*static-directory*))
(in-package :rmrf.app)

(builder
 (:static
  :path (lambda (path)
          (if (ppcre:scan "^(?:/img/|/css/|/js/|/.*\\.html$|/robot\\.txt$|/favicon\\.ico$)" path)
              path
              nil))
  :root *static-directory*)
 (if (productionp)
     nil
     :accesslog)
 (if (getf (config) :error-log)
     `(:backtrace
       :output ,(getf (config) :error-log))
     nil)
 :session
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((datafly:*trace-sql* t))
           (funcall app env)))))
 *web*)
