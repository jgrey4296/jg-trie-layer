;; trie funcs.el
;; loaded third.

;;Utilities
(defun jg-trie-layer/trie-ide-running-p ()
  " Tests whether the ide is running or not "
  jg-trie-layer/trie-ide-is-running
  )
(defun jg-trie-layer/no-op ()
  (interactive)
  )

;;Startup and Cleanup
(defun jg-trie-layer/toggle-trie-ide ()
  (interactive)
  (if (jg-trie-layer/trie-ide-running-p)
      (jg-trie-layer/stop-trie-ide)
    (jg-trie-layer/start-trie-ide))
  )
(defun jg-trie-layer/start-trie-ide ()
  " Start the trie ide, setting up windows, etc "
  (interactive)
  ;; Get the directory to work with
  (let ((location (read-file-name "Institution Location:"))
        (windows (jg-trie-layer/build-ide-window-layout))
        inst-name
        )


    ;;if a dir chosen, get a name for the
    ;;inst, create a stub, create a data dir
    (if (f-dir? location)
        (progn
          ;;get name for inst
          (setq inst-name (read-string "Institution Name: ")
                jg-trie-layer/ide-data-loc (f-join location (format "%s-data" inst-name)))
          )
      ;;else if an org chosen, load it and its data dir
      (progn
        (assert (equal (f-ext location) "org"))
        (setq inst-name (f-base location)
              location (f-parent location)
              jg-trie-layer/ide-data-loc (f-join location (format "%s-data" inst-name))
              )
        ))

    (setq jg-trie-layer/ide-pipeline-spec-buffer (format "%s.org" inst-name))
    (jg-trie-layer/maybe-build-data-loc)
    (jg-trie-layer/init-ide-buffers-contents location inst-name)

    (jg-trie-layer/load-directory-and-pipeline jg-trie-layer/ide-data-loc)
    ;;Save the window configuration
    (setq jg-trie-layer/window-confguration (current-window-configuration))
    ;;start python server
    (jg-trie-layer/run-python-server)
    ;;setup windows and their modes
    ;; (in trie | trie-select |
    ;; org | pipeline | explore | sequence)

    )

  (setq jg-trie-layer/trie-ide-running t)
  )
(defun jg-trie-layer/stop-trie-ide ()
  (interactive)
  ;;Clear windows, unload data
  (jg-trie-layer/dump-to-files)
  (setq jg-trie-layer/trie-ide-running nil)
  )

;;Directory and buffer initialisation
(defun jg-trie-layer/maybe-build-data-loc ( )
  ;;TODO: If doesn't exist, make the data location subdirectories
  (if (not (f-exists? jg-trie-layer/ide-data-loc))
      (progn (mkdir jg-trie-layer/ide-data-loc)
             (mapc (lambda (x) (mkdir (f-join jg-trie-layer/ide-data-loc x)))
                   jg-trie-layer/data-loc-subdirs)
             )
    )
  )
