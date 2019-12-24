(defun trie-minor/test-fun ()
  (interactive)
  (message "Trie minor test")
)

(define-minor-mode trie-minor-mode
  "A Minor Mode for layering on top of org files for rule authoring"
  :lighter "TrieMM"
  :keymap (make-sparse-keymap)
  )

(provide 'trie-minor-mode)
