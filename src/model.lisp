(in-package :cl-user)

(defpackage rmrf.model
  (:use :cl
        :sxql)
        ;; :rmrf.web
  (:import-from :rmrf.db
                :db
                :with-connection
                :with-transaction)
  (:import-from :datafly
                :execute
                :retrieve-all
                :retrieve-one)
  (:import-from :sxql
                :create-table)
  (:export :create-user-table
           :add-user
           :check-password
           :find-user
           :find-user-by-email
           :authenticate-user))

(in-package :rmrf.model)

;;; User model


;; (datafly:defmodel (user (:inflate registered-at #'datetime-to-timestamp))
(defstruct (user)
  id
  email
  password)

(defun create-user-table ()
  "Create user table if it doesn't exist."
  (with-transaction (db)
    (execute
     (create-table (:user :if-not-exists t)
         ((id :type 'integer
              :primary-key t
              :auto-increment t)
          (email :type 'varchar\(64\)
                 :not-null t
                 :unique t)
          (password :type 'varchar\(128\)
                    :not-null t))))))

(defun add-user (email password)
  "Add user record to database."
  (if (find-user-by-email email)
      "This account already exists."
      (progn
        (with-transaction (db)
          (execute
           (insert-into :user
             (set= :email email
                   :password (cl-pass:hash password)))))
        nil)))

(defun check-password (password password2) ;TODO: rename
  (cond ((< (length password) 6)
         "Your password is too short. (6 characters minimum)")
        ((string/= password password2)
         "Your password and confirmation password do not match.")
        (t nil)))

(defun find-user (id)
  "Lookup user record by id."
  (with-transaction (db)
    (retrieve-one
     (select :* (from :user)
             (where (:= :id id)))
     :as 'user)))

(defun find-user-by-email (email)
  "Lookup user record by email."
  (with-transaction (db)
    (retrieve-one
     (select :* (from :user)
             (where (:= :email email)))
     :as 'user)))

(defun authenticate-user (email password)
  "Lookup user record and validate password."
  (let ((user (find-user-by-email email)))
    (if (and user (cl-pass:check-password password (user-password user)))
        (user-id user)
        nil)))
