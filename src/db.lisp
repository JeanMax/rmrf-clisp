(in-package :cl-user)
(defpackage rmrf.db
  (:use :cl)
  (:import-from :rmrf.config
                :config)
  (:import-from :datafly
                :*connection*)
  (:import-from :cl-dbi
                :connect-cached)
  (:export :connection-settings
           :db
           :with-connection
           :with-transaction))
(in-package :rmrf.db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'connect-cached (connection-settings db)))

(defmacro with-connection (conn &body body)
  `(let ((*connection* ,conn))
     ,@body))

(defmacro with-transaction (conn &body body)
  `(let ((*connection* ,conn))
     (cl-dbi:with-transaction *connection*
       ,@body)))