(defun jg-trie-layer/init-ide-buffers-contents (location inst-name)
  ;;create inst stub
  (if (not (f-exists? (f-join location jg-trie-layer/ide-pipeline-spec-buffer)))
      (progn
        (with-current-buffer (get-buffer-create jg-trie-layer/ide-pipeline-spec-buffer)
          ;; insert default institution contents
          (trie-mode)
          (org-mode)
          (yas-expand-snippet (yas-lookup-snippet "pipeline" 'trie-mode))
          (write-file (f-join location jg-trie-layer/ide-pipeline-spec-buffer))
          )
        )
    )


  (window--display-buffer (find-file (f-join location jg-trie-layer/ide-pipeline-spec-buffer)) (plist-get windows :miscL) 'window)
  (window--display-buffer (generate-new-buffer "rule_stub")  (plist-get windows :rule) 'window)
  (window--display-buffer (get-buffer-create jg-trie-layer/inputs-buffer-name)  (plist-get windows :prior)'window)
  (window--display-buffer (get-buffer-create jg-trie-layer/outputs-buffer-name)  (plist-get windows :post) 'window)
  (window--display-buffer (get-buffer-create jg-trie-layer/logging-buffer-name)  (plist-get windows :miscR) 'window)
  (window--display-buffer (get-buffer-create jg-trie-layer/working-group-buffer-name)  (plist-get windows :miscC) 'window)

  (jg-trie-layer/build-working-group-buffer)
  (with-current-buffer "rule_stub"
    (trie-mode)
    (yas-expand-snippet (yas-lookup-snippet "rule" 'trie-mode) (point-min))
    )

  (with-current-buffer jg-trie-layer/inputs-buffer-name
    (insert "AVAILABLE INPUTS:\n\n\n")
    )
  (with-current-buffer jg-trie-layer/outputs-buffer-name
    (insert "AVAILABLE OUTPUTS:\n\n\n")
    )
  (with-current-buffer jg-trie-layer/logging-buffer-name
    (insert "LOGGING:\n\n\n")
    )
  )
(defun jg-trie-layer/build-working-group-buffer ()
  (with-current-buffer jg-trie-layer/working-group-buffer-name
    (org-mode)
    (insert "* Working Group\n")
    (mapc (lambda (x) (insert "** " x ":\n")) jg-trie-layer/working-group-buffer-headings)
    )
  )

;;Window setup
(defun jg-trie-layer/reset-windows ()
  (interactive)
  (if (and (jg-trie-layer/trie-ide-running-p) (window-configuration-p jg-trie-layer/window-configuration))
      (set-window-configuration jg-trie-layer/window-configuration)
    )
  )
(cl-defun jg-trie-layer/build-ide-window-layout ()
  """ Setup rule editing windows """
  ;; (terminals - ) priors - rule - posts (terminals)
  ;;                       defeaters
  ;;       upstream stats  - alts - downstream stats
  (interactive)
  (let (prior post rule miscL miscC miscR)
    (delete-other-windows)
    ;; split in half
    (setq prior (selected-window))
    (setq miscL (split-window-below))
    ;;Top half:
    ;; Split into three: priors, rule, posts
    (setq rule (split-window-right))
    (select-window rule)
    (setq post (split-window-right))
    ;;Bottom Half
    ;; Split into three: upstream, alts, downstream
    (select-window miscL)
    (setq miscC (select-window (split-window-right)))
    (setq miscR (split-window-right))

    (list :prior prior :post post :rule rule :miscL miscL :miscC miscC :miscR miscR)
    )
  )
(defun jg-trie-layer/show-side-window (buffer &optional left)
  (interactive)
  ;; For Terminals:
  (display-buffer-in-side-window buffer `((side . ,(if left 'left 'right))))
  )

;;Loading and saving files
(defun jg-trie-layer/load-directory-and-pipeline (loc)
  " Given a location, load into ide "
  (let ((files (f-files loc nil t)))
    (loop for file in files do
          (let ((ftype (f-ext file)))
            ;;Handle each file type and store it in its management hash-table
            (cond ((equal ftype "rule"    ) )
                  ((equal ftype "type"    ) )
                  ((equal ftype "cc"      ) )
                  ((equal ftype "pattern" ) )
                  ((equal ftype "test"    ) )
                  )
            )
          )
    )
  )
(defun jg-trie-layer/dump-to-files ()
  (interactive)
  ;;Get all trie-* mode buffers, and the pipeline spec
  ;;and write to subdirs of jg-trie-layer/ide-data-loc



  )

(defun jg-trie-layer/load-rule (x)
  (message "loading %s" x)
  (with-temp-buffer
    (insert-file-contents x)
    (goto-char (point-min))
    (org-mode)
    ;;parse and store information
    ;;(org-map-tree jg-trie-layer/parse-rule)
    )
  )
(defun jg-trie-layer/load-type (x)
  (message "loading %s" x)
  (with-temp-buffer
    (insert-file-contents x)
    (goto-char (point-min))
    (org-mode)
    ;;parse and store information
    )
  )
(defun jg-trie-layer/load-crosscut (x)
  (message "loading %s" x)
  (with-temp-buffer
    (insert-file-contents x)
    (goto-char (point-min))
    (org-mode)
    ;;parse and store information
    )
  )
(defun jg-trie-layer/load-pattern (x)
  (message "loading %s" x)
  (with-temp-buffer
    (insert-file-contents x)
    (goto-char (point-min))
    (org-mode)
    ;;parse and store information
    )
  )
(defun jg-trie-layer/load-test (x)
  (message "loading %s" x)
  (with-temp-buffer
    (insert-file-contents x)
    (goto-char (point-min))
    (org-mode)
    ;;parse and store information
    )
  )

(defun jg-trie-layer/parse-rule (x)
  ;;Get the heading
  ;;get name
  ;;Get tags
  ;;Get conditions
  ;;Get actions
  )
(defun jg-trie-layer/parse-type (x)
  ;;Get name
  ;;Get structure
  ;;Get variables?
  ;;Get Tags
  )
(defun jg-trie-layer/parse-crosscut (x)
  ;;Get Name
  ;;get type
  ;;call subparser
  )
(defun jg-trie-layer/parse-pattern (x)
  ;;Get Name
  ;;Get Variables
  ;;Get tags

  )
(defun jg-trie-layer/parse-test (x)
  ;;Get name
  ;;Get states
  ;;Get Tags
  )

;;Python subprocess
(defun jg-trie-layer/run-python-server ()
  "Start a subprocess of python, loading the rule engine
ready to set the pipeline and rulesets, and to test"


  )

;;Testing
(defun jg-trie-layer/trigger-tests ()
  " Trigger a Bank of tests "
  (interactive)
  ;;with buffer rule logs
  ;;clear?
  ;;get tests for working group
  ;;run tests
  ;;print results


  )

;;Folding:
;; (defun jg-trie-layer/toggle-all-defs ()
;;   (interactive)
;;   ;; goto start of file
;;   (let* ((open-or-close 'evil-close-fold)
;;          (current (point))
;;          )
;;     (save-excursion
;;       (goto-char (point-min))
;;       (python-nav-forward-defun)
;;       (while (not (equal current (point)))
;;         (setq current (point))
;;         (if (jg-trie-layer/line-starts-with? "def ")
;;             (funcall open-or-close))
;;         (python-nav-forward-defun)
;;         )
;;       )
;;     )
;;   )
;; (defun jg-trie-layer/close-class-defs ()
;;   (interactive )
;;   (save-excursion
;;     (let* ((current (point)))
;;       (python-nav-backward-defun)
;;       (while (and (not (jg-trie-layer/line-starts-with? "class "))
;;                   (not (equal current (point))))
;;         (evil-close-fold)
;;         (setq current (point))
;;         (python-nav-backward-defun)
;;         )
;;       )
;;     )
;;   (save-excursion
;;     (let* ((current (point)))
;;       (python-nav-forward-defun)
;;       (while (and (not (jg-trie-layer/line-starts-with? "class "))
;;                   (not (equal current (point))))
;;         (evil-close-fold)
;;         (setq current (point))
;;         (python-nav-forward-defun)
;;         )
;;       )
;;     )
;;   )
;; (defun jg-trie-layer/setup-python-mode ()
;;   (evil-define-key 'normal python-mode-map
;;     (kbd "z d") 'jg-trie-layer/toggle-all-defs
;;     (kbd "z C") 'jg-trie-layer/close-class-defs
;;     ))

;; (src (helm-make-source "My Find" 'helm-source-ffiles))
;; (helm-ff-setup-update-hook)
;; (setq location (helm :sources (helm-make-source "My Find" 'helm-source-ffiles
;;                                 :action (helm-make-actions "Default" 'identity))
;;                      :input (expand-file-name (helm-current-directory))
;;                      :case-fold-search helm-file-name-case-fold-search
;;                      :ff-transformer-show-only-basename
;;                      helm-ff-transformer-show-only-basename
;;                      :prompt "Find my files"
;;                      :buffer "*helm my find*"
;;                      )
