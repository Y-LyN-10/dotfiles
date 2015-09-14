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
 '(display-time-mode t)
 '(inhibit-startup-screen t)
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(speedbar-frame-parameters (quote ((width . 40)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(put 'upcase-region 'disabled nil)
(add-to-list 'load-path "~/elisp")

(setq debug-on-error t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs theme customize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mark that there are unsaved changes in the current buffer name
(setq frame-title-format
    '((:eval (if (buffer-file-name)
                  (abbreviate-file-name (buffer-file-name))
                    "%b"))
      (:eval (if (buffer-modified-p) 
                 " •"))
      " - Emacs")
    )

;; Directory tree
(require 'sr-speedbar)
(sr-speedbar-open)
(global-set-key (kbd "s-s") 'sr-speedbar-toggle)

;; fringle-mode right only, add scroll bar
(set-fringe-mode '(0 . nil))
(set-scroll-bar-mode 'right)

;; TODO: auto-scroll bar, based on text height

;; select all
(global-set-key "\C-c\C-a" 'mark-whole-buffer)

;; Line numbers
(global-linum-mode t)
(column-number-mode t)
;; TODO: remove linum mode at speedbar frame

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

;; Adjust size of window accoridng to screen resolution.
(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if window-system
  (progn
    ;; use 120 char wide window for largeish displays
    ;; and smaller 80 column windows for smaller displays
    ;; pick whatever numbers make sense for you
    (if (> (x-display-pixel-width) 1280)
           (add-to-list 'default-frame-alist (cons 'width 120))
           (add-to-list 'default-frame-alist (cons 'width 85)))
    ;; for the height, subtract a couple hundred pixels
    ;; from the screen height (for panels, menubars and
    ;; whatnot), then divide by the height of a char to
    ;; get the height we want
    (add-to-list 'default-frame-alist 
         (cons 'height (/ (- (x-display-pixel-height) 200)
                             (frame-char-height)))))))

(set-frame-size-according-to-resolution)


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
;; (js2-imenu-extras-mode)

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
;; (smart-tabs-advice js2-indent-line js2-basic-offset)

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

;; Enable shift selection mode (shame on me)
(setq shift-select-mode t)

;; Let's play with GO Lang a little bit :))
(require 'go-complete)
(add-hook 'completion-at-point-functions 'go-complete-at-point)
(require 'go-autocomplete)

(require 'auto-complete-config)
(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)

(add-to-list 'load-path "PATH CONTAINING golint.el" t)
(require 'golint)
