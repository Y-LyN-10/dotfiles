(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf" "#eeeeec"])
 '(comment-style (quote multi-line))
 '(custom-enabled-themes (quote (wombat)))
 '(display-time-mode t)
 '(fringe-mode (quote (0)) nil (fringe))
 '(inhibit-startup-screen t)
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(menu-bar-mode nil)
 '(speedbar-frame-parameters (quote ((width . 40))))
 '(speedbar-show-unknown-files t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(put 'upcase-region 'disabled nil)
(add-to-list 'load-path "~/elisp")

;; auto-refresh all buffers when files have changed on disk
(global-auto-revert-mode t)
(setq debug-on-error t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs theme customize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; badger theme
(add-to-list 'custom-theme-load-path "~/elisp/themes")
(load-theme 'badger t)

;; save sessions
(desktop-save-mode 1)

;; make whitespace-mode use just basic coloring
(setq whitespace-style (quote (tabs newline tab-mark)))

;; struck-through the headline after a DONE keyword in org mode
(setq org-fontify-done-headline t)

;; Directory tree
(require 'sr-speedbar)
(sr-speedbar-open)
(global-set-key (kbd "s-s") 'sr-speedbar-toggle)

;; fringle-mode right only, add scroll bar
(set-fringe-mode '(0 . nil))
(set-scroll-bar-mode 'right)

;; TODO: auto-scroll bar, based on text height

;; select all
(global-set-key "\C-a" 'mark-whole-buffer)

;; Line numbers
(linum-mode t)

;; TODO: remove linum mode at speedbar frame

;; Separating line numbers from text
;; (setq linum-format "%d ")
(setq linum-format "%4d \u2502 ")

;; Use spaces instead of tabs
(setq-default indent-tabs-mode nil)
(setq tab-width 4) ; or any other preferred value
    (defvaralias 'c-basic-offset 'tab-width)
    (setq js-indent-level 2)
    (setq-default js2-basic-offset 2)

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

;; highlight all occurences of a word
(require 'highlight-symbol)
(global-set-key [(control f3)] 'highlight-symbol)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)
(global-set-key [(meta f3)] 'highlight-symbol-query-replace)

;; fixmee plugin
(require 'fixmee)

;; Multiple Cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)

;; end in a newline
(setq require-final-newline 't)

;; Click on URLs in manual pages
(add-hook 'Man-mode-hook 'goto-address)

;; js2 extras mode
;; (js2-imenu-extras-mode)

;; Comments
(setq comment-start "/*" 
      comment-end "*/" 
      comment-style 'multi-line) 

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

;; JavaScript auto-complete with tern
(add-to-list 'load-path "/home/yten/bin/tern/emacs/")
(autoload 'tern-mode "tern.el" nil t)
(add-hook 'js-mode-hook (lambda () (tern-mode t)))

(autoload 'tern-mode "tern-auto-complete.el" nil t)
(eval-after-load 'tern
   '(progn
      (require 'tern-auto-complete)
      (tern-ac-setup)))

;; folding
(add-hook 'js-mode-hook
          (lambda ()
            ;; Scan the file for nested code blocks
            (imenu-add-menubar-index)
            ;; Activate the folding mode
            (hs-minor-mode t)))

;; key-bindings for folding JS code (same as in web-mode for HTML)
(global-set-key (kbd "\C-c \C-f") 'hs-toggle-hiding)

;; auto-enable cool modes
(require 'auto-complete)
(global-auto-complete-mode t)
(global-company-mode t)
(electric-pair-mode t)
(show-paren-mode 1)

;; Markdown support
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; Use emacs keybindings in term-mode
(add-hook 'term-mode-hook
          '(lambda ()
             (term-set-escape-char ?\C-x)))

;; jade-mode
(add-to-list 'load-path "~/elisp/jade-mode")
(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl\\'" . sws-mode))

;; Spotify keybindings
(global-set-key (kbd "\C-N") 'spotify-next)
(global-set-key (kbd "\C-R") 'spotify-prev)
(global-set-key (kbd "\C-c") 'spotify-current)
(global-set-key (kbd "\C-P") 'spotify-playpause) ;; toggle play/pause

;; smart-tabs
;; (smart-tabs-advice js2-indent-line js2-basic-offset)

;; Enable shift selection mode (shame on me)
(setq shift-select-mode t)

;; css-shit
(defun xah-syntax-color-hex ()
  "Syntax color text of the form 「#ff1100」 in current buffer.
URL `http://ergoemacs.org/emacs/emacs_CSS_colors.html'
Version 2015-06-11"
  (interactive)
  (font-lock-add-keywords
   nil
   '(("#[abcdef[:digit:]]\\{6\\}"
      (0 (put-text-property
          (match-beginning 0)
          (match-end 0)
          'face (list :background (match-string-no-properties 0)))))))
  (font-lock-fontify-buffer))

(add-hook 'css-mode-hook 'xah-syntax-color-hex)
(add-hook 'js2-mode-hook 'xah-syntax-color-hex)
(add-hook 'html-mode-hook 'xah-syntax-color-hex)

;; Let's play with GO!
(setenv "GOPATH" "~/go")

(add-to-list 'load-path "~/elisp/go-mode.el")
(add-to-list 'load-path "~/elisp/generated-autoload-file")
(add-to-list 'exec-path "~/go/bin")

; TODO: Godef jump key binding                                                   
(require 'go-mode-load)

(require 'go-complete)
(add-hook 'completion-at-point-functions 'go-complete-at-point)
(require 'go-autocomplete)

(require 'auto-complete-config)
(define-key ac-mode-map (kbd "C-TAB") 'auto-complete)

(add-to-list 'load-path "PATH CONTAINING golint.el" t)
(require 'golint)

; Call Gofmt before saving                                                    
(add-hook 'before-save-hook 'gofmt-before-save)

(add-hook 'go-mode-hook 'go-eldoc-setup)

; Snippets
(add-to-list 'yas-snippet-dirs "~/go/src/github.com/dominikh/yasnippet-go/go-mode/")

(eval-after-load "go-mode"
  '(require 'flymake-go))
(put 'scroll-left 'disabled nil)
(put 'downcase-region 'disabled nil)
