(asdf:defsystem #:edgar
  :description "New CLOG System"
  :author "some@one.com"
  :license  "BSD"
  :version "0.0.0"
  :serial t
  :entry-point "edgar:start-app"  
  :depends-on (#:clog #:local-time #:cl-markdown) ; add clog plugins here as #:plugin for run time
  :components ((:file "edgar")
               (:file "commands")
               ))

(asdf:defsystem #:edgar/tools
  :defsystem-depends-on (:clog)
  :depends-on (#:edgar #:clog/tools ) ; add clog plugins here as #:plugin/tools for design time
  :components ())
