(in-package :cl-user)
(defpackage rmrf.config
  (:use :cl)
  (:import-from :envy
                :config-env-var
                :defconfig)
  (:export :config
           :*application-root*
           :*static-directory*
           :*template-directory*
           :appenv
           :developmentp
           :productionp))
(in-package :rmrf.config)

(setf (config-env-var) "APP_ENV")

(defparameter *application-root*   (asdf:system-source-directory :rmrf))
(defparameter *static-directory*   (merge-pathnames #P"static/" *application-root*))
(defparameter *template-directory* (merge-pathnames #P"templates/" *application-root*))

(defconfig |development|
    '(:debug T
      :databases
      ((:maindb :mysql :database-name "cavemandev" :username "username" :password "password"))))

(defconfig |production|
    '(:databases
      ((:maindb :mysql :database-name "caveman" :username "username" :password "password"))))

(defun config (&optional key)
  (envy:config #.(package-name *package*) key))

(defun appenv ()
  (uiop:getenv (config-env-var #.(package-name *package*))))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (string= (appenv) "production"))
