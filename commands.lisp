(in-package :lem-user)
(define-key lem-lisp-mode:*lisp-mode-keymap* "C-c C-v" 'zzz)
(define-command zzz () () (edgar::reload ()))
