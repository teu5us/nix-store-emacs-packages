;;; nix-store-emacs-packages.el --- Summary:

;; Retrieve installed epkgs from the nix store.

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'straight)

;;;; Utility

(defun nsep/find-string (name lst)
  "Find string NAME in a list of strings LST."
  (cl-position name lst :test #'string-equal))

(defun nsep/pname (str)
  "Extract package name from STR."
  (cl-subseq str 0
             (cl-position ?- str :from-end t)))

(defun nsep/package-from-path (path)
  "Extract package name from store PATH."
  (let* ((split (split-string path "/"))
         (package (nth (+ 2 (nsep/find-string "site-lisp" split)) split)))
    (nsep/pname package)))

(defun nsep/store-path-filter (path)
  "Check if PATH is a store path installed by emacsWithPackages."
  (string-match-p "^/nix/store/[a-z0-9]+-emacs-packages-deps" path))

;;;; Key definitions

(defun nsep/installed-packages ()
  "Return a list of packages installed by nix."
  (cl-remove-duplicates
   (mapcar #'nsep/package-from-path
             (cl-remove-if #'(lambda (path)
                               (or
                                (string-match-p "elpa$" path)
                                (string-match-p "site-lisp$" path)))
                             (cl-remove-if-not #'nsep/store-path-filter load-path)))
   :test #'string-equal))

(defun nsep/override-as-built-in (pname)
  "Override straight recipe for package PNAME with the 'built-in type."
  (let* ((pname-sym (intern pname))
         (recipe (cdr (straight-recipes-retrieve pname-sym))))
    (setf (cl-getf recipe :type) 'built-in)
    (setq recipe (cons pname-sym recipe))
    (straight-override-recipe recipe)))

;; (defun nsep/straight-if-not-in-store (args)
;;   "Advice `straight-use-package' to register package if found in the nix store.
;; Otherwise, call `straight-use-package' with ARGS"
;;   (let* ((melpa-style-recipe (car-safe args))
;;          (recipe (straight--convert-recipe
;;                   (or
;;                    (straight--get-overridden-recipe
;;                     (if (listp melpa-style-recipe)
;;                         (car melpa-style-recipe)
;;                       melpa-style-recipe))
;;                    melpa-style-recipe)
;;                   nil))
;;          (package (cl-getf recipe :package))
;;          (deps (straight--get-dependencies package)))
;;     (when (member package (nsep/installed-packages))
;;       (dolist (p `(,package ,@deps))
;;         (unless (string-equal p "emacs")
;;           (nsep/override-as-built-in p))))
;;     args))

(defun nsep/override-installed ()
  "Override installed packages as 'built-in."
  (dolist (p (nsep/installed-packages))
    (nsep/override-as-built-in p)))

;;;; Set things up

;; (advice-add 'straight-use-package :filter-args #'nsep/straight-if-not-in-store)

(nsep/override-installed)

(provide 'nix-store-emacs-packages)
;;; nix-store-packages ends here
