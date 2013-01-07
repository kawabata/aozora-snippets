(defconst japanese-to-kana-buffer "*jp2kana*")
(defvar japanese-to-kana-process nil)
(defvar japanese-to-kana-hash (make-hash-table :test 'equal))
;; 以下の関数は青空文庫用のyasnippetでも使用する。
(defun japanese-to-kana-string (str)
  (if (null (executable-find "kakasi")) str)
  (when (null japanese-to-kana-process)
    (setq japanese-to-kana-process
          (start-process "kakasi" japanese-to-kana-buffer
                         ;; kakasi に必ず "-u" (fflush) を入れておかないと、バッファリングして
                         ;; 答えが返ってこなくなるので注意する。
                         "kakasi" "-u" "-ieuc" "-oeuc" "-KH" "-JH" "-EH" "-kH")))
  (or (gethash str japanese-to-kana-hash)
      (let ((old-buffer (current-buffer)))
        (unwind-protect
            (progn
              (set-buffer japanese-to-kana-buffer)
              (set-buffer-process-coding-system 'euc-jp-unix 'euc-jp-unix)
              (erase-buffer)
              (process-send-string japanese-to-kana-process (concat str "\n"))
              (while (= (buffer-size) 0)
                (accept-process-output nil 0 50))
              (puthash str (substring (buffer-string) 0 -1) japanese-to-kana-hash))
          (set-buffer old-buffer)))))

(defun ruby-clean-up ()
  (when (looking-back "\\\cC\\(.+\\)《.+\\(\\1\\)》")
    (insert (match-string 1))
    (delete-region (match-beginning 2) (match-end 2))
    (delete-region (match-beginning 1) (match-end 1))))

(add-hook 'yas-after-exit-snippet-hook 'ruby-clean-up)
