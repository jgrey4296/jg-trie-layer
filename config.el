;; trie config.el
;; loaded fourth

(defgroup trie-modes '() "Customization group for trie-related modes")

(defvar jg-trie-layer/rule-helm-source nil
  "Main Helm Source for rule loading / finding ")
(defvar jg-trie-layer/rule-helm-dummy-source)
(defvar jg-trie-layer/type-helm-source nil
  "Main Helm Source for type loading / finding ")
(defvar jg-trie-layer/type-helm-dummy-source)




;;Variables for the active ide
(setq jg-trie-layer/trie-ide-is-running nil
      jg-trie-layer/python-process nil
      jg-trie-layer/window-configuration nil
      jg-trie-layer/ide-data-loc nil
      jg-trie-layer/ide-pipeline-spec-buffer nil
      )

(defcustom jg-trie-layer/process-python-command
  "python3"
  "Name of the Python program to use")

(defcustom jg-trie-layer/process-python-args
  ""
  "Arguments to python to run IDE server")


;;Defaults
(setq-default
 jg-trie-layer/inputs-buffer-name "*Rule Inputs*"
 jg-trie-layer/outputs-buffer-name "*Rule Outputs*"
 jg-trie-layer/working-group-buffer-name "*Rule Working Group*"
 jg-trie-layer/logging-buffer-name "*Rule Logs*"
 jg-trie-layer/python-process-buffer-name "*Rule IDE*"
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
