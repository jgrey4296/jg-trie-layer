;; trie config.el
;; loaded fourth

(defgroup trie-modes '() "Customization group for trie-related modes")

;;Variables for the active ide
(setq jg-trie-layer/trie-ide-is-running nil
      jg-trie-layer/python-process nil
      jg-trie-layer/window-configuration nil
      jg-trie-layer/ide-data-loc nil
      jg-trie-layer/ide-pipeline-spec-buffer nil
      )


;;Defaults
(setq-default
 jg-trie-layer/inputs-buffer-name "*Rule Inputs*"
 jg-trie-layer/outputs-buffer-name "*Rule Outputs*"
 jg-trie-layer/working-group-buffer-name "*Rule Working Group*"
 jg-trie-layer/logging-buffer-name "*Rule Logs*"
 jg-trie-layer/working-group-buffer-headings '("Defeaters"
                                      "Interferers"
                                      "Alternatives"
                                      "Equal Depth"
                                      "Relevant Types"
                                      "Meta"
                                      "Layer Stats"
                                      "Tests")
 jg-trie-layer/data-loc-subdirs '("rules"
                         "types"
                         "crosscuts"
                         "patterns"
                         "tests")

)

(spacemacs|define-transient-state trie-help-hydra
      :title "Transient State for Help in Rule IDE"
      :doc (concat "
   | General           ^^|
   |-------------------^^+
   | [_q_] Quit          |
   |                   ^^|
   |                   ^^|
   |                   ^^|
  ")
      :bindings
      ("q" nil :exit t)
      )
