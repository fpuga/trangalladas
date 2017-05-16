;;; Inspired in https://github.com/Unitech/gc-refresh-mode by Strzelewicz Alexandre <strzelewicz.alexandre@gmail.com>
;;; Copyrigth (C) 2017 Francisco Puga <fpuga@icarto.es>
;;; GPL v3. See <http://www.gnu.org/licenses/>.

(defvar chrome-reload-page-hook nil)

(defun refresh-browser()
  (interactive)
  (save-buffer)
  (call-process "~/.emacs.d/chrome-reload-page/reload.py" nil 0 nil)
  )

(defun chrome-reload-page ()
  "Minor mode for refreshing Chrome when saving file"
  (interactive)
  ;; Read URL to find on tabs
  (setq url (read-from-minibuffer "Url to refresh: " "http://"))
  ;; Start Chrome with URL given + with the remote option
  (call-process "google-chrome" nil 0 nil url "--remote-debugging-port=9222")
  ;; Rebind Save keys
  (define-key global-map "\C-x\C-s" 'refresh-browser)
  )

(provide 'chrome-reload-page)
