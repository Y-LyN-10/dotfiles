(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf" "#eeeeec"])
 '(custom-enabled-themes (quote (tsdh-dark)))
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(put 'upcase-region 'disabled nil)
(add-to-list 'load-path "~/elisp")

(setq debug-on-error t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Marmelade package manager
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Emacs is not a package manager, and here we load its package manager!
(require 'package)
(dolist (source '(("marmalade" . "http://marmalade-repo.org/packages/")
                  ("elpa" . "http://tromey.com/elpa/")
                  ("melpa" . "http://melpa.milkbox.net/packages/")
                  ))

(add-to-list 'package-archives source t))
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs theme customize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Include current buffer name in the title bar
(setq frame-title-format '(buffer-file-name "%f" ("%b")))

;; Enable visual feedback on selections
(setq transient-mark-mode t)

;; fringle-mode right only, add scroll bar
(set-fringe-mode '(0 . nil))
(set-scroll-bar-mode 'right)

;; auto-scroll bar, based on text height
(setq-default
 mode-line-position
 '(:eval
   (let ((scroll-bars  (nth 2 (window-scroll-bars))))
     (if (or (> (point-max) (window-end))  (< (point-min) (window-start)))
         (unless scroll-bars (set-window-scroll-bars nil 20 t))
       (when scroll-bars (set-window-scroll-bars nil 0 t)))
     (unless (equal scroll-bars (nth 2 (window-scroll-bars))) (redraw-frame))
     `((-3 ,(propertize
             "%p"
             'local-map mode-line-column-line-number-mode-map
             'mouse-face 'mode-line-highlight
             'help-echo "Buffer position, mouse-1: Line/col menu"))
       (line-number-mode
        ((column-number-mode
          (10 ,(propertize
                " (%l,%c)"
                'face (and (> (current-column)
                              modelinepos-column-limit)
                           'modelinepos-column-warning)
                'local-map mode-line-column-line-number-mode-map
                'mouse-face 'mode-line-highlight
                'help-echo "Line and column, mouse-1: Line/col menu"))
          (6 ,(propertize
               " L%l"
               'local-map mode-line-column-line-number-mode-map
               'mouse-face 'mode-line-highlight
               'help-echo "Line number, mouse-1: Line/col menu"))))
        ((column-number-mode
          (5 ,(propertize
               " C%c"
               'face (and (> (current-column)
                             modelinepos-column-limit)
                          'modelinepos-column-warning)
               'local-map mode-line-column-line-number-mode-map
               'mouse-face 'mode-line-highlight
               'help-echo "Column number, mouse-1: Line/col menu")))))))))

;; surprise
(defconst animate-n-steps 3) 
  (defun emacs-reloaded ()
    (animate-string (concat ";; Initialization successful, welcome to "
  			  (substring (emacs-version) 0 16)
			  ".")
		  0 0)
    (newline-and-indent)  (newline-and-indent))

(add-hook 'after-init-hook 'emacs-reloaded)  

;; select all
(global-set-key "\C-c\C-a" 'mark-whole-buffer)

;; Directory tree
(require 'sr-speedbar)
(global-set-key (kbd "s-s") 'sr-speedbar-toggle)

;; Remove tool-bar
;; (gbby-one-zbqr f)

;; Line numbers
(global-linum-mode t)
(column-number-mode t)

;; Separating line numbers from text
;; (setq linum-format "%d ")
(setq linum-format "%4d \u2502 ")

;; Use spaces instead of tabs
(setq-default indent-tabs-mode nil)

;; Display or insert the current date and time
(defun date (&optional insert)
    "Display the current date and time.
  With a prefix arg, INSERT it into the buffer."
    (interactive "P")
    (funcall (if insert 'insert 'message)
             (format-time-string "%a, %d %b %Y %T %Z" (current-time))))

;; Smart inference in case of used tabs
(defun how-many-region (begin end regexp &optional interactive)
  "Print number of non-trivial matches for REGEXP in region.                    
Non-interactive arguments are Begin End Regexp"
  (interactive "r\nsHow many matches for (regexp): \np")
  (let ((count 0) opoint)
    (save-excursion
      (setq end (or end (point-max)))
      (goto-char (or begin (point)))
      (while (and (< (setq opoint (point)) end)
                  (re-search-forward regexp end t))
        (if (= opoint (point))
            (forward-char 1)
          (setq count (1+ count))))
      (if interactive (message "%d occurrences" count))
      count)))

(defun infer-indentation-style ()
  ;; if our source file uses tabs, we use tabs, if spaces spaces, and if        
  ;; neither, we use the current indent-tabs-mode                               
  (let ((space-count (how-many-region (point-min) (point-max) "^  "))
        (tab-count (how-many-region (point-min) (point-max) "^\t")))
    (if (> space-count tab-count) (setq indent-tabs-mode nil))
    (if (> tab-count space-count) (setq indent-tabs-mode t))))

(setq indent-tabs-mode nil)
(infer-indentation-style)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Packages & Other preferences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; helm auto-complete
(require 'ac-helm)
(global-set-key (kbd "C-:") 'ac-complete-with-helm)
(define-key ac-complete-mode-map (kbd "C-:") 'ac-complete-with-helm)

;; end in a newline
(setq require-final-newline 't)

;; Click on URLs in manual pages
(add-hook 'Man-mode-hook 'goto-address)

;; js2 extras mode
(js2-imenu-extras-mode)

;; js2-mode and jslint

;; After js2 has parsed a js file, we look for jslint globals decl comment ("/* global Fred, _, Harry */") and
;; add any symbols to a buffer-local var of acceptable global vars
;; Note that we also support the "symbol: true" way of specifying names via a hack (remove any ":true"
;; to make it look like a plain decl, and any ':false' are left behind so they'll effectively be ignored as
;; you can't have a symbol called "someName:false"

(add-hook 'js2-post-parse-callbacks
              (lambda ()
                (when (> (buffer-size) 0)
                  (let ((btext (replace-regexp-in-string
                                ": *true" " "
                                (replace-regexp-in-string "[\n\t ]+" " " (buffer-substring-no-properties 1 (buffer-size)) t t))))
                    (mapc (apply-partially 'add-to-list 'js2-additional-externs)
                          (split-string
                           (if (string-match "/\\* *global *\\(.*?\\) *\\*/" btext) (match-string-no-properties 1 btext) "")
                           " *, *" t))
                    ))))

;; Autocomplete with helm
(require 'ac-helm) ;; Not necessary if using ELPA package
(global-set-key (kbd "C-:") 'ac-complete-with-helm)
(define-key ac-complete-mode-map (kbd "C-:") 'ac-complete-with-helm)

;; jade-mode
(add-to-list 'load-path "~/elisp/jade-mode")
(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl\\'" . sws-mode))

;; smart-tabs
(smart-tabs-advice js2-indent-line js2-basic-offset)

;; tern
(add-hook 'js-mode-hook (lambda () (tern-mode t)))
(eval-after-load 'tern
   '(progn
      (require 'tern-auto-complete)
      (tern-ac-setup)))

(autoload 'tern-mode "tern.el" nil t)

;; folding
(require 'yafolding)

(defvar yafolding-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<C-S-return>") #'yafolding-hide-parent-element)
    (define-key map (kbd "<C-M-return>") #'yafolding-toggle-all)
    (define-key map (kbd "<C-return>") #'yafolding-toggle-element)
    map))

(define-key yafolding-mode-map (kbd "<C-S-return>") nil)
(define-key yafolding-mode-map (kbd "<C-M-return>") nil)
(define-key yafolding-mode-map (kbd "<C-return>") nil)
(define-key yafolding-mode-map (kbd "C-c <C-M-return>") 'yafolding-toggle-all)
(define-key yafolding-mode-map (kbd "C-c <C-S-return>") 'yafolding-hide-parent-element)
(define-key yafolding-mode-map (kbd "C-c <C-return>") 'yafolding-toggle-element)

