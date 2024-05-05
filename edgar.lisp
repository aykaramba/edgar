

;;;; ====[ release ]====================================================================================
;;;;
;;;; v.0.2
;;;;

;;; ====[ load app ]=====================================================================================

(defpackage #:edgar
  (:use #:cl #:clog #:clog-web #:clog-gui #:clog-web-dbi )
  (:export start-app))

(in-package :edgar)

(defun start-app ()
  (initialize 'on-new-window :static-root (merge-pathnames "./www/" (asdf:system-source-directory :edgar)))
  (open-browser))


;;; ====[ variables and initialization ]===================================================================

;; set the database dir
(defparameter *db-dir* (format nil "~A~A" (asdf:system-source-directory :edgar) "data.db"))

;; set the db connection
(defparameter *sql-connection* (dbi:connect :sqlite3 :database-name *db-dir*))

;; set the email address in order to download edgar data
(defparameter *email* nil)

;; set the path of the downloads folder 
(defparameter *path* nil)

;; set the timestamp
(defparameter *timestamp* nil)

;; set file name - dex - json file
(defparameter *filename-dex-json* nil)

;; set file name - dex - list file
(defparameter *filename-dex-data* nil)

;; set the user agent for sec
(defparameter *sec-headers*
  '(
    `("User-Agent" . ,(format "~a" *email*))
    ))

;; company information
(defparameter *company-info* (make-hash-table :test 'equal))

;; set the new table name to import data into
(defparameter *table-name-import* nil)

;; set the table name as the current view
(defparameter *table-name-current* nil)

;; set database import status
(defparameter *db-import-status* "no")


;;; ====[ edgar - render ]=================================================================================

(defun on-new-window (body)
  
  ;; initialize a few things
  (clog-gui-initialize body)
  (enable-clog-popup) ; To allow browser popups

  ;; initialize the current *table-name-current* variable in order to display the latest downloaded data
  (let* ((conn (dbi:connect :sqlite3 :database-name *db-dir*))
	  (query (dbi:prepare conn (concatenate 'string  " SELECT * FROM "   "\""(format nil "~a" "000-ndx")"\""  " WHERE ROWID IN ( SELECT max( ROWID ) FROM "  "\""(format nil "~a" "000-ndx")"\""  "  )   " ))))
    
    (loop for row = (dbi:fetch query)
	  while row
	  do
	     (setf *table-name-current* (nth 5  row)))
    (dbi:disconnect conn))

  
  (defun reload (obj)
    (url-replace (location body) "/"))

  ;; initialize a bunch of things
  (load-css (html-document body) "https://www.w3schools.com/w3css/4/w3.css")
  (load-css (html-document body) "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css")
  
  (let* (;; initialize a few values on load
	 (var-current-sort-letter "a")
	 (var-current-sort-button "btn-a")
	 (var-current-sort-paginationnumber 1)
	 (btn-pagination 10)
	 
	 (conn (dbi:connect :sqlite3 :database-name *db-dir*))
	 
	 ;; create a list for per letter number pagination
	 (global-list-of-pagination-numbers (list  1))
	 
	 ;; menu items
	 (menu (create-div body :class "" :style "display:flex; flex-direction:row; justify-content:center;"))
	 
	 ;; anchor
	 (anchor (create-div menu :content "<a href=\"#\"></a>"))
	 
	 ;; buttons
	 (btn-reload (create-div menu :content "<span class=\"fa fa-rotate-right\"> </span>" :class "w3-red w3-button"))
	 (btn-data (create-div menu :content "<span class=\"fa fa-cloud-download\"> </span>" :class "w3-blue w3-button"))
	 (btn-window-notifications (create-div menu  :content "<span class=\"fa fa-heart-circle-exclamation\"> </span>" :class "w3-green w3-button ")) ;; pop-up
	 (btn-help (create-div menu  :content "<span class=\"fa fa-circle-info\"> </span>" :class "w3-pink w3-button "))
	 
	 ;; notifications
	 (notifications (create-div body  :content "-- [ notifications ] --" :style "text-align:center; margin-top:40px; font-weight:bold;"))

	 ;; content - renders all the content including the menus
	 (content (create-div body :style "text-align:center; margin-top:40px; "))

	 ;; menu - pagination
	 (menu-row-variables (create-div content :style "display:flex; flex-direction:row; justify-content:center;"))
	 (notification-current-dataset (create-div menu-row-variables :content (concatenate 'string "Current dataset: " (format nil "~a" *table-name-current*)) :class "w3-margin" ))
	 (btn-pagination (create-select menu-row-variables :label (create-label menu-row-variables :content "How many result per page?" :class "w3-margin")))
	 
	 ;; menu - pagination - letters
	 (menu-row-sort (create-div content :class "w3-margin"))
	 (btn-a (create-div menu-row-sort :content "A" :class "w3-light-gray w3-button w3-small"))
	 (btn-b (create-div menu-row-sort :content "B" :class "w3-light-gray w3-button w3-small"))
	 (btn-c (create-div menu-row-sort :content "C" :class "w3-light-gray w3-button w3-small"))
	 (btn-d (create-div menu-row-sort :content "D" :class "w3-light-gray w3-button w3-small"))
	 (btn-e (create-div menu-row-sort :content "E" :class "w3-light-gray w3-button w3-small"))
	 (btn-f (create-div menu-row-sort :content "F" :class "w3-light-gray w3-button w3-small"))
	 (btn-g (create-div menu-row-sort :content "G" :class "w3-light-gray w3-button w3-small"))
	 (btn-h (create-div menu-row-sort :content "H" :class "w3-light-gray w3-button w3-small"))
	 (btn-i (create-div menu-row-sort :content "I" :class "w3-light-gray w3-button w3-small"))
	 (btn-j (create-div menu-row-sort :content "J" :class "w3-light-gray w3-button w3-small"))
	 (btn-k (create-div menu-row-sort :content "K" :class "w3-light-gray w3-button w3-small"))
	 (btn-l (create-div menu-row-sort :content "L" :class "w3-light-gray w3-button w3-small"))
	 (btn-m (create-div menu-row-sort :content "M" :class "w3-light-gray w3-button w3-small"))
	 (btn-n (create-div menu-row-sort :content "N" :class "w3-light-gray w3-button w3-small"))
	 (btn-o (create-div menu-row-sort :content "O" :class "w3-light-gray w3-button w3-small"))
	 (btn-p (create-div menu-row-sort :content "P" :class "w3-light-gray w3-button w3-small"))
	 (btn-q (create-div menu-row-sort :content "Q" :class "w3-light-gray w3-button w3-small"))
	 (btn-r (create-div menu-row-sort :content "R" :class "w3-light-gray w3-button w3-small"))
	 (btn-s (create-div menu-row-sort :content "S" :class "w3-light-gray w3-button w3-small"))
	 (btn-t (create-div menu-row-sort :content "T" :class "w3-light-gray w3-button w3-small"))
	 (btn-u (create-div menu-row-sort :content "U" :class "w3-light-gray w3-button w3-small"))
	 (btn-v (create-div menu-row-sort :content "V" :class "w3-light-gray w3-button w3-small"))
	 (btn-w (create-div menu-row-sort :content "W" :class "w3-light-gray w3-button w3-small"))
	 (btn-x (create-div menu-row-sort :content "X" :class "w3-light-gray w3-button w3-small"))
	 (btn-y (create-div menu-row-sort :content "Y" :class "w3-light-gray w3-button w3-small"))
	 (btn-z (create-div menu-row-sort :content "Z" :class "w3-light-gray w3-button w3-small"))

	 ;; menu - pagination - numbers - top
	 (menu-row-pagination-top (create-div content :style "display:flex; flex-direction: column; align-items:center; align:center; text-align:center; margin-top:0px;"))
	 (menu-row-pagination-top-data (create-div menu-row-pagination-top :class "w3-margin" :style "width:1000px;"  ))

	 ;; data - render dynamic data into this div
	 (data (create-div content :style "display:flex; flex-direction: column; align-items:center; align:center; text-align:center; margin-top:0px;"))

	 ;; menu - pagination - numbers - bottom
	 (menu-row-pagination-bottom (create-div content :class "w3-margin" :content " <a href=\"#\"> Back to TOP </a>   ")))
    
    ;; btn-pagionation -  add options to pagination pulldown menu
    (add-select-options btn-pagination '("10" "20" "50" "100" "200"))
    
    ;; btn-pagination - add on-change events to the btn-pagination pulldown menu
    (set-on-change btn-pagination
		   (lambda (obj)
		     (list-companies-letter var-current-sort-letter)
		     (list-companies-letter-paginated var-current-sort-letter)))

    ;; notifications - update
    ;; removed the decorations between the double quotes below, it looks better this way
    ;; leaving the concatenate in because I may decide to bring back decorations in the future.
    (defun notifications-update (message)
      (setf (text notifications) (concatenate 'string  " " message " ")))
    
    ;; menu - set the on-mouseover events
    (set-on-mouse-over btn-reload
		       (lambda (obj)
			 (notifications-update "Reload page.")))

    (set-on-mouse-out btn-reload
		      (lambda (obj)
			(notifications-update "--[  notifications  ]--")))

    (set-on-mouse-over btn-data
		       (lambda (obj)
			 (notifications-update "Download company data from the Edgar service.")))

    (set-on-mouse-out btn-data
		      (lambda (obj)
			(notifications-update "--[  notifications  ]--")))

    (set-on-mouse-over btn-window-notifications
		       (lambda (obj)
			 (notifications-update "Quick and dirty notifications.")))
    
    (set-on-mouse-out btn-window-notifications
		      (lambda (obj)
			(notifications-update "--[  notifications  ]--")))

    (set-on-mouse-over btn-help
		       (lambda (obj)
			 (notifications-update "Help file.")))
    
    (set-on-mouse-out btn-help
		      (lambda (obj)
			(notifications-update "--[  notifications  ]--")))
    
    
    ;; menu - set the on-click events
    (set-on-click btn-reload 
		  (lambda (obj)
		    
		    (if (equalp  "yes"  *db-import-status*)

			;; if yes, clear out the content and display message.
			(setf (text content) "There is a db import currently processing.  Please wait, it should complete in about a minute.")

			;; if no, proceed with rendering the data import page
			(reload ()))))

    

    
    ;; download data, stuff it into hash table, create table, import data into table, save dex file, save json file, create links to dex file, create links to json file
    (set-on-click btn-data
		  (lambda (obj)
		    (setf (text content) " ")
		    
		    ;; first we check to see if any data is being imported into the database.
		    ;; if it is, do not display anything in the content div except a notice
		    (if (equalp  "yes"  *db-import-status*)

			;; if yes, clear out the content and display message.
			(setf (text content) "There is a db import currently processing.  Please wait, it should complete in about a minute.")

			;; if no, proceed with rendering the data import page
			(let* (  ;; menu
			       (menu-data (create-div content :style "display:flex; flex-direction:row; justify-content:center;"))
			       
			       ;; (data (create-div content :class "w3-orange " :style "display:flex; flex-direction:column; justify-content:center; "))
			       (data (create-div content :style "display:flex; flex-direction: column; align-items:center; align:center; text-align:center; margin-top:0px;"))

			       ;; db connection
			       (conn (dbi:connect :sqlite3 :database-name *db-dir*))
			       
			       ;; form - email
			       (f1  (create-form menu-data))
			       (email (create-form-element f1 :text :label (create-label f1 :content "Email Address:") :class "w3-margin-right"))
			       (download-dex (create-form-element f1 :submit :class "w3-button w3-green" :value "Download DEX File"))

			       ;; table - 000-ndx entries
			       (data-table (create-div data :class "w3-margin "))

			       ;; set the path to the downloads folder
			       (path (asdf:system-relative-pathname "edgar" "www/downloads" )))

			  ;; check email - on submit
			  (set-on-click download-dex
					(lambda (obj)

					  (if  (find #\@ (value email))  ;; not being very serious about checking email, just wan to give the user a quick heads up.

					       ;; --> dothis
					       (if (equalp "yes" *db-import-status*)

						   ;; --> do this
						   (setf (text data-table)  "YUP! Still importing data ... hang tight.")

						   ;; --> otherwise do this
						   ;; download data
						   (progn  
						     ;; test message
						     (notifications-update "Email looks valid, starting download of data.")

						     ;; set the path to the local asdf system download folder
						     (setf *path* (asdf:system-relative-pathname "edgar" "www/downloads/" ))
						     
						     ;; set the global var *email* to email
						     (setf *email* (value email))

						     ;; set the timestamp
						     (setf *timestamp* (local-time:format-timestring nil (local-time:now) :format '((:year 4) "-" (:month 2) "-" (:day 2) "-" (:hour 2) (:min 2) (:sec 2) (:msec  2))))

						     ;; set file name - dex - json file
						     (setf *filename-dex-json* (concatenate 'string  *timestamp* ".json" ))

						     ;; set file name - dex - list file
						     (setf *filename-dex-data* (concatenate 'string  *timestamp* ".data" ))
						     
						     ;; set the table name
						     (setf *table-name-import* *timestamp*)
						     
						     ;; create a table for this download
						     (dbi:execute (dbi:prepare conn  (concatenate 'string " CREATE TABLE " (write-to-string *table-name-import* )   "  \( \"ticker\" INTEGER NOT NULL UNIQUE, \"company\" INTEGER NOT NULL, \"cik\"  INTEGER NOT NULL \) ")))

						     ;; update the table of downloads in the data div
						     (setf (text data-table) " ... working, will take less than a minute ...  ") ;; clear the table first
						     
						     ;; download data, stuff data into hash table, save dex json file, save dex data to list of lists data file, populate dadabase, update 000-ndx with upload nfo
						     (read-tickers-to-hashtable-and-save)

						     ;; once the import is done, update the table of downloads in the data div
						     (setf (text-value data-table) " ") ;; clear the table first
						     
						     
						     ;; display a list 000-ndx entries in the data-table
						     ;; table - list all the download entries in 000-ndx table
						     ;; this is a list of all downloads in the database
						     ;; this means i need to add a delete function so all tables are updated + dropped appropriately
						     ;; this needs to be refactored into a function
						     (let* ((conn (dbi:connect :sqlite3 :database-name *db-dir*))
							    (query (dbi:prepare conn   (concatenate 'string  "SELECT * FROM "  "\""(format nil "~a" "000-ndx")"\""  )))
							    (table (create-table data-table :class "w3-white"))
							    (table-row))
						       
						       ;; column headers
						       (setf table-row (create-table-row table :class "w3-blue-gray w3-padding"))
						       (create-table-column table-row :content "DB Entry" :class "w3-padding") 
						       (create-table-column table-row :content "Email Used" :class "w3-padding") 
						       (create-table-column table-row :content "Table Name" :class "w3-padding") 
						       (create-table-column table-row :content "File - Lisp Data" :class "w3-padding") 
						       (create-table-column table-row :content "File - Json / DEX" :class "w3-padding") 
						       (create-table-column table-row :content "Date of Download" :class "w3-padding") 

						       ;; convert results of query
						       ;; this works
						       (loop for row = (dbi:fetch query)
							     while row
							     do (setf table-row (create-table-row table :class "w3-light-gray w3-padding"))
								
								;; dateofdbentry
								(create-table-column table-row :content (nth 1 row ) :class "w3-padding")
								
								;; email
								(create-table-column table-row :content (nth 3 row ) :class "w3-padding")
								
								;; tablename
								(create-table-column table-row :content (nth 5 row ) :class "w3-padding")
								
								;; filenamelispdata
								(create-table-column table-row :content (nth 7 row ) :class "w3-padding")
								
								;; filenamedexjson
								(create-table-column table-row :content (nth 9 row ) :class "w3-padding")
								
								;; dateofdownload
								(create-table-column table-row :content (nth 11 row ) :class "w3-padding"))
						       
						       (dbi:disconnect conn))))

					       ;; --> otherwise send notification
					       (notifications-update  "Your email does not look valid.  Please input a valid email address to download data."))))


			  ;; table - list all the download entries in 000-ndx table
			  ;; this is a list of all downloads in the database
			  ;; this means i need to add a delete function so all tables are updated + dropped appropriately
			  ;; this needs to be refactored into a function
			  (let* ((conn (dbi:connect :sqlite3 :database-name *db-dir*))
				 (query (dbi:prepare conn   (concatenate 'string  "SELECT * FROM "  "\""(format nil "~a" "000-ndx")"\""  )))
				 (table (create-table data-table :class "w3-white"))
				 (table-row))

			    ;; column headers
			    (setf table-row (create-table-row table :class "w3-blue-gray w3-padding"))
			    (create-table-column table-row :content "DB Entry" :class "w3-padding") 
			    (create-table-column table-row :content "Email Used" :class "w3-padding") 
			    (create-table-column table-row :content "Table Name" :class "w3-padding") 
			    (create-table-column table-row :content "File - Lisp Data" :class "w3-padding") 
			    (create-table-column table-row :content "File - Json / DEX" :class "w3-padding") 
			    (create-table-column table-row :content "Date of Download" :class "w3-padding") 
			    
			    ;; convert results of query
			    (loop for row = (dbi:fetch query)
				  while row
				  do (setf table-row (create-table-row table :class "w3-light-gray"))
				     
				     ;; dateofdbentry
				     (create-table-column table-row :content (nth 1 row ) :class "w3-padding")
				     
				     ;; email
				     (create-table-column table-row :content (nth 3 row ) :class "w3-padding")
				     
				     ;; tablename
				     (create-table-column table-row :content (nth 5 row ) :class "w3-padding")
				     
				     ;; filenamelispdata
				     (create-table-column table-row :content (nth 7 row ) :class "w3-padding")
				     
				     ;; filenamedexjson
				     (create-table-column table-row :content (nth 9 row ) :class "w3-padding")
				     
				     ;; dateofdownload
				     (create-table-column table-row :content (nth 11 row ) :class "w3-padding"))
			    
			    (dbi:disconnect conn))))))


    ;; window - notifications / variables
    (set-on-click btn-window-notifications
		  (lambda (obj)
		    (let* (;; containers
			   (win (create-gui-window body :title "Notifications - Variables in the app." :client-movement t :width 800 :height 400 :keep-on-top t :title-class "w3-center w3-black"))
			   (content-container (create-div (window-content win) :class "w3-margin w3-padding" :style "display:flex; flex-direction: column; align-items:center; align:center; text-align:center; margin-top:0px;"))

			   ;; variables
			   (myvar-letter (create-div content-container :content "*"))
			   (myvar-button (create-div content-container :content "*"))
			   (myvar-paginationnumber (create-div content-container :content "*"))
			   (myvar-btn (create-div content-container :content "*"))
			   (myvar-email (create-div content-container :content "*"))
			   (myvar-database-import (create-div content-container :content "*"))
			   (myvar-db-table-latest (create-div content-container :content "*")))
		      
		      (loop 
			(setf (text myvar-letter) (concatenate 'string "Current sort letter: " var-current-sort-letter)) 
			(sleep 0.3)
			(setf (text myvar-button) (concatenate 'string "Current sort button: " var-current-sort-button))
			(setf (text myvar-paginationnumber) (concatenate 'string "Current sort button: " (format nil "~a"  (+ 1 var-current-sort-paginationnumber))))
			(setf (text myvar-btn) (concatenate 'string "Current sort button: " (format nil "~a" (value  btn-pagination))))
			(setf (text myvar-email) (concatenate 'string "Current email: " (format nil "~a" *email*)))
			(setf (text myvar-database-import) (concatenate 'string "Is the database currently importing any data: " (format nil "~a" *db-import-status*)))
			(setf (text myvar-db-table-latest) (concatenate 'string  "The current table being displayed is: " (format nil "~a" *table-name-current*)))))))

    
    (set-on-click btn-help
		  (lambda (obj)

		    (setf (text content) " ")
		    
		    (let* ((content-help (create-div content :style "display:flex; flex-direction: column; align-items:center; align:center; text-align:center; margin-top:0px;"))
			   (content-logo (create-div content-help  :style "width: 800px; ;"))
			   (content-text (create-div content-help :class "w3-margin-top" :style "width: 500px; text-align: left;"))
			   (content-nfo (create-div content-help :class "w3-margin-top" :style "width: 500px; text-align: left;"))
			   (data-readme (with-output-to-string (s) (cl-markdown:markdown (asdf:system-relative-pathname :edgar "README.md") :stream s)))
			   (data-nfo (with-output-to-string (s) (cl-markdown:markdown (asdf:system-relative-pathname :edgar "nfo") :stream s))))

		      (create-img content-logo :url-src "/img/logo.webp")
		      (create-div content-text :content data-readme)
		      (create-div content-nfo :content data-nfo))))

    ;; function - update all letter pagination buttons except the clicked button
    (defun change-ui-state-btn (btn-item)
      (let* ( (my-button btn-letter)
	      (list-buttons  (list btn-a btn-b btn-c btn-d btn-e btn-f btn-g btn-h btn-i btn-j btn-k btn-l btn-m btn-n btn-o btn-p btn-q btn-r btn-s btn-t btn-u btn-v btn-w btn-x btn-y btn-z))
	      (my-list (remove my-button list-buttons)))
	(mapcar (lambda (x) 
		  (setf (css-class-name x) "w3-light-grey w3-button w3-small"))
		my-list)))


    ;; menu - paginaton letters -- set the on-click events
    (set-on-click btn-a
		  (lambda (obj)
		    (setf var-current-sort-letter  "a")
		    (setf var-current-sort-button "btn-a")
		    (setf (css-class-name btn-a) "w3-red w3-btn w3-small")
		    (list-companies-letter "a")
		    (list-companies-letter-paginated  "a") 
		    (change-ui-state-letter btn-a)))
    
    (set-on-click btn-b
		  (lambda (obj)
		    (setf var-current-sort-letter  "b")
		    (setf var-current-sort-button "btn-b")
		    (setf (css-class-name btn-b) "w3-red w3-btn w3-small")
		    (list-companies-letter "b")
		    (list-companies-letter-paginated  "b")
		    (change-ui-state-letter btn-b)))
    
    (set-on-click btn-c
		  (lambda (obj)
		    (setf var-current-sort-letter  "c")
		    (setf var-current-sort-button "btn-c")
		    (setf (css-class-name btn-c) "w3-red w3-btn w3-small")
		    (list-companies-letter "c")
		    (list-companies-letter-paginated  "c")
		    (change-ui-state-letter btn-c)))
    
    (set-on-click btn-d
		  (lambda (obj)
		    (setf var-current-sort-letter  "d")
		    (setf var-current-sort-button "btn-d")
		    (setf (css-class-name btn-d) "w3-red w3-btn w3-small")
		    (list-companies-letter "d")
		    (list-companies-letter-paginated  "d")
		    (change-ui-state-letter btn-d)))
    
    (set-on-click btn-e
		  (lambda (obj)
		    (setf var-current-sort-letter  "e")
		    (setf var-current-sort-button "btn-e")
		    (setf (css-class-name btn-e) "w3-red w3-btn w3-small")
		    (list-companies-letter "e")
		    (list-companies-letter-paginated  "e")
		    (change-ui-state-letter btn-e)))
    
    (set-on-click btn-f
		  (lambda (obj)
		    (setf var-current-sort-letter  "f")
		    (setf var-current-sort-button "btn-f")
		    (setf (css-class-name btn-f) "w3-red w3-btn w3-small")
		    (list-companies-letter "f")
		    (list-companies-letter-paginated  "f")
		    (change-ui-state-letter btn-f)))

    (set-on-click btn-g
		  (lambda (obj)
		    (setf var-current-sort-letter  "g")
		    (setf var-current-sort-button "btn-g")
		    (setf (css-class-name btn-g) "w3-red w3-btn w3-small")
		    (list-companies-letter "g")
		    (list-companies-letter-paginated  "g")
		    (change-ui-state-letter btn-g)))
    
    (set-on-click btn-h
		  (lambda (obj)
		    (setf var-current-sort-letter  "h")
		    (setf var-current-sort-button "btn-h")
		    (setf (css-class-name btn-h) "w3-red w3-btn w3-small")
		    (list-companies-letter "h")
		    (list-companies-letter-paginated  "h")
		    (change-ui-state-letter btn-h)))
    
    (set-on-click btn-i
		  (lambda (obj)
		    (setf var-current-sort-letter  "i")
		    (setf var-current-sort-button "btn-i")
		    (setf (css-class-name btn-i) "w3-red w3-btn w3-small")
		    (list-companies-letter "i")
		    (list-companies-letter-paginated  "i")
		    (change-ui-state-letter btn-i)))
    
    (set-on-click btn-j
		  (lambda (obj)
		    (setf var-current-sort-letter  "j")
		    (setf var-current-sort-button "btn-j")
		    (setf (css-class-name btn-j) "w3-red w3-btn w3-small")
		    (list-companies-letter "j")
		    (list-companies-letter-paginated  "j")
		    (change-ui-state-letter btn-j)))
    
    (set-on-click btn-k
		  (lambda (obj)
		    (setf var-current-sort-letter  "k")
		    (setf var-current-sort-button "btn-k")
		    (setf (css-class-name btn-k) "w3-red w3-btn w3-small")
		    (list-companies-letter "k")
		    (list-companies-letter-paginated  "k")
		    (change-ui-state-letter btn-k)))
    
    (set-on-click btn-l
		  (lambda (obj)
		    (setf var-current-sort-letter  "l")
		    (setf var-current-sort-button "btn-l")
		    (setf (css-class-name btn-l) "w3-red w3-btn w3-small")
		    (list-companies-letter "l")
		    (list-companies-letter-paginated  "l")
		    (change-ui-state-letter btn-l)))

    (set-on-click btn-m
		  (lambda (obj)
		    (setf var-current-sort-letter  "m")
		    (setf var-current-sort-button "btn-m")
		    (setf (css-class-name btn-m) "w3-red w3-btn w3-small")
		    (list-companies-letter "m")
		    (list-companies-letter-paginated  "m")
		    (change-ui-state-letter btn-m)))
    
    (set-on-click btn-n
		  (lambda (obj)
		    (setf var-current-sort-letter  "n")
		    (setf var-current-sort-button "btn-n")
		    (setf (css-class-name btn-n) "w3-red w3-btn w3-small")
		    (list-companies-letter "n")
		    (list-companies-letter-paginated  "n")
		    (change-ui-state-letter btn-n)))
    
    (set-on-click btn-o
		  (lambda (obj)
		    (setf var-current-sort-letter  "o")
		    (setf var-current-sort-button "btn-o")
		    (setf (css-class-name btn-o) "w3-red w3-btn w3-small")
		    (list-companies-letter "o")
		    (list-companies-letter-paginated  "o")
		    (change-ui-state-letter btn-o)))
    
    (set-on-click btn-p
		  (lambda (obj)
		    (setf var-current-sort-letter  "p")
		    (setf var-current-sort-button "btn-p")
		    (setf (css-class-name btn-p) "w3-red w3-btn w3-small")
		    (list-companies-letter "p")
		    (list-companies-letter-paginated  "p")
		    (change-ui-state-letter btn-p)))
    
    (set-on-click btn-q
		  (lambda (obj)
		    (setf var-current-sort-letter  "q")
		    (setf var-current-sort-button "btn-q")
		    (setf (css-class-name btn-q) "w3-red w3-btn w3-small")
		    (list-companies-letter "q")
		    (list-companies-letter-paginated  "q")
		    (change-ui-state-letter btn-q)))
    
    (set-on-click btn-r
		  (lambda (obj)
		    (setf var-current-sort-letter  "r")
		    (setf var-current-sort-button "btn-r")
		    (setf (css-class-name btn-r) "w3-red w3-btn w3-small")
		    (list-companies-letter "r")
		    (list-companies-letter-paginated  "r")
		    (change-ui-state-letter btn-r)))

    (set-on-click btn-s
		  (lambda (obj)
		    (setf var-current-sort-letter  "s")
		    (setf var-current-sort-button "btn-s")
		    (setf (css-class-name btn-s) "w3-red w3-btn w3-small")
		    (list-companies-letter "s")
		    (list-companies-letter-paginated  "s")
		    (change-ui-state-letter btn-s)))
    
    (set-on-click btn-t
		  (lambda (obj)
		    (setf var-current-sort-letter  "t")
		    (setf var-current-sort-button "btn-t")
		    (setf (css-class-name btn-t) "w3-red w3-btn w3-small")
		    (list-companies-letter "t")
		    (list-companies-letter-paginated  "t")
		    (change-ui-state-letter btn-t)))
    
    (set-on-click btn-u
		  (lambda (obj)
		    (setf var-current-sort-letter  "u")
		    (setf var-current-sort-button "btn-u")
		    (setf (css-class-name btn-u) "w3-red w3-btn w3-small")
		    (list-companies-letter "u")
		    (list-companies-letter-paginated  "u")
		    (change-ui-state-letter btn-u)))
    
    (set-on-click btn-v
		  (lambda (obj)
		    (setf var-current-sort-letter  "v")
		    (setf var-current-sort-button "btn-v")
		    (setf (css-class-name btn-v) "w3-red w3-btn w3-small")
		    (list-companies-letter "v")
		    (list-companies-letter-paginated  "v")
		    (change-ui-state-letter btn-v)))
    
    (set-on-click btn-w
		  (lambda (obj)
		    (setf var-current-sort-letter  "w")
		    (setf var-current-sort-button "btn-w")
		    (setf (css-class-name btn-w) "w3-red w3-btn w3-small")
		    (list-companies-letter "w")
		    (list-companies-letter-paginated  "w")
		    (change-ui-state-letter btn-w)))
    
    (set-on-click btn-x
		  (lambda (obj)
		    (setf var-current-sort-letter  "x")
		    (setf var-current-sort-button "btn-x")
		    (setf (css-class-name btn-x) "w3-red w3-btn w3-small")
		    (list-companies-letter "x")
		    (list-companies-letter-paginated  "x")
		    (change-ui-state-letter btn-x)))
    
    (set-on-click btn-y
		  (lambda (obj)
		    (setf var-current-sort-letter  "y")
		    (setf var-current-sort-button "btn-y")
		    (setf (css-class-name btn-y) "w3-red w3-btn w3-small")
		    (list-companies-letter "y")
		    (list-companies-letter-paginated  "y")
		    (change-ui-state-letter btn-y)))
    
    (set-on-click btn-z
		  (lambda (obj)
		    (setf var-current-sort-letter  "z")
		    (setf var-current-sort-button "btn-z")
		    (setf (css-class-name btn-z) "w3-red w3-btn w3-small")
		    (list-companies-letter "z")
		    (list-companies-letter-paginated  "z")
		    (change-ui-state-letter btn-z)))

    ;; function - update all letter pagination buttons except the clicked button
    (defun change-ui-state-letter (btn-letter)
      (let* ( (my-button btn-letter)
	      (list-buttons  (list btn-a btn-b btn-c btn-d btn-e btn-f btn-g btn-h btn-i btn-j btn-k btn-l btn-m btn-n btn-o btn-p btn-q btn-r btn-s btn-t btn-u btn-v btn-w btn-x btn-y btn-z))
	      (my-list (remove my-button list-buttons)))
	(mapcar (lambda (x) 
		  (setf (css-class-name x) "w3-light-grey w3-button w3-small"))
		my-list)))

    ;; function - update all number pagination buttons except the clicked button
    (defun change-ui-state-number (btn-number)
      (let* ((tmp-number-btn (remove btn-number  global-list-of-pagination-numbers)))
	(mapcar (lambda (x)
		  (setf (css-class-name x) "w3-button w3-small"))
		tmp-number-btn)))
    
    ;; create a functions sort companies by letter 
    (defun list-companies-letter (v-sort)
      (setf (text data) " ")

      ;; test if we have any entries in the 000-ndx table
      ;; (defparameter *table-name-current* nil)
      (if (not *table-name-current*)
	  
	  ;; do this
	  (setf (text data) "No data exists, please download to begin.")

	  ;; otherwise do this
	  (let* ((conn (dbi:connect :sqlite3 :database-name *db-dir*))
		 (query (dbi:prepare conn  (concatenate 'string "SELECT * FROM (SELECT * FROM "   "\""(format nil "~a" *table-name-current*)"\""  "  WHERE ticker LIKE '" v-sort "%' ORDER BY company ASC) LIMIT " (value btn-pagination) " OFFSET 0")))
		 (table (create-table data :class "w3-white"))
		 (table-row))
	    
	    ;; clear the menu-row-pagination-top-data
	    (setf (text menu-row-pagination-top-data) " ")
	    
	    ;; column headers
	    (setf table-row (create-table-row table :class "w3-blue-gray w3-padding"))
	    (create-table-column table-row :content "Ticker" :class "w3-padding") 
	    (create-table-column table-row :content "Company" :class "w3-padding") 
	    (create-table-column table-row :content "CIK Number" :class "w3-padding") 

	    ;; create columns
	    ;; convert results of query
	    (loop for row = (dbi:fetch query)
		  while row
		  do (setf table-row (create-table-row table))
		     (create-table-column table-row :content (car ( cdr row)) :class "w3-light-gray w3-padding")
		     (create-table-column table-row :content (first  (cdddr row)) :class "w3-light-gray w3-padding")
		     (create-table-column table-row :content (second  (cddddr row)) :class "w3-light-gray w3-padding"))
	    
	    (dbi:disconnect conn))))
    
    ;; create pagination links for each letter sort
    (defun list-companies-letter-paginated (v-sort)

      ;; test if we have any entries in the 000-ndx table
      (if (not *table-name-current*)

	  ;; do this
	  (princ nil)

	  ;; otherwise do this
	  (let* ((conn (dbi:connect :sqlite3 :database-name *db-dir*))
		   (count (dbi:prepare conn  (concatenate 'string "SELECT COUNT(*) FROM "  "\""(format nil "~a" *table-name-current*)"\""  "   WHERE ticker LIKE '" v-sort "%' ORDER BY company ASC")))
		   (total-page-number (floor (/ (car  (last (dbi:fetch  count))) (parse-integer (value btn-pagination)) ))))
	    
	    ;; clear the menu-row-pagination-top-data
	    (setf (text menu-row-pagination-top-data) "  ")
	    
	    ;; clear out global variable
	    (setf global-list-of-pagination-numbers nil)
	    
	    ;; main loop for creating and rendering the pagination numbers
	    (loop for x from 0 to total-page-number
		  do
		     (let (  (btn-x (create-div menu-row-pagination-top-data :content (+ 1 x) :class "w3-button w3-small"))
			     (page-number x))
		       
		       ;; append each clog obj for btn-x to the global-list-of-paginatio-numbers var
		       ;; note to self: global-list-of-pagination-numbers ends up backwards
		       (setf global-list-of-pagination-numbers (append (list btn-x)  global-list-of-pagination-numbers   ) )
		       
		       (set-on-click btn-x 
				     (lambda (obj)
				       (setf var-current-sort-paginationnumber page-number)
				       
				       ;; clear the data div
				       (setf (text data) " ")
				       
				       ;; render paginated number view, set clicked button color to red, update paginated number colour state 
				       (list-companies-letter-paginated-singleview v-sort page-number)
				       (setf (css-class-name btn-x) "w3-red w3-button w3-small")
				       (change-ui-state-number btn-x)
				       ))))
	    
	    ;; set the first paginated number item to active
	    ;; note: since we are appending btn-x to global-list-of-pagination-numbers, the list is appending to the beginning and therefore is in reverse order
	    ;; note: we cannot use last either because the btn-x labels are incremented with a (+ 1 .. ) because a page labled "0" makes no sense
	    ;; note: this means we get the actual last item appended to the list which is the nth item of total-page-nunmber calculated aboe
	    (setf (css-class-name (nth total-page-number global-list-of-pagination-numbers)) "w3-red w3-button w3-small")
	    
	    (dbi:disconnect conn))))
    
    ;; create the table for each paginated link
    (defun list-companies-letter-paginated-singleview (v-sort-letter v-offset-number)
      (let* ((table (create-table data :class "w3-white" ))
	      (table-row))
	
	;; column headers
	(setf table-row (create-table-row table :class "w3-blue-gray w3-padding"))
	(create-table-column table-row :content "Ticker" :class "w3-padding") 
	(create-table-column table-row :content "Company" :class "w3-padding") 
	(create-table-column table-row :content "CIK Number" :class "w3-padding") 

	
	(let* ((conn (dbi:connect :sqlite3 :database-name *db-dir*))
		(paginated-query (dbi:prepare conn (concatenate 'string "SELECT * FROM (SELECT * FROM "  "\""(format nil "~a" *table-name-current*)"\""  "   WHERE ticker LIKE '" v-sort-letter "%' ORDER BY company ASC) LIMIT " (value btn-pagination)  (format nil " OFFSET ~a"  (* (parse-integer (value btn-pagination)) v-offset-number) )))))
	  
	  (loop for row = (dbi:fetch paginated-query)
		while row
		do (setf table-row (create-table-row table))
		   (create-table-column table-row :content (car ( cdr row)) :class "w3-padding w3-light-gray")
		   (create-table-column table-row :content (first  (cdddr row)) :class "w3-padding w3-light-gray")
		   (create-table-column table-row :content (second  (cddddr row)) :class "w3-padding w3-light-gray"))
	  
	  (dbi:disconnect conn))))

    ;; once everything is setup, let's default to showing a companies paginated to the default value of btn-pagination pulldown menu         
    (setf (css-class-name btn-a) "w3-red w3-btn ")

    ;; render letter paginated view, number paginated view
    (list-companies-letter var-current-sort-letter)
    (list-companies-letter-paginated  var-current-sort-letter)))



;;; ====[ edgar - core logic ]===================================================================
;;; 
;;; note: credit for most of the code in this section goes to  MURO from the SEC tutorials above.
;;; download the dex data from the SEC, convert the json data to a list and push data to a hash table
;;; this function needs to be refactored into individual functions
;;; this function is a proof of concept
(defun read-tickers-to-hashtable-and-save ()
  "Get list of companies from Edgar and store them in the *company-info* hash table, save json, save list of lists data, import data into the correct db table."

  ;; create a separte let for separation of purpose
  ;; first we updated 000-ndx to indicate we are about to start a download and record the data
  (let* ((conn (dbi:connect :sqlite3 :database-name *db-dir*))
	  (query (dbi:prepare conn (concatenate 'string " SELECT * FROM "  "\""(format nil "~a" "000-ndx")"\""  " WHERE ROWID IN ( SELECT max( ROWID ) FROM "  "\""(format nil "~a" "000-ndx")"\""  "  )   " ))))

    ;; create an entry for the data in the 000-ndx file
    (dbi:do-sql conn (sql-insert* (concatenate 'string  "\""(format nil "~a" "000-ndx")"\"" ) `(
												;; i don't know how to do datetime('now') yet, leaving this out 
												;; :dateofdbentry ,(format nil "~a" "datetime('now')")
												;; :dateofdbentry ,(concatenate 'string  (format nil "~a" "(datetime('now'))") )
												:email ,(format nil "~a" *email*)
												:tablename ,(format nil "~a" *table-name-import*)
												:filenamelispdata ,(format nil "~a" *filename-dex-data*)
												:filenamedexjson ,(format nil "~a" *filename-dex-json*)
												:dateofdownload ,(format nil "~a" *timestamp*))))

    
    ;; update the *table-name-current* variable to tell the system what the latest table to diplay
    (loop for row = (dbi:fetch query)
	  while row
	  do
	     (setf *table-name-current* (nth 5  row)))
    
    (dbi:disconnect conn))
  
  
  ;; main let for download and data manipulation
  (let* ((tickers (dex:get "https://www.sec.gov/files/company_tickers.json" :headers *sec-headers*))
	   (response (cl-json:decode-json-from-string tickers)))

    ;; save dex data in json format
    (with-open-file (s  
		     (concatenate 'string  (format nil "~a" *path*) *filename-dex-json* )
		     :direction :output
		     :if-does-not-exist :create
		     :if-exists :overwrite)
      (write tickers :stream s ))

    ;; save the dex data in list of lists format
    (with-open-file (s 
		     (concatenate 'string  (format nil "~a" *path*) *filename-dex-data* )
		     :direction :output
		     :if-does-not-exist :create
		     :if-exists :overwrite)
      (write response :stream s)) 
    
    

    ;; stuff data into hashtable
    (dolist (item response)
      (let* ((ticker (cdr (assoc :TICKER (cdr item))))
	       (cik (cdr (assoc :CIK--STR (cdr item))))
	       (company (cdr (assoc :TITLE (cdr item))))
	       (value (list (cons 'company company) (cons 'cik cik))))
	(setf (gethash ticker *company-info*) value)))

    
    ;; stuff the hashtable data into it's own table named *table-name*
    (let ((i (hash-table-count *company-info*))
	    (conn (dbi:connect :sqlite3 :database-name *db-dir*)))
      (with-hash-table-iterator (iterator *company-info*)
	(setf *db-import-status* "yes") ;; set db import status to yes
	(dotimes (i i)
	  (let* ((cmpny  (multiple-value-list (iterator)) ))
	    (dbi:do-sql conn (sql-insert* (concatenate 'string  "\""  (format nil "~a" *table-name-import*) "\"" ) `(
														     :ticker ,(first (cdr cmpny))
														     :company ,(cdr  (car (second (cdr cmpny))))
														     :cik ,(cdr (car (cdr (second (cdr cmpny)))))
														     ))))))

      ;; disconnect from db
      (dbi:disconnect conn)

      ;; set db import status to  no
      (setf *db-import-status* "no"))))

;; the cik number needs to be padded for a successful query
(defun pad-cik (cik)
  "Pad CIK number so it is always 10 digits long"
  (format nil "~10,'0d"  cik))

;; get the stock cik
(defun get-stock-cik (ticker)
  "Get CIK number for a given ticker"
  (let ((data (gethash ticker *company-info*)))
    (pad-cik (cdr (assoc 'cik data)))))

;; get the company name
(defun get-company-name (ticker)
  "Get company name for a given ticker"
  (let ( (data (gethash ticker *company-info*)))
    (cdr (assoc 'company data))))







;;; ====[ edgar - for next set of features, leave this alone for now ]===================================================================

;;;(defun get-company-concept (ticker taxonomy concept)
;;;  "Get company concept using a taxonomy and a concept"
;;;  (cl-json:decode-json-from-string 
;;;   (dex:get (format nil "https://data.sec.gov/api/xbrl/companyconcept/CIK~a/~a/~a.json" 
;;;                    (get-stock-cik ticker) 
;;;                    taxonomy concept)
;;;            :headers *sec-headers*)))


;;; We store our data in a variable called "data"
;;;(setf data (get-company-concept "AAPL" "us-gaap" "EarningsPerShareBasic"))

;;; And now we traverse the nested alist until we get to our EPS information
;;;(setf eps (loop for entry in 
;;;                   (cdr (assoc :+usd+/shares (cdr (assoc :units data))))
;;;                when (equal (cdr (assoc :FORM entry)) "10-K")
;;;                collect (list (cdr (assoc :FY entry)) (cdr (assoc :VAL entry))))
;;;      )

;;; notes:
;;; 
;;; we can now do calculations in the repl against data
;;; these examples can be used in a clog interface

;;; grab all earnings per share values for aapl
;;; (mapcar #'(lambda (x) (cadr x)) eps)

;;; calculate average earnings per share for aapl
;;; (/ (apply #'+ (mapcar #'(lambda (x) (cadr x)) eps)) 
;;;    (length eps))



