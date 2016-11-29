(in-package :cl-user)
(defpackage rmrf.web
  (:use :cl
        :caveman2
        :rmrf.config
        :rmrf.view
        :rmrf.db
        :rmrf.model
        :datafly
        :sxql)
  (:import-from :rmrf.model
                :create-user-table
                :add-user
                :check-password
                :authenticate-user)
  (:export :*web*))
(in-package :rmrf.web)

;; for @route annotation
;; (syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defconstant moved-permanently 301 "Won't request the original uri again.")
(defconstant see-other 303 "POST/PUT/DELETE response.")
(defconstant temporary-redirect 307 "Still use original uri")

;; DEBUG
(defroute test "/test" ()
  (format t "zboub:~A" (gethash :user-id *session*)))

;; (defroute trailing-slash-redirect ("^(.*)/+$" :regexp t) (&key captures)
;;   (redirect (first captures) moved-permanently)
;;   "")

(defroute index "/" ()
  (render #P"index.html"))

(defroute welcome "/welcome/:name" (&key name)
  (render #P"index.html" `(:name ,name)))

(defroute bye "/bye" ()
  (render #P"index.html"))

(defroute register ("/register" :method :GET) ()
  (if (gethash :user-id *session*)
      (progn (redirect "/welcome/test" temporary-redirect) "")
      (render #P"register.html")))

(defroute login ("/login" :method :GET) ()
  (if (gethash :user-id *session*)
      (progn (redirect "/welcome/test" temporary-redirect) "")
      (render #P"login.html")))

(defroute register-post ("/register" :method :POST) (&key _parsed)
  (let ((email (cdr (assoc "email" (cdar _parsed) :test #'string=)))
        (password (cdr (assoc "password" (cdar _parsed) :test #'string=)))
        (password2 (cdr (assoc "password2" (cdar _parsed) :test #'string=)))
        (error-msg))
    (setq error-msg (check-password password password2))
    (unless error-msg
      (setq error-msg (add-user email password)))
    (if error-msg
        (render #P"register.html" `(:error ,error-msg :email ,email))
        (progn (redirect (format nil "/welcome/~A" (quri:url-encode email)) see-other) ""))))

(defroute login-post ("/login" :method :POST) (&key _parsed)
  (let ((email (cdr (assoc "email" (cdar _parsed) :test #'string=)))
        (password (cdr (assoc "password" (cdar _parsed) :test #'string=)))
        (id))
    (if (setq id (authenticate-user email password))
        (progn
          (setf (gethash :user-id *session*) id)
          (progn (redirect "/" see-other) ""))
        (render #P"login.html" `(:error "Invalid email and/or password." :email ,email)))))

(defroute logout "/logout" ()
  (setf (gethash :user-id *session*) nil)
  (redirect "/bye" temporary-redirect)
  "")



;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))

(defmethod on-exception ((app <web>) (code (eql 500))) ;TODO
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
