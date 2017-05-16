Inspired by [gc-refresh-mode](https://github.com/Unitech/gc-refresh-mode) this is an example of how to use the [Chrome debugging protocol ](https://developer.chrome.com/devtools/docs/integrating) to refresh the browser when `C-x C-s` is typed in emacs.

It uses a small elisp portion of code and a python script that already embeds the max-weller's fork of the python library [chrome_remote_shell](https://github.com/max-weller/chrome_remote_shell).

# Installation

* Download this folder to your ~/emacs.d directory
* Give execution privileges to the script `chmod u+x ~/.emacs.d/chrome-reload-page/reload.py`
* Install python websocket-client library (`sudo pip install websocket-cliente`)
* Add to .emacs

```
(add-to-list 'load-path (expand-file-name "~/.emacs.d/chrome-reload-page"))
(require 'chrome-reload-page)
```

# Usage

* Type `M-x chrome-reload-page`
* Type the url (file:/// is a valid scheme)